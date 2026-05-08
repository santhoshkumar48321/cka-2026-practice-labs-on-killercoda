## Tasks
- Add the official Argo CD Helm repo named `argocd-repo`.
- Render chart `argocd-repo/argo-cd` version **7.6.8** into namespace `gitops`.
- Ensure CRDs are not included in the rendered output.
- Save the manifest to `/home/candidate/argocd-manifest.yaml`.

## Hints
- Use `helm repo add` and `helm repo update` to register the repo.
- Use `helm template` with `--skip-crds` (or an equivalent values flag).
