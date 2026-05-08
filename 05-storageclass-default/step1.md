## Tasks
- Create a StorageClass named `local-storage`.
- Set the provisioner to `rancher.io/local-path`.
- Set `volumeBindingMode` to `WaitForFirstConsumer`.
- Mark the StorageClass as the default for the cluster.

## Hints
- Use the default-class annotation on the StorageClass metadata.
- StorageClasses are cluster-scoped resources.
