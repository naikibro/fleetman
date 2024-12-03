#!/bin/sh

# ANSI escape codes for colors
GRAY="\033[90m"      # For "unchanged"
GREEN="\033[32m"     # For "created"
BLUE="\033[34m"      # For "configured"
RESET="\033[0m"      # Reset to default

# Namespace
NAMESPACE="fleetman"

# Output file
REPORT_FILE="deployment_report.md"
echo "# Deployment Report" > $REPORT_FILE
echo "Date: $(date)" >> $REPORT_FILE
echo >> $REPORT_FILE

# Check if namespace exists
kubectl get namespace $NAMESPACE >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "----- CREATING NAMESPACE FLEETMAN -----"
  echo "Creating namespace $NAMESPACE..."
  kubectl create namespace $NAMESPACE
  echo "- Namespace **$NAMESPACE**: Created" >> $REPORT_FILE
else
  echo "----- USING NAMESPACE FLEETMAN -----"
  echo "Namespace $NAMESPACE already exists."
  echo "- Namespace **$NAMESPACE**: Already exists" >> $REPORT_FILE
fi

# Function to apply YAML and format output
apply_with_color() {
  OUTPUT=$(kubectl apply -f $1 -n $NAMESPACE)
  STATUS=""

  if echo "$OUTPUT" | grep -q "unchanged"; then
    echo -e "${GRAY}${OUTPUT}${RESET}"
    STATUS="Unchanged"
  elif echo "$OUTPUT" | grep -q "created"; then
    echo -e "${GREEN}${OUTPUT}${RESET}"
    STATUS="Created"
  elif echo "$OUTPUT" | grep -q "configured"; then
    echo -e "${BLUE}${OUTPUT}${RESET}"
    STATUS="Configured"
  else
    STATUS="Error"
    echo "$OUTPUT"
  fi

  # Log to report
  RESOURCE=$(echo "$1" | sed 's/.*\///;s/.yaml//')
  echo "| $RESOURCE | $STATUS |" >> $REPORT_FILE
}

# Header for report
echo "## Deployment Status" >> $REPORT_FILE
echo "| Resource | Status |" >> $REPORT_FILE
echo "|----------|--------|" >> $REPORT_FILE

echo "\n"
echo "----- DEPLOYING SERVICES -----"
echo "\n"
# Apply YAML files
echo "Deploying Persistent Volume Claim..."
apply_with_color fleetman-mongodb-pvc.yaml

echo "Deploying MongoDB..."
apply_with_color fleetman-mongodb-deployment.yaml
apply_with_color fleetman-mongodb-service.yaml

echo "Deploying Position Simulator..."
apply_with_color fleetman-position-simulator-deployment.yaml
apply_with_color fleetman-position-simulator-service.yaml

echo "Deploying Queue Service..."
apply_with_color fleetman-queue-deployment.yaml
apply_with_color fleetman-queue-service.yaml

echo "Deploying API Gateway..."
apply_with_color fleetman-api-gateway-deployment.yaml
apply_with_color fleetman-api-gateway-service.yaml

echo "Deploying Web Application..."
apply_with_color fleetman-webapp-deployment.yaml
apply_with_color fleetman-webapp-service.yaml

# Verify deployments
echo "\n"
echo "----- DEPLOYMENT : HEALTHCHECK -----"
echo "\n"
echo "Waiting for all pods to become ready..."
kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=300s

# Display and log status
echo "\n"
echo "----- DEPLOYMENT : DONE  -----"
echo "\n"
echo "Deployment complete"
echo "## Resource Status" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
kubectl get all -n $NAMESPACE >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE

kubectl get all -n $NAMESPACE

# Final message
echo "Deployment report saved to $REPORT_FILE"