# 🔐 SSH Key for Git Commit Signing

## Public Key (Add to GitHub)

Copy this entire line and paste it into GitHub:
→ Settings → SSH and GPG keys → New SSH key → Key type: "Signing Key"

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpbNpEpHnEnny2NDNg8+YqxKiwacf6+ZPehcKxPkd7r adrianssenfuma@gmail.com

## Key Details
- Type: ssh-ed25519
- Fingerprint: SHA256:7WF4UyJG5gK6U1HjzA+kU1+LaMJ+4zdyFd6Wl9d/2Sc
- Email: adrianssenfuma@gmail.com

## How to Add to GitHub

1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Set "Key type" to **Signing Key** (NOT Authentication Key)
4. Paste the public key above
5. Title: "Melina Bakes Commit Signing"
6. Click "Add SSH key"

## After Adding to GitHub

Run these commands in your local repo to push:

```bash
cd /path/to/melina_bakes

# Add the key to your SSH agent
 eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_melina_bakes

# Push the signed commit
git push origin main
```

## Git Config Already Set

The repo already has these configs set:
- user.signingkey = ~/.ssh/id_ed25519_melina_bakes
- gpg.format = ssh
- commit.gpgsign = true

## Commit Status

✅ Commit `8a6ec0d` is signed with SSH and verified locally.
It will show as "Verified" on GitHub once you add the key above.
