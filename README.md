# Nix infrastructure example

A deliberately sanitized, educational example of an inventory-driven homelab: NixOS servers, a macOS workstation, shared Home Manager settings, private service patterns, and an opt-in remote Linux builder. It contains no media services, production endpoints, original keys, real credentials, or production hardware identifiers. It is a new example, not a copy of private Git history. It is **not ready to deploy as-is**.

## Layout

- `hosts.nix` — generic platform and role inventory.
- `flake.nix` — maps the inventory to NixOS and nix-darwin configurations, with Home Manager.
- `hosts/*/configuration.nix` — per-host policy and customization.
- `modules/nixos/` — common baseline, role modules, opt-in distributed builder.
- `modules/darwin/` — macOS settings without taking ownership of an external Nix installer.
- `modules/home-manager/` — shared operator environment.
- `docs/remote-builds.md` — trust boundaries, platform limitations and rollout.
- `docs/secrets.md` and `secrets/secrets.example.yaml` — placeholder-only SOPS guidance.

## Architecture

Inventory → flake constructors → common modules and individual hosts → system and Home Manager configurations. The generic roles are a k3s control plane and worker, Forgejo DevOps host, monitoring host, Linux builder, and Darwin workstation. k3s is deliberately disabled until network and secrets are configured. Forgejo and monitoring bind to loopback; no public routing is configured. Production would place services in dedicated VMs or containers, separate from the hypervisor management plane.

## Evaluation, not activation

With Nix and flakes enabled:

```sh
nix flake check --no-build
nix eval --raw .#nixosConfigurations.builder.config.networking.hostName
nix eval --raw .#darwinConfigurations.laptop.config.networking.hostName
nix eval .#nixosConfigurations.devops.config.nix.distributedBuilds
```

For a real host, replace the example filesystem and bootloader with its generated hardware configuration; add a tested boot mode and boot disk, operator SSH public keys, scoped firewall/overlay policy, backups, secrets and service configuration. Explicitly review every setting before building or activating. Host and service names are illustrative, not live inventory. See `docs/remote-builds.md` for the builder's current limits and verification steps.

## Public sharing checklist

This folder has no private Git history. Before publishing any derivative, inspect **all** files including hidden files, lock sources, generated files, links, and history for hostnames, identifiers, private paths, keys, plaintext or encrypted secrets, logs, and personal information. Configure an independent secret scanner and human review; passing a scan does not prove publication safety. Never initialize a repository by copying the original `.git` directory.
