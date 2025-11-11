#!/usr/bin/env bash
set -euo pipefail

# pwned-password.sh
# Check a password against haveibeenpwned PwnedPasswords using k-anonymity.

password=""

if [ ! -t 0 ]; then
  # read from stdin (e.g., echo -n "pwd" | ./pwned-password.sh)
  IFS= read -r password || true
else
  # Prompt the user (hidden input) using read -s 
  read -r -s -p "Enter password: " password || true
  printf "\n" >&2
fi

if [ -z "$password" ]; then
  echo "No password provided." >&2
  exit 2
fi

# Compute SHA1 hash of the password and uppercase it.
if command -v shasum >/dev/null 2>&1; then
  hash_cmd=$(printf "%s" "$password" | shasum -a 1)
elif command -v sha1sum >/dev/null 2>&1; then
  hash_cmd=$(printf "%s" "$password" | sha1sum)
else
  echo "Neither shasum nor sha1sum is available on PATH." >&2
  exit 3
fi

unset password

sha1=$(printf "%s" "$hash_cmd" | awk '{print $1}' | tr '[:lower:]' '[:upper:]')
prefix=${sha1:0:5}
suffix=${sha1:5}

url="https://api.pwnedpasswords.com/range/${prefix}"

response=$(curl -sS --ssl-reqd --max-time 3 --tlsv1.2 --fail -H "User-Agent: pwned-check/1.0" -H "Add-Padding: true" "$url") || {
  echo "Failed to query API at $url" >&2
  exit 4
}

# Response lines are like: <HASH_SUFFIX>:<COUNT>
# Search for the suffix (case-insensitive to be robust)
count=$(printf "%s" "$response" | awk -F: -v suf="$suffix" 'BEGIN{IGNORECASE=1} $1==suf {print $2}' | tr -d '\r')

if [ -n "$count" ]; then
  echo "The password was found in data breaches: ${count} times."
  exit 0
else
  echo "The password was NOT found in the Pwned Passwords database." >&2
  exit 0
fi
