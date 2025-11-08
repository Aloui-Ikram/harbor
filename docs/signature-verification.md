# Harbor Release Signature Verification

## What is This?

Harbor releases are **cryptographically signed** to prove they're authentic and haven't been tampered with. This guide shows you how to verify them.

## Why Verify?

✅ Confirms the file came from Harbor's official build  
✅ Detects any modifications or tampering  
✅ Protects against malicious downloads  

## Prerequisites

**Install Cosign (v2.0+):**
```bash
# macOS
brew install sigstore/tap/cosign

# Linux
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign

# Verify installation
cosign version
```

## Verification Steps

### 1. Download Files
```bash
# Download installer and signature bundle (example v2.14.0)
wget https://github.com/goharbor/harbor/releases/download/v2.14.0/harbor-offline-installer-v2.14.0.tgz
wget https://github.com/goharbor/harbor/releases/download/v2.14.0/harbor-offline-installer-v2.14.0.tgz.bundle
```

### 2. Verify Signature
```bash
cosign verify-blob \
  --bundle harbor-offline-installer-v2.14.0.tgz.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/goharbor/harbor/.github/workflows/build-package.yml@refs/(heads/main|tags/v.*)$' \
  harbor-offline-installer-v2.14.0.tgz
```

**Expected output:**
```
Verified OK
```

### 3. For Online Installer

Same process, just replace `offline` with `online`:
```bash
wget https://github.com/goharbor/harbor/releases/download/v2.14.0/harbor-online-installer-v2.14.0.tgz
wget https://github.com/goharbor/harbor/releases/download/v2.14.0/harbor-online-installer-v2.14.0.tgz.bundle

cosign verify-blob \
  --bundle harbor-online-installer-v2.14.0.tgz.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/goharbor/harbor/.github/workflows/build-package.yml@refs/(heads/main|tags/v.*)$' \
  harbor-online-installer-v2.14.0.tgz
```

## Testing in my  Fork

```bash
cosign verify-blob \
  --bundle harbor-offline-installer-v2.14.0-build.12.tgz.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/Aloui-Ikram/harbor/.github/workflows/build-package.yml@' \
  harbor-offline-installer-v2.14.0-build.12.tgz
```

## Common Errors

### "certificate identity doesn't match"
**Solution:** Make sure you're using the correct repository name in `--certificate-identity-regexp`

### "unable to find signature"
**Solution:** Ensure the `.bundle` file is in the same directory as the `.tgz` file

### "bad signature"
**Solution:** Re-download both files from official GitHub releases

## What Gets Verified

✅ **File authenticity** - Signed by official Harbor workflow  
✅ **File integrity** - No modifications since signing  
✅ **Build provenance** - Logged in public transparency log  

## Resources

- [Cosign Documentation](https://docs.sigstore.dev/cosign/overview/)
- [Harbor Issue #22367](https://github.com/goharbor/harbor/issues/22367)
- [Keyless Signing Tutorial](https://www.appvia.io/blog/tutorial-keyless-sign-and-verify-your-container-images)

---

**Last Updated:** November 2025  
**Applies to:** Harbor v2.14.0+