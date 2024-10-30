FOH_QAS=/home/carlos/git/bbr-foh-gke/a-financiera-oh/foh-procesador-qas/credentials/foh-procesador-qas-2b0ee8eb0c2e.json
cat $FOH_QAS | docker login -u _json_key --password-stdin https://gcr.io
docker build -t check-db-cloud-sql-proxy:v1 . 
docker tag check-db-cloud-sql-proxy:v1 gcr.io/foh-procesador-qas/financial/check-db-cloud-sql-proxy:v1
docker push gcr.io/foh-procesador-qas/financial/check-db-cloud-sql-proxy:v1
