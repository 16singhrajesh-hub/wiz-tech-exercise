set -e

echo "=== Wiz Exercise Cleanup script   =="
echo "=== This will remove all resources created during the exercise. ==="
echo "=== Please make sure to run this script after completing the exercise. ==="
read -p "Do you want to proceed? (y/n) " -confirm
if [[ "$REPLY" != "y" ]]; then
    echo "Cleanup aborted."
    exit 0
fi

source .env
echo "Starting gclound Project"

gcloud config set procet $GCP_PROJECT_ID


echo "Deleting GKE cluster"
kubectl delete namespace wiz-app --ignore-not-found=true


# Run Terraform Destroy
echo "Running Terraform Destroy"
cd terraform/environments/prod
terraform destroy -auto-approve


# Delete Cloud Storage
echo "Deleting Cloud Storage"
BACKUP_BUCKET="wiz-mongodb-backups-$GCP_PROJECT_ID"
AUDIT_BUCKET="wiz-audit-logs-$GCP_PROJECT_ID"

gsutil -m rm -r gs://$BACKUP_BUCKET 2>/dev/null || echo "Backup bucket not found, skipping."
gsutil -m rm -r gs://$AUDIT_BUCKET 2>/dev/null || echo "Audit bucket not found, skipping."

#Delete Artifact Registery Repository
echo " Deleting Artifact Registry Repository"
REPO_NAME="wiz-app-repo"
gcloud artifacts repositories delete $REPO_NAME --location=us-west1 --quiet || echo "Artifact Registry repository not found, skipping."  

