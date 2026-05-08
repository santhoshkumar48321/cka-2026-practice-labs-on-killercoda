## Tasks
- Edit ConfigMap `web-tls-config` so only TLSv1.3 is allowed.
- Add the `web-service` ClusterIP to `/etc/hosts` as `secure.demo.local`.
- Validate that TLSv1.2 fails and TLSv1.3 succeeds.

## Hints
- Update the `ssl_protocols` directive in the ConfigMap data.
- Use curl with `--tls-max 1.2` and `--tlsv1.3` when testing.
