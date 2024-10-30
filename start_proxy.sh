#!/bin/bash

        db_user = os.getenv('DB_USER')
        db_password = os.getenv('DB_PASSWORD')
        db_name = os.getenv('DB_NAME')
        db_host = os.getenv('DB_HOST', 'localhost')
        db_port = os.getenv('DB_PORT', '5432')
        
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "El archivo de credenciales JSON no está presente en /cloudsql."
  exit 1
fi

# Iniciamos el Cloud SQL Proxy en segundo plano
cloud_sql_proxy -instances=foh-procesador-qas:us-central1:fohct06c=tcp:5432 &

# Esperamos a que el proxy esté listo
sleep 5

# Realizamos una consulta a la base de datos para verificar la conexión
PGPASSWORD=DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "SELECT NOW();"

# Mantenemos el contenedor activo
tail -f /dev/null