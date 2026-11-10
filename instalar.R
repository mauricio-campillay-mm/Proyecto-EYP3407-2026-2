# instalar.R — instala las versiones exactas de los paquetes de renv.lock
#
# Ejecutar una vez, desde la raíz del proyecto:
#   Rscript --vanilla instalar.R
#
# renv crea una biblioteca propia del proyecto (renv/library), separada de los
# paquetes que el equipo tenga instalados, y descarga cada paquete en la versión
# registrada. El repositorio del lockfile está fijado al 6 de noviembre de 2026,
# por lo que en Windows y Linux se instalan binarios sin compilar (~2 minutos).
# Requisitos y problemas frecuentes: README.md.

source("renv/activate.R")
renv::restore(prompt = FALSE)
message("Instalación terminada. Ahora ejecute: Rscript --vanilla analisis.R")
