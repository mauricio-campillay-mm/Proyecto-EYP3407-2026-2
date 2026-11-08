# 03_modelos.R — ajuste y selección de hiperparámetros en desarrollo (2021-2022)
suppressPackageStartupMessages({
  library(tidymodels)
  library(glmnet)
  library(rpart)
  library(xgboost)
})
tidymodels_prefer(quiet = TRUE)
set.seed(3407)

N_HILOS <- min(8L, parallel::detectCores())

# --- 1. Datos de desarrollo y remuestreo temporal -----------------------
filas_dev <- which(base_modelo$t_seg < as.numeric(inicio_reserva))
col_modelo <- c("unique_key", "Yf", predictores_modelo)
dev <- base_modelo[filas_dev, col_modelo]

# Las particiones se expresan en índices de 'dev'; toda fila de desarrollo
# precede a la reserva, por lo que los índices coinciden con base_modelo.
stopifnot(identical(filas_dev, seq_along(filas_dev)))

remuestreo <- manual_rset(
  lapply(ventanas, function(v) make_splits(list(analysis = v$entrena, assessment = v$valida), data = dev)),
  ids = names(ventanas)
)

# --- 2. Preprocesamiento: se estima dentro del entrenamiento de cada ventana ----
crear_receta <- function(datos, predictores, normalizar = FALSE) {
  rec <- recipe(datos[, c("Yf", predictores)]) |>
    update_role(all_of(predictores), new_role = "predictor") |>
    update_role(Yf, new_role = "outcome") |>
    step_novel(all_nominal_predictors(), new_level = "nueva") |>
    step_unknown(all_nominal_predictors(), new_level = "faltante") |>
    step_other(all_nominal_predictors(), threshold = 0.005, other = "otras") |>
    step_impute_median(all_numeric_predictors()) |>
    step_dummy(all_nominal_predictors()) |>
    step_zv(all_predictors())
  if (normalizar) rec <- rec |> step_normalize(all_numeric_predictors())
  rec
}

# --- 3. Especificaciones (máximo 20 configuraciones por familia) --------
espec_m1 <- logistic_reg(penalty = tune(), mixture = 1) |> set_engine("glmnet")
grilla_m1 <- tibble(penalty = 10^seq(-5, -1, length.out = 20))

espec_m2 <- decision_tree(cost_complexity = tune(), min_n = 50, tree_depth = 30) |>
  set_engine("rpart") |> set_mode("classification")
grilla_m2 <- tibble(cost_complexity = 10^seq(-5, -2, length.out = 20))

espec_m3 <- boost_tree(
  trees = tune(), tree_depth = tune(), learn_rate = tune(), min_n = tune(),
  mtry = 0.8, sample_size = 0.8
) |>
  set_engine("xgboost", counts = FALSE, nthread = N_HILOS) |>
  set_mode("classification")
grilla_m3 <- grid_space_filling(
  trees(range = c(100L, 600L)),
  tree_depth(range = c(2L, 7L)),
  learn_rate(range = c(-2, -0.7)),
  min_n(range = c(5L, 50L)),
  size = 20
)

familias <- list(
  M1 = list(nombre = "M1: logística lasso", espec = espec_m1, grilla = grilla_m1, normalizar = TRUE),
  M2 = list(nombre = "M2: árbol podado",    espec = espec_m2, grilla = grilla_m2, normalizar = FALSE),
  M3 = list(nombre = "M3: boosting",        espec = espec_m3, grilla = grilla_m3, normalizar = FALSE)
)

metricas_ajuste <- metric_set(mn_log_loss, brier_class, roc_auc)

# --- 4. Búsqueda de hiperparámetros -------------------------------------
resultados_ajuste <- lapply(names(familias), function(m) {
  f <- familias[[m]]
  message("Ajustando ", f$nombre, " ...")
  set.seed(3407)
  flujo <- workflow() |>
    add_recipe(crear_receta(dev, predictores_modelo, f$normalizar)) |>
    add_model(f$espec)
  t_ini <- Sys.time()
  res <- tune_grid(
    flujo, resamples = remuestreo, grid = f$grilla, metrics = metricas_ajuste,
    control = control_grid(save_pred = TRUE, verbose = FALSE)
  )
  seg <- as.numeric(difftime(Sys.time(), t_ini, units = "secs"))
  mejor <- select_best(res, metric = "mn_log_loss")
  list(
    nombre = f$nombre, flujo = flujo, mejor = mejor, segundos = seg,
    n_config = nrow(f$grilla), metricas_grilla = collect_metrics(res),
    pred = collect_predictions(res, parameters = mejor)
  )
})
names(resultados_ajuste) <- names(familias)

# --- 5. Hiperparámetros elegidos y costo ---------------------------------
tabla_hiper <- bind_rows(lapply(resultados_ajuste, function(r) {
  valores <- r$mejor |> select(-.config)
  tibble(
    modelo = r$nombre,
    hiperparametros = paste(names(valores), signif(unlist(valores), 3), sep = " = ", collapse = "; "),
    configuraciones = r$n_config,
    particiones = nrow(remuestreo),
    minutos_busqueda = round(r$segundos / 60, 1)
  )
}))
print(tabla_hiper)
write_csv(tabla_hiper, "output/tablas/hiperparametros.csv")

grillas <- bind_rows(lapply(resultados_ajuste, function(r) {
  r$metricas_grilla |> filter(.metric == "mn_log_loss") |>
    transmute(modelo = r$nombre, config = .config, log_loss = mean, ee = std_err)
}))
write_csv(grillas, "output/tablas/grillas_log_loss.csv")
