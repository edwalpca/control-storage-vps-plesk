#!/bin/bash
# ====================================================================================================
# Desarrollado por Mauricio Alpizar (modificado por Soporte Nivel 2 / Infraestructura)
# Descripción:
#  Obtiene la lista de suscripciones/dominios del servidor y la información completa de cada uno.
#  Graba el reporte en un archivo de salida en el mismo directorio donde se encuentra el script.
# ====================================================================================================

# Determinar el directorio donde se encuentra el script
script_dir="$(dirname "$(readlink -f "$0")")"

# Definir la ruta absoluta del archivo de salida en el mismo directorio
output="$script_dir/subscription_report.txt"

# (Opcional) Definir PATH, ya que el entorno del cron es limitado
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Capturamos toda la salida (stdout y stderr) en el archivo de log
{
  echo "Reporte de suscripciones - $(date)"

  # Obtener la lista de suscripciones
  subscriptions=$(/usr/local/psa/bin/subscription --list)

  # Iterar sobre cada suscripción
  for subscription in $subscriptions; do
      echo "Procesando: $subscription"
      echo "----- $subscription -----"
      /usr/local/psa/bin/subscription --info "$subscription"
      echo ""
  done

  echo "Reporte generado en $output"
} >> "$output" 2>&1

