set -e

echo "Wiz Tech Deployment Script"

source .env
echo "Starting gclound Project"
echo "Build Docker Image"


cd app

docker build --build-arg YOUR_NAME=$YOUR_NAME -t wiz-todo-app:latest .

echo "Configuring Docker for artifact registry"
gcloud auth configure-docker ${gcp-region}-docker.pkg.dev

echo "Tagging Docker Image"
docker tag wiz-todo-app:latest ${gcp-region}-docker.pkg.dev/${GCP_PROJECT_ID}/wiz-apps/wiz-todo-app:latest

docker push ${gcp-region}-docker.pkg.dev/${GCP_PROJECT_ID}/wiz-apps/wiz-todo-app:latest

echo "Getting GKE credentials"
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region ${gcp-region}-a --project ${GCP_PROJECT_ID}

echo "Get MongoDB Private IP"
MONGO_IP=$(gcloud compute instances describe ${MONGO_INSTANCE_NAME} --zone ${gcp-zone}-a --format='get(networkInterfaces[0].networkIP)')

echo "MongoBD Private IP: $MONGO_IP"

echo "Update Kubernetes Manifest with MongoDB IP"

cd k8s

sed -i.bak "s/GCP_PROJECT_ID/${GCP_PROJECT_ID}/g" deployment.yaml
sed -i.bak "s/gcp-region/${gcp-region}/g" deployment.yaml
sed -i.bak "s/MONGODB_PRIVATE_IP/${MONGO_IP}/g" deployment.yaml
sed -i.bak "s/REPLACE_WITH_PASSWORD/$MONGO_PASSWORD/g" deployment.yaml

echo "Deploying to GKE"

kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml
kubectl apply -f serviceaccount.yaml
kubectl apply -f clusterrolebinding.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

echo "Waiting for deployment to be ready..."

kubectl rollout status deployment/todo-app -n wiz-app   --timeout=5m    

echo ""
echo "Deployment Complete!"
echo "Application Status"

kubectl get pods -n wiz-app

kubectl get svc -n wiz-app

kubectl get ingress -n wiz-app

echo "Application URL (wait 5 mins for load balancer)"

kubctl get ingress wiz-ingress -n wiz-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

rm *.bak
