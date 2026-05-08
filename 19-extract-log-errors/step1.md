## Tasks
- Fetch logs from Pod `payment-api`.
- Filter for lines containing `error file-not-found`.
- Save the matching lines to `/opt/CKA2026/payment-api/errors.log`.

## Hints
- Create the target directory if it does not exist.
- Use a pipeline to redirect filtered output to the file.
