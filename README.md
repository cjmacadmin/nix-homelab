# Nix Homelab

An inventory-driven infrastructure configuration for NixOS and macOS, with a k3s cluster, a dedicated Nix build machine, development services, monitoring, Home Manager, and a separate Kubernetes application layer. Hostnames, accounts, addresses, and secret values are intended to be customized for the environment where the configuration is deployed.

## Architecture

```text
                       reviewed configuration changes
                                    |
                        Nix infrastructure repository
                                    |
             hosts.nix -> flake.nix -> NixOS / nix-darwin modules
                                    |
         +--------------------------+-------------------------+
         |                          |                         |
    build machine            k3s node fleet             service VMs + Mac
    x86_64-linux           control + workers          Forgejo, monitoring,
    Nix daemon             k3s + storage tools        Home Manager
         |                          |
         +-- compatible builds      +-- Kubernetes API
                 via SSH                       |
                                    Kubernetes application repository
                                    namespaces, manifests, Helm values
```

Nix evaluates a host's complete system configuration from a shared inventory and modules. NixOS or nix-darwin activates that result on the target. Home Manager contributes the operator's shell, tools, and Git configuration. The separate Kubernetes repository manages cluster resources after the operating systems and cluster are ready. Service management and application workloads remain separate from the hypervisor management plane.

## Repository hierarchy

```text
flake.nix, flake.lock       Inputs and host constructors, pinned revisions
hosts.nix                   NixOS and Darwin inventory
hosts/                      Host-specific system settings
  builder/                  Build capacity and Nix daemon access
  control/                  k3s control plane
  worker*/                  Shared worker definition and worker instances
  devops/                   Forgejo
  monitoring/               Uptime Kuma
  laptop/                   macOS settings
modules/
  nixos/common.nix          User, SSH, firewall, Tailscale and base packages
  nixos/roles.nix           Cluster management tools selected by role
  nixos/longhorn.nix        iSCSI and NFS host prerequisites
  nixos/remote-builder.nix  Opt-in client-side distributed build settings
  darwin/common.nix         macOS base and externally managed Nix daemon
  home-manager/operator.nix Shared operator tools and shell configuration
secrets/                    Example SOPS secret schema
docs/                       Setup, trust boundaries, and integration guides
examples/k3s-homelab/       Companion Kubernetes repository layout and manifests
```

The flake maps `hosts.nix` into `nixosConfigurations` and `darwinConfigurations`. Each constructor imports a shared baseline, the matching `hosts/<name>/configuration.nix`, and Home Manager. Nix's module system merges the resulting options into a single host configuration. The `role` inventory field selects shared packages and storage prerequisites; services and host names are defined in the host files. Worker instances import the same worker configuration and get their unique host name from the inventory.

## Fleet and services

| Host | Purpose | Main configuration |
| --- | --- | --- |
| `builder` | Dedicated x86_64 Linux Nix build machine | Four build jobs, eight cores per job, daily garbage collection, remote builder account |
| `control` | k3s control plane | Cluster initialization; tainted for critical add-ons; built-in Traefik and ServiceLB disabled |
| `worker`, `worker-2`, `worker-3` | k3s workers | Shared agent configuration and worker node label |
| `devops` | Self-hosted source control | Forgejo with SQLite and a loopback HTTP listener |
| `monitoring` | Service health checks | Uptime Kuma with a loopback listener |
| `laptop` | macOS administration | nix-darwin and shared Home Manager profile |

The server examples enable the QEMU guest agent. The common Linux module enables Tailscale and key-based OpenSSH, creates `operator`, and keeps the firewall enabled. Provision authorized keys, overlay access and a scoped firewall policy before connecting. Forgejo and monitoring require a deliberately configured private access path and persistent backups.

## k3s and the application repository

The Nix repository owns the node operating systems, k3s server/agent services, host packages and Longhorn host prerequisites. A separate repository owns namespaces, workload manifests, Helm values, storage resources and ingress. A renderable example of that second repository lives in `examples/k3s-homelab/`.

The control plane and three workers use the same runtime token file; the worker server URL, token, network policy, hardware and storage must be supplied for a particular deployment. Longhorn's iSCSI tools and host directory are configured by Nix; the Longhorn Kubernetes chart is an independently managed cluster installation. Registry addressing crosses the boundary too: Kubernetes runs a registry service while each k3s node's container runtime needs a reachable, trusted registry endpoint.

See **[docs/k3s.md](docs/k3s.md)** for bootstrap order, network and storage planning, workload repository examples, deployment verification and the registry boundary.

## Remote Nix builds

The builder provides Linux build capacity over SSH. `example.remoteBuilder` is an opt-in NixOS client module: configure the private builder address, the Nix daemon's SSH identity, verified host keys, and supported system features before enabling it. Clients evaluate and request builds; the target remains responsible for activation. The `nixremote` account is trusted by the Nix daemon, which is a powerful privilege even if SSH is restricted. The x86_64 Linux builder handles compatible Linux derivations; Darwin and other architectures require compatible builders or a separately tested cross-build strategy.

See **[docs/remote-builds.md](docs/remote-builds.md)** for setup, rollout, and verification.

## Secrets and identity

`secrets/secrets.example.yaml` documents the shape of deployment secrets. Create your own age identities and SOPS configuration, encrypt your own secret file, and deploy values to runtime paths through an appropriately scoped secrets mechanism. Keep private keys and plaintext out of Nix expressions and the Nix store. See **[docs/secrets.md](docs/secrets.md)**.

## Bring-up workflow

1. Select or add an inventory entry and generate the actual host hardware configuration. Replace the illustrative filesystem and bootloader settings in `modules/nixos/common.nix` with host-specific imports, matching firmware mode and boot disk.
2. Provision the operator's SSH public key and verify recovery access. Set host-specific network names, overlay configuration and a restricted firewall policy.
3. Provision required SOPS identities and runtime secrets; set the k3s API address and token path consistently across cluster nodes.
4. Evaluate the configuration, build the selected closure, review changes, and activate on a test host. For a cluster, bring up the control plane first, then workers, verify node readiness, and install storage and application resources in dependency order.
5. Configure and verify the remote builder on one client before enabling it elsewhere. Roll out hosts individually and verify services and recovery after each activation.

```sh
nix flake check --no-build --all-systems
nix eval --raw .#nixosConfigurations.control.config.networking.hostName
nix eval --raw .#darwinConfigurations.laptop.system.drvPath
nix build .#nixosConfigurations.control.config.system.build.toplevel --no-link
kubectl kustomize examples/k3s-homelab/k3s
```

A build requires a compatible Linux builder or remote build configuration. Build and evaluation do not activate a system, validate real hardware, authenticate a host, install Kubernetes charts, or prove application health. Review the deployment-specific settings and test recovery before activation.
