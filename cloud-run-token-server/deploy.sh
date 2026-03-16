#!/bin/bash
# Deploy Monti Token Server to Cloud Run
# Usage: ./deploy.sh [PROJECT_ID] [REGION]

set -e

PROJECT_ID="${1:-edamame-uk}"
REGION="${2:-us-central1}"
SERVICE_NAME="monti-token-server"

echo "Deploying $SERVICE_NAME to $PROJECT_ID ($REGION)..."

# Deploy directly from source (no Docker build needed locally)
gcloud run deploy "$SERVICE_NAME" \
  --source . \
  --project "$PROJECT_ID" \
  --region "$REGION" \
  --allow-unauthenticated \
  --memory 256Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 3 \
  --timeout 30 \
  --set-env-vars "PORT=8080"

# Get the service URL
URL=$(gcloud run services describe "$SERVICE_NAME" \
  --project "$PROJECT_ID" \
  --region "$REGION" \
  --format "value(status.url)")

echo ""
echo "Deployed! Service URL: $URL"
echo "Token endpoint: $URL/token"
echo "Health check:   $URL/health"
echo ""
echo "Add to Flutter build:"
echo "  --dart-define=TOKEN_SERVER_URL=$URL"
