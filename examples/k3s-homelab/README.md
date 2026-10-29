# Companion Kubernetes repository example

This directory illustrates the structure of a separate Kubernetes configuration repository. Its `k3s/` tree owns application resources; Nix owns the hosts that run k3s. Render the included application with `kubectl kustomize k3s/`. Read `../../docs/k3s.md` before applying anything.

The Longhorn values file is input to a separately version-pinned Helm chart; it is not part of the Kustomize output. The example application exposes a ClusterIP service and can be inspected with an authorized port-forward.
