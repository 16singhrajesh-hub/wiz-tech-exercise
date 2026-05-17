set -e

echo "=== Wiz Exercise Setup script   ==="


if [ -f .env ]; then
    echo "Loading environment variables from .env file"
    source .env
else
    echo "Error: .env file not found. Please create a .env file with the required environment variables."
    exit 1
fi

source .env
echo "Starting gclound Project"

echo "Project ID: $GCP_PROJECT_ID"
echo "Region: $GCP_REGION"
echo "Zone: $GCP_ZONE"

echo " "

# Set gcloud Project

gcloud config set project $GCP_PROJECT_ID

gcloud config set compute/region $GCP_REGION

gcloud config set compute/zone $GCP_ZONE

# Enable Require APIS

gcloud services enable container.googleapis.com \
    artifactregistry.googleapis.com \
    compute.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudbuild.googleapis.com \
    cloudlogging.googleapis.com \
    cloudmonitoring.googleapis.com \
    cloudtrace.googleapis.com \
    clouddebugger.googleapis.com \
    storage-api.googleapis.com \


    echo "Setup Complete"

    echo "Next Steps:"

    echo "1. cd /terrform/environments/prod"
    echo "2. cp terraform.tfvars.example terraform.tfvars"
    echo "3. edit terraform.tfvars to set the required variables." 
    echo "4. Run terraform init"
    echo "5. Run terraform Plan"
    echo "6. Run terraform apply -auto-approve"   
