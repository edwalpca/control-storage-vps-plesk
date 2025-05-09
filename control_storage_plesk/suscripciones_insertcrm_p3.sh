#!/bin/bash
# ====================================================================================================
# Desarrollado por Mauricio Alpizar (modificado por Soporte Nivel 2 / Infraestructura)
# Descripción:
#  Realiza la inserción de datos en el CRM en función del contenido del archivo llamado "disk_usage.csv".
#  Para mapear aquellos clientes con sobreutilización de espacio en disco.
#  Lista de Modificaciones:
#  Modificado 08 Mayo, 2025 por ealpizar para guardar el estado del dominio en db
# ====================================================================================================

# Determinar el directorio donde se encuentra el script
script_dir="$(dirname "$(readlink -f "$0")")"

# Archivo CSV con los datos (ruta absoluta)
input_file="$script_dir/disk_usage.csv"

# Verificar si el archivo existe
if [[ ! -f "$input_file" ]]; then
    echo "Error: El archivo $input_file no existe."
    exit 1
fi

# (Opcional) Definir PATH en caso de que el entorno tenga variables limitadas
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Configuración de MySQL
DB_HOST=	""         # Cambia si MySQL está en otro servidor
DB_USER=	""          # Usuario de MySQL
DB_PASS=	""   # Contraseña de MySQL
DB_NAME=	""       # Nombre de la base de datos
TABLE_NAME=	""

## COLOCAR EL NOMBRE DEL SERVER, EJEMPLO: SERVER.EMPRESA.COM
SERVER="SERVER.EMPRESA.COM"

# Comando para ELIMINAR el contenido en la base de datos CRM del SERVER FUENTE
SQL_TRUNCATE="DELETE FROM $TABLE_NAME WHERE servidor = '$SERVER';"
# Ejecutar el comando en la base de datos CRM
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$SQL_TRUNCATE"

# Obtener la fecha y hora actual en formato 'YYYY-MM-DD HH:MM:SS'
current_datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Insertar datos en MySQL
echo "Insertando datos en MySQL..."
while IFS=, read -r subscription limit_gb used_gb Estado; do
    # Ignorar la cabecera del CSV
    if [[ "$subscription" != "Suscripción" ]]; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e \
        "INSERT INTO $TABLE_NAME (dominio, disk_limit_gb, disk_used_gb, servidor, fecha_actualizacion,estado) VALUES ('$subscription', $limit_gb, $used_gb, '$SERVER', '$current_datetime', '$Estado' );"
    fi
done < "$input_file"

echo "Datos insertados en MySQL correctamente."

# Vaciar el contenido de los archivos generados
> "$script_dir/disk_usage.csv"
> "$script_dir/subscription_report.txt"

echo "Archivos disk_usage.csv y subscription_report.txt han sido vaciados."
