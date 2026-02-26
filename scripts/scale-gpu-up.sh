#!/usr/bin/env bash
# scale-gpu-up.sh — Scale GPU nodepool up before a lab session
# Usage: ./scripts/scale-gpu-up.sh [node-count]
set -euo pipefail

NODE_COUNT="${1:-1}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-aiinfra-lab}"
CLUSTER_NAME="${CLUSTER_NAME:-aks-aiinfra-lab}"
NODEPOOL_NAME="${NODEPOOL_NAME:-gpunodepool}"

echo "[scale-gpu-up] Scaling ${NODEPOOL_NAME} to ${NODE_COUNT} node(s)..."
az aks nodepool scale \
  --resource-group "${RESOURCE_GROUP}" \
  --cluster-name "${CLUSTER_NAME}" \
  --name "${NODEPOOL_NAME}" \
  --node-count "${NODE_COUNT}"

echo "[scale-gpu-up] Done. GPU nodepool is up with ${NODE_COUNT} node(s)."
