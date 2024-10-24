FROM python:3.11-slim

# Instalación de dependencias necesarias
RUN pip install psycopg2-binary

# Creación del script Python que hará la query
COPY <<EOF /app/query_db.py
import psycopg2
import os

def main():
    try:
        # Parámetros de conexión desde variables de entorno
        db_user = os.getenv('DB_USER')
        db_password = os.getenv('DB_PASSWORD')
        db_name = os.getenv('DB_NAME')
        db_host = os.getenv('DB_HOST', '127.0.0.1')
        db_port = os.getenv('DB_PORT', '5432')

        # Conexión a la base de datos
        connection = psycopg2.connect(
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port,
            dbname=db_name
        )
        cursor = connection.cursor()
        cursor.execute("SELECT 1;")
        result = cursor.fetchone()
        print("Resultado de la query:", result)

        cursor.close()
        connection.close()
    except psycopg2.Error as err:
        print(f"Error: {err}")

if __name__ == "__main__":
    main()
EOF

WORKDIR /app

# Comando por defecto para ejecutar el script Python
CMD ["python", "query_db.py"]
