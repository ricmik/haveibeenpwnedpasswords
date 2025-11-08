# pwned-password.sh

This small helper checks whether a password appears in the haveibeenpwned PwnedPasswords database using the k-anonymity model.

- The script computes the SHA-1 hash locally and sends only the first 5 hex characters of the hash to the HIBP API. The full password and full hash never leave your machine.
- The script sets the `Add-Padding: true` header to make requests more uniform.

## How to use

Make the script executable:

```zsh
chmod +x pwned-password.sh
```

Prompt for password (recommended):

```zsh
./pwned-password.sh
```

Pipe a password into the script:

```zsh
echo -n "hunter2" | ./pwned-password.sh
```

## Notes
- No API key is required for the PwnedPasswords endpoint.
