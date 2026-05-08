## Goal
Install a CNI that enables pod networking and supports NetworkPolicy enforcement.

## Requirements
- Install Calico v3.27.4 from the official manifest URL.
- Ensure `tigera-operator` is running in namespace `tigera-operator`.
- Ensure `calico-node` is running in namespace `calico-system`.
