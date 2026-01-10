#!/bin/bash
# Test script for enforce-gitops-kubectl hook

HOOK="/home/mriley/.claude/hooks/enforce-gitops-kubectl.py"

test_command() {
  local description="$1"
  local command="$2"
  local expected_exit="$3"

  echo "{\"tool_name\": \"Bash\", \"tool_input\": {\"command\": \"$command\"}}" | \
    uv run "$HOOK" 2>/dev/null

  actual_exit=$?

  if [ $actual_exit -eq $expected_exit ]; then
    echo "✅ PASS: $description"
  else
    echo "❌ FAIL: $description (expected: $expected_exit, got: $actual_exit)"
  fi
}

echo "======================================================================="
echo "Testing kubectl GitOps Hook"
echo "======================================================================="
echo ""

echo "Testing MUTATION commands (should block with exit 2)..."
echo "-----------------------------------------------------------------------"
test_command "Block apply" "kubectl apply -f file.yaml" 2
test_command "Block create" "kubectl create deployment nginx --image=nginx" 2
test_command "Block delete" "kubectl delete pod nginx" 2
test_command "Block scale" "kubectl scale deployment nginx --replicas=5" 2
test_command "Block patch" "kubectl patch deployment nginx -p '{...}'" 2
test_command "Block rollout restart" "kubectl rollout restart deployment/nginx" 2
test_command "Block set image" "kubectl set image deployment/nginx nginx=nginx:1.21" 2
test_command "Block label" "kubectl label pods nginx env=prod" 2
test_command "Block annotate" "kubectl annotate pods nginx key=value" 2
test_command "Block expose" "kubectl expose deployment nginx --port=80" 2
test_command "Block run" "kubectl run nginx --image=nginx" 2
test_command "Block edit" "kubectl edit deployment nginx" 2
test_command "Block replace" "kubectl replace -f deployment.yaml" 2
test_command "Block exec" "kubectl exec nginx -- touch /tmp/file" 2
test_command "Block cp" "kubectl cp file.txt nginx:/tmp/" 2

echo ""
echo "Testing READ-ONLY commands (should allow with exit 0)..."
echo "-----------------------------------------------------------------------"
test_command "Allow get" "kubectl get pods" 0
test_command "Allow describe" "kubectl describe deployment nginx" 0
test_command "Allow logs" "kubectl logs nginx-pod" 0
test_command "Allow top" "kubectl top nodes" 0
test_command "Allow diff" "kubectl diff -f file.yaml" 0
test_command "Allow explain" "kubectl explain deployment.spec" 0
test_command "Allow api-resources" "kubectl api-resources" 0
test_command "Allow cluster-info" "kubectl cluster-info" 0
test_command "Allow rollout status" "kubectl rollout status deployment/nginx" 0
test_command "Allow rollout history" "kubectl rollout history deployment/nginx" 0
test_command "Allow version" "kubectl version" 0
test_command "Allow config view" "kubectl config view" 0
test_command "Allow auth can-i" "kubectl auth can-i create pods" 0

echo ""
echo "Testing DRY-RUN commands (should allow with exit 0)..."
echo "-----------------------------------------------------------------------"
test_command "Allow apply dry-run (client)" "kubectl apply -f file.yaml --dry-run=client" 0
test_command "Allow apply dry-run (server)" "kubectl apply -f file.yaml --dry-run=server" 0
test_command "Allow create dry-run" "kubectl create deployment nginx --image=nginx --dry-run=client" 0
test_command "Allow delete dry-run" "kubectl delete pod nginx --dry-run=server" 0

echo ""
echo "Testing EDGE CASES..."
echo "-----------------------------------------------------------------------"
test_command "Flags before verb (mutation)" "kubectl --namespace=default delete pod nginx" 2
test_command "Flags before verb (read-only)" "kubectl -n default get pods" 0
test_command "Short flags (mutation)" "kubectl -n prod scale deployment api --replicas=3" 2
test_command "Short flags (read-only)" "kubectl -n prod get svc" 0
test_command "Non-kubectl command" "echo kubectl apply -f file.yaml" 0

echo ""
echo "======================================================================="
echo "Test suite complete!"
echo "======================================================================="
