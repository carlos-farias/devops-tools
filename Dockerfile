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
ENV GOOGLE_APPLICATION_CREDENTIALS=/cloudsql/service_account.json
COPY <<EOF /cloudsql/service_account.json
{
    "type": "service_account",
    "project_id": "d-irmabo-tesoreria",
    "private_key_id": "ce94cf462dcf740f39fc8f14275e88e4436b6429",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChWVXIHyiz75E2\nOa0/gDxbGzQYR8c/NnzKVf9mwmbbS8kq76bA5IbciD7lXK4dE0Hyf0LSka3tmTmp\n+5JXOqfB8XknsNt3zZ/VG92qzZKM0zs2s99p+XGCND619QIPVH6s+e7fvCirFGya\nETreqyN9PnBwCuErRp44sk7fLiKsmfjMLaFIOMF+gZz1hy3ABUWaDUu59egN47K8\nIg0GKJiuml1e4B9a4jn4SN+KXYaCC5tQNSWOQIe3ewNc9tiXUlBFQZciyEwU8SVj\nw2FXHNydTsg6q8ttCGwdAYDpPlESSJAdnypC604PnOMjOKihu8YCkcrkLaxHvB7u\n2uMfry8zAgMBAAECggEASbfeWJPb7fI7/3F0tXmqmdmhAKLy5u/HLk8CZPnXMsS6\ngdKC9siy0VmymuqwZnpg/CGm7zw+IjuKvB5D63TSJutj9n14mJErQJv9uEc6ePsd\np82g+vNMKDgkms/5g/WP9wouWKzIS/oF8JKEui2pBlUb3CUsYbBfI/pbzN5wWzk4\nNhJdKCcC5hNQXayHhlZookHNNRbXp6cS1QXrrEZrirSQta6dmzYHXXrr8n2wZCcH\nl0v5yN9UUqEaPCIqjz/iEgwb6WI3uGz+VDKb6fWY6KuE5drnpo3Iv/xbOIOFhbyt\nDPYX2D0gtbvqt3gL6/HCc4FvTdRJft3Jywa71bUkeQKBgQDTbHg8kYM+UJisNAJ3\nQBYcRoUnN1LZrR8+rPHvWDqWbmjUBd99O/nCI8GUGC0CXDS2nZXLnYtZb56BCIQY\nrvxvyB+lp7VheAHMSp/PTWKFShqNKutNlMo6IXkC/z5Jk84v+j7yjSRV0FvPZLrJ\nFOdfpmdPdo2gbD/bcT2trv5sfQKBgQDDXhipHU1yT25V8ubTfhRcYyGNYV6/SkjJ\nwmxkn0Qy2qHU6B6fa6knTlCVEkzxzlkWqJ+HuXwrqAX7+KOy1xqxqdHXt3eNehs+\nYQ77bHz9j4sUvTdKzL+kTQkPApLkw3IeU56w5/JGFWg/V/nJmEnx0YbnmpC0oh2F\nJyxhk/DJbwKBgGDTZmVmxtJ9Gs6SqyZuBTJB4a1KGvlx3cNYdRyGLZ7DReMEJYw3\nMXUF5xupzsMr80BG/1lW94CoK9EwUz7ytM2Eu2mkWt8elMQ40OOhryMYAvzv0P+g\nytTAi6khuCb+OAmk87slhKSAXeunWBvLJQObM+kihE4aBUy8meC3KfIJAoGBALKX\nIMnvTG2zaLRPAGzS8z/lKrW4Dcml2VX+UeHFqa0nKQqcSeoHm7CfqZAsE4Rz0gKh\nkHuctoKd7SKCDvqcIf3ItFeSkkoVFjR2uyBg8v1DK6uAsLvC4WkLNr2u56MRew93\n9zfWQCWKyiolfOSpPuc8Vyr+o0tMatnejnaAq3snAoGAPuHvHKfXMvUR1Ea+ZwKg\nbtTGn0aucBHmP6sZ4x6QFm7npdfbtUuxi4bWLGmXPFnA5YjwQ5i9lNA+/nth2IQP\nomSINLODe7DF0lBjCiNS9YhPhEcp6FGPQJYo2Bk9zTSvVneb6zVt8Rf/WeA4Wcg1\nWA5dRHNnBwXqiUe8s4TYnFc=\n-----END PRIVATE KEY-----\n",
    "client_email": "db-sql-sa@d-irmabo-tesoreria.iam.gserviceaccount.com",
    "client_id": "108909718819450668423",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/db-sql-sa%40d-irmabo-tesoreria.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
}
EOF

# El puerto al cual el Cloud SQL Proxy se conectará
EXPOSE 5432

# Script de entrada para inicializar el Cloud SQL Proxy
COPY start_proxy.sh /usr/local/bin/start_proxy.sh
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
