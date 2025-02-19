# Use OpenJDK as the base image (Don't ask why)
FROM openjdk:17-jdk-slim

# Install curl, Python, postgresql-client and download Google Cloud SQL Proxy
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    postgresql-client \
    && curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.14.3/cloud-sql-proxy.linux.amd64 \
    && chmod +x cloud-sql-proxy \
    && mv cloud-sql-proxy /usr/local/bin/

# Create a directory to store the JSON key for the service account
RUN mkdir -p /cloudsql
WORKDIR /cloudsql

# Set the environment variable for the service account key (JSON file must be mounted)
ENV GOOGLE_APPLICATION_CREDENTIALS=/cloudsql/foh-base-de-datos-foh-procesador-qas

# Entry script to initialize Cloud SQL Proxy and Execute Test
COPY <<EOF /usr/local/bin/start_proxy.sh
#!/bin/bash
set -x  # Debug mode to show commands

echo "Test started v5 - Debugging enabled"

if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "The JSON credential file is not present in ${GOOGLE_APPLICATION_CREDENTIALS}"
  exit 1
fi

# Start Cloud SQL Proxy in the background
###V1 cloud_sql_proxy -instances=foh-procesador-qas:us-central1:fohct06c=tcp:5432 -ip_address_types=PRIVATE &
## V2
export CSQL_PROXY_INSTANCE_CONNECTION_NAME_0="foh-procesador-qas:us-central1:fohct06c?port=5432"
export CSQL_PROXY_AUTO_IAM_AUTHN=true
cloud-sql-proxy --private-ip &

sleep 10
echo "Cloud SQL Proxy logs:"
#cat /tmp/cloud_sql_proxy.log

echo "Setting up environment variables"
export DB_USER="mpago"
export DB_PASSWORD="C93XHxN5X6UcpgJz"
export DB_NAME="bbr-processor"

echo "Configured variables: DB_USER=${DB_USER}, DB_PASSWORD=${DB_PASSWORD}, DB_NAME=${DB_NAME}"

# Verify database connection
export PGPASSWORD="${DB_PASSWORD}"
CMD="psql -h localhost -p 5432 -U ${DB_USER} -d ${DB_NAME} -c 'SELECT NOW();'"
echo "Executing command: $CMD"
eval $CMD

PGPASSWORD=C93XHxN5X6UcpgJz psql -h localhost -p 5432 -U mpago -d bbr-processor -t -c "SELECT NOW();"

export PGPASSWORD=C93XHxN5X6UcpgJz

# Execute the query and store the result in a variable
RESULT=$(psql -h localhost -p 5432 -U mpago -d bbr-processor -t -A -c "SELECT NOW();" 2>&1)

echo "Query result: ${RESULT}"

# Check if the result is empty
if [ -z "${RESULT}" ]; then
    echo "The query returned no result or failed."
else
    echo "The query returned: ${RESULT}"
fi

echo "End"
EOF

RUN chmod +x /usr/local/bin/start_proxy.sh

CMD ["/usr/local/bin/start_proxy.sh"]
