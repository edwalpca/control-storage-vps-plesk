#!/bin/bash
# ====================================================================================================
# Desarrollado por Mauricio Alpizar (modificado por Soporte Nivel 2 / Infraestructura)
# Descripción:
#  Analiza todo el contenido del archivo subscription_report.txt, y por medio del comando AWK
#  obtiene aquellos dominios o suscripciones que superan el límite asignado.
#  Modificaciones:
#  08 Mayo, 2025 para obtener el estado de la suscripcion o dominio en el plesk
# ====================================================================================================

# Determinar el directorio donde se encuentra el script
script_dir="$(dirname "$(readlink -f "$0")")"

# Archivo de entrada con la información de las suscripciones
input_file="$script_dir/subscription_report.txt"

# Archivo de salida en formato CSV
output_file="$script_dir/disk_usage.csv"

# Encabezado del archivo CSV
echo "Suscripción,Límite de Espacio (GB),Espacio Usado (GB),Estado" > "$output_file"

# Procesar el archivo con AWK
awk -v out_file="$output_file" '
{
    # Elimina espacios y tabulaciones en exceso
    gsub(/^[ \t]+|[ \t]+$/, "", $0);
}
/^Domain name:/ { name = $3 }
/^Disk space limit:/ {
    match($0, /([0-9.]+) GB/, arr);
    limit_gb = arr[1] + 0;
}
/^Size:/ {
    match($0, /([0-9.]+) GB/, arr);
    used_gb = arr[1] + 0;
}
/^Domain status:/ {
    status_raw = substr($0, index($0, ":") + 1);
    gsub(/^[ \t]+/, "", status_raw);
    if (status_raw == "OK") {
        status = "OK";
    } else {
        status = "SUSPENDIDO";
    }
}
/^$/ {
    if (used_gb > limit_gb && name != "") {
        print name "," limit_gb "," used_gb "," status >> out_file;
    }
    name = ""; limit_gb = 0; used_gb = 0; status = "";
}
END {
    # Por si el archivo no termina con línea en blanco
    if (used_gb > limit_gb && name != "") {
        print name "," limit_gb "," used_gb "," status >> out_file;
    }
}' "$input_file"

echo "El archivo CSV ha sido generado: $output_file"
