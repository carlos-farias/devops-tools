FROM openjdk:17-jdk-slim

# Instalamos curl y python, además descargamos el Google Cloud SQL Proxy
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    postgresql-client \
    && curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 \
    && chmod +x cloud_sql_proxy \
    && mv cloud_sql_proxy /usr/local/bin/

# Creamos un directorio para almacenar el JSON de la key de la service account
RUN mkdir -p /cloudsql
WORKDIR /cloudsql

# Añadimos la variable de entorno para la key del service account (archivo json debe ser montado)
ENV GOOGLE_APPLICATION_CREDENTIALS=/cloudsql/foh-base-de-datos-foh-procesador-qas

#RUN echo '{  "type": "service_account", "project_id": "d-irmabo-tesoreria",  "private_key_id": "ce94cf462dcf740f39fc8f14275e88e4436b6429",  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChWVXIHyiz75E2\\nOa0/gDxbGzQYR8c/NnzKVf9mwmbbS8kq76bA5IbciD7lXK4dE0Hyf0LSka3tmTmp\\n...","client_email": "db-sql-sa@d-irmabo-tesoreria.iam.gserviceaccount.com",  "client_id": "108909718819450668423",  "auth_uri": "https://accounts.google.com/o/oauth2/auth",  "token_uri": "https://oauth2.googleapis.com/token","auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/db-sql-sa%40d-irmabo-tesoreria.iam.gserviceaccount.com","universe_domain": "googleapis.com" }' > /cloudsql/service_account.json


# El puerto al cual el Cloud SQL Proxy se conectará
EXPOSE 5432

# Script de entrada para inicializar el Cloud SQL Proxy
COPY <<EOF /usr/local/bin/start_proxy.sh
#!/bin/bash

echo "Prueba iniciada v4 - "

if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "El archivo de credenciales JSON no está presente en ${GOOGLE_APPLICATION_CREDENTIALS}"
  exit 1
fi

# Iniciamos el Cloud SQL Proxy en segundo plano
cloud_sql_proxy -instances=foh-procesador-qas:us-central1:fohct06c=tcp:5432 &

# Esperamos a que el proxy esté listo
sleep 5

echo "CloudSQL Proxy operativo "
DB_USER=mpago
DB_PASSWORD=C93XHxN5X6UcpgJz
DB_NAME=bbr-processor

echo "$DB_PASSWORD - $DB_USER - $DB_NAME"

# Realizamos una consulta a la base de datos para verificar la conexión
export PGPASSWORD=$DB_PASSWORD
psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "SELECT NOW();"

EOF

RUN chmod +x /usr/local/bin/start_proxy.sh

CMD ["/usr/local/bin/start_proxy.sh"]

# Contenido de start_proxy.sh
# =====================================
# #!/bin/bash
#
# if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
#   echo "El archivo de credenciales JSON no está presente en /cloudsql."
#   exit 1
# fi
#
# # Iniciamos el Cloud SQL Proxy en segundo plano
# cloud_sql_proxy -instances=<YOUR_INSTANCE_CONNECTION_NAME>=tcp:5432 &
#
# # Esperamos a que el proxy esté listo
# sleep 5
#
# # Realizamos una consulta a la base de datos para verificar la conexión
# PGPASSWORD=<YOUR_DB_PASSWORD> psql -h localhost -p 5432 -U <YOUR_DB_USER> -d <YOUR_DB_NAME> -c "SELECT NOW();"
#
# # Mantenemos el contenedor activo
# tail -f /dev/null
# =====================================

# Nota: Asegúrate de reemplazar <YOUR_INSTANCE_CONNECTION_NAME>, <YOUR_DB_USER>, <YOUR_DB_PASSWORD>, y <YOUR_DB_NAME> con los valores correspondientes.
