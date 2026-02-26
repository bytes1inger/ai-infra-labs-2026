#!/usr/bin/env bash
# teardown-namespace.sh — Delete a lab namespace and all its resources
# Usage: ./scripts/teardown-namespace.sh <namespace>
set -euo pipefail

NAMESPACE="${1:-}"
if [[ -z "${NAMESPACE}" ]]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

echo "[teardown] Deleting namespace ${NAMESPACE}..."
kubectl delete namespace "${NAMESPACE}" --ignore-not-found

echo "[teardown] Done. Namespace ${NAMESPACE} removed."
