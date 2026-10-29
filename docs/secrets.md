# Secrets

`secrets/secrets.example.yaml` is a placeholder schema, **not a valid SOPS-encrypted file**. This example does not copy ciphertext, SOPS metadata, age recipients, private keys, or actual credentials from any existing installation. Nothing in the sample config decrypts or deploys secrets.

For a real deployment, generate new, appropriately scoped age identities outside the repository, create a private local `.sops.yaml` with the intended public recipients, and encrypt a new `secrets/secrets.yaml` with SOPS. Use sops-nix as a separately pinned flake input, declare only the secrets each target needs, and reference runtime paths such as `/run/secrets/k3s-token` rather than placing secret values in Nix expressions or the Nix store. Provision host identities through an approved secure channel. Test decryption and access controls on a disposable host before deploying.

A shared vault is convenient but is **not** per-agent isolation; prefer scoped identities and distinct encrypted files where workloads have different trust boundaries. Never publish decrypted files or age private keys. Review recipient public keys and encrypted metadata too: they can disclose infrastructure relationships even when values remain encrypted.
