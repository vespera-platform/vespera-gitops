#!/usr/bin/env bash
set -euo pipefail
export KUBECONFIG="$(mktemp)"
aws eks update-kubeconfig --name vespera --region eu-north-1 --kubeconfig "$KUBECONFIG" >/dev/null

echo "1/4 Argo CD przestaje odtwarzac zasoby"
kubectl -n argocd scale statefulset argocd-application-controller --replicas=0
for a in $(kubectl -n argocd get applications -o name); do
  kubectl -n argocd patch "$a" --type merge -p '{"metadata":{"finalizers":null}}' >/dev/null
done

echo "2/4 usuwam aplikacje (external-dns i kontroler LB jeszcze dzialaja)"
kubectl delete ns vespera-staging monitoring --ignore-not-found --wait=true --timeout=10m

echo "3/4 czekam na zwolnienie NLB i dyskow EBS"
kubectl wait --for=delete svc -n envoy-gateway-system -l gateway.envoyproxy.io/owning-gateway-name=vespera-gateway --timeout=10m 2>/dev/null || true
kubectl wait --for=delete pv --all --timeout=10m 2>/dev/null || true

echo "4/4 czas dla external-dns na usuniecie rekordu"
sleep 90
kubectl get pv,svc -A 2>/dev/null | grep -E "LoadBalancer|pvc-" || echo "czysto"