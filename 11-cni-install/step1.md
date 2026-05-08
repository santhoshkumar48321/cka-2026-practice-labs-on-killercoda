## Tasks
- Install Calico (v3.27.4) using the provided Tigera Operator manifest.
- Wait for the tigera-operator deployment and calico-node daemonset to appear.

## Hints
- Use `kubectl apply -f` with the manifest URL.
- Check both `tigera-operator` and `calico-system` namespaces.
