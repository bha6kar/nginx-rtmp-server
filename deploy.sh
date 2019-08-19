export PROJECT_ID="$(gcloud config get-value project -q)"
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone us-central1-b

docker build -t gcr.io/${PROJECT_ID}/nginx-server:v1 .
gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/nginx-server:v1
docker run -d -p 1935:1935 gcr.io/${PROJECT_ID}/nginx-server:v1
gcloud container clusters create nginx-cluster --num-nodes=3
kubectl run nginx-web --image=gcr.io/${PROJECT_ID}/nginx-server:v1 --port 1935
kubectl get pods
kubectl expose deployment nginx-web --type=LoadBalancer --port 1935 --target-port 1935
kubectl get service

gcloud container images delete gcr.io/${PROJECT_ID}/nginx-server:v1

# gcloud container images list-tags gcr.io/${PROJECT_ID}/nginx-server --filter='-tags:*' --format='get(digest)' --limit=unlimited

# gcloud container images delete --quiet gcr.io/${PROJECT_ID}/nginx-server@sha256:78e61f6b8e0dce572f7472589ad2e4317d3c2286bc5469f231bb4561e8012aaf

# gcloud container images delete gcr.io/${PROJECT_ID}/nginx-server:v1
