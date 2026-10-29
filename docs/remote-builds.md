# Remote builds: design and rollout

The example models a dedicated x86_64 Linux builder separate from application and hypervisor management. The requesting machine evaluates a derivation, its Nix daemon dispatches compatible builds over SSH, and the target remains responsible for activation. `modules/nixos/remote-builder.nix` is opt-in and disabled for every host. Its address and key path are placeholders. There is no configured shared binary cache or automatic fleet deployment.

The builder account is declared as a trusted Nix user but has no authorized SSH keys by default. Configure and verify restricted access and end-to-end daemon dispatch before enabling client integration. The example is an architectural template, not a claim that every host already uses it.

## Before enabling on a Linux client

1. Build and enroll the builder independently; preserve its actual generated hardware configuration. Set SSH access, verify its host key out of band, and install the pinned host key where the **client Nix daemon** can use it. Do not disable host verification.
2. Provision a dedicated client identity in a root-only location and a restricted SSH account on the builder. Configure any command restrictions and Nix daemon trust deliberately. A trusted Nix user is powerful: forced-command SSH does **not** make Nix daemon access an unprivileged sandbox. Scope access and network exposure accordingly.
3. Set `example.remoteBuilder` to the real private hostname, user and daemon-readable key; confirm supported features against the actual machine. Client daemons must access their own credentials; Home Manager aliases or an interactive user's SSH agent are not sufficient proof.
4. On a disposable client, verify strict-host-key SSH as the actual daemon identity, then build a small uncached x86_64-linux derivation and confirm from builder-side evidence where it ran. Build the intended system closure without activating it, compare to the reviewed revision, then separately authorize activation and verify health. Repeat per host.

The four jobs/eight cores values are illustrative and can oversubscribe CPUs; tune after observing workload and RAM. Confirm required sandbox/KVM features before advertising them. Use signed substitutes and deliberate cache trust.

## Platform boundaries

An x86_64 Linux builder cannot natively build arbitrary aarch64-Darwin outputs. Linux hosts of other architectures need an appropriate native or deliberately configured cross/emulated builder; cross-building is not universally supported. Darwin requires a suitable Darwin builder or local build. This example intentionally does not modify externally managed Determinate Nix settings; configure its daemon through its supported mechanism and verify separately. `nix-darwin` sets `nix.enable = false`.
