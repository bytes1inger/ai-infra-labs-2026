#!/usr/bin/env bash
# scale-gpu-down.sh — Scale GPU nodepool to zero after a lab session
# Usage: ./scripts/scale-gpu-down.sh
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-aiinfra-lab}"
CLUSTER_NAME="${CLUSTER_NAME:-aks-aiinfra-lab}"
NODEPOOL_NAME="${NODEPOOL_NAME:-gpunodepool}"

echo "[scale-gpu-down] Scaling ${NODEPOOL_NAME} to 0 nodes..."
az aks nodepool scale \
  --resource-group "${RESOURCE_GROUP}" \
  --cluster-name "${CLUSTER_NAME}" \
  --name "${NODEPOOL_NAME}" \
  --node-count 0

echo "[scale-gpu-down] Done. GPU nodepool scaled to zero."
