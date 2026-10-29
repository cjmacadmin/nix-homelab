# k3s cluster and Kubernetes repository

## Responsibility boundary

The Nix flake defines the machines and the cluster runtime: hostname, OS, operator access, Tailscale, k3s, cluster tools and Longhorn host dependencies. The separate Kubernetes repository defines the workloads running on those machines. Keeping these layers independent lets an OS generation change without silently changing cluster applications, and lets application changes be reviewed without rebuilding a host.

The example fleet contains a single control plane and three workers. A single control plane is not highly available. The control-plane configuration initializes embedded etcd, applies a `CriticalAddonsOnly=true:NoExecute` taint, and disables the bundled Traefik and ServiceLB components. Each worker joins the API endpoint and applies a worker label. Replace `control.example.invalid` with a real, reachable private endpoint and configure certificates/SANs for the chosen name. Ensure the cluster's pod and service CIDRs do not overlap the LAN or overlay networks.

## Prepare the machines

1. Import each machine's generated hardware configuration and configure the real bootloader, root filesystem, network and host name. Establish console recovery and verified SSH access. The sample operator has no authorized keys until you supply them.
2. Provide a common cluster token at `/run/secrets/k3s-token`, accessible to the k3s service. Use per-host SOPS identities and sops-nix or another runtime secret provisioner; `secrets/secrets.example.yaml` is a schema, not an encrypted secret. Do not commit tokens or place them in the Nix store.
3. Create a deliberate private network policy among cluster nodes. k3s control-plane API, kubelet, overlay networking, storage traffic and any chosen ingress/controller need connectivity appropriate to the installed k3s and Longhorn versions. Scope rules to trusted peers or interfaces. This repository does not open cluster ports automatically; a running firewall without suitable rules will prevent nodes and storage from communicating. Do not expose the API or storage ports broadly to untrusted networks.
4. Apply the reviewed NixOS configuration to the control plane first; inspect `systemctl status k3s`, verify the API certificate and take a protected copy of the kubeconfig for the authorized administrator. The default control-plane kubeconfig is sensitive.
5. Configure and roll out the workers one at a time. Confirm the actual API endpoint and node names, then check:

```sh
kubectl get nodes -o wide
kubectl get pods -A
kubectl describe node control
```

Node readiness and taints are cluster observations, not consequences of evaluation alone. Use the chosen CNI's diagnostics if the API is available but pod networking fails.

## Storage

`modules/nixos/longhorn.nix` enables open-iscsi and provides NFS and storage utilities plus `/var/lib/longhorn` on all cluster nodes. This is host preparation, not a Longhorn installation, backup system, or evidence of adequate disk capacity. Verify stable disks, mounts, capacity, node scheduling and the version-specific Longhorn prerequisites first. Avoid storing durable data on the root disk by accident.

The companion example contains `k3s/helm-values/longhorn-values.yaml`, setting a data path and two replicas. Install a reviewed, version-pinned Longhorn chart separately in its own namespace, passing that values file with Helm. Check chart options and NixOS-specific host binary paths against that exact chart release; merely creating a PATH ConfigMap does not inject it into Longhorn pods. Verify manager/engine health, StorageClass selection, replica placement, a test PVC, node failure behavior and tested external backups before relying on the storage. Two replicas improve availability but are not a backup.

## Application-repository layout

`examples/k3s-homelab/` demonstrates a separate working tree:

```text
k3s/
  namespaces.yaml
  kustomization.yaml
  devops/status-page/
    deployment.yaml
    service.yaml
    kustomization.yaml
  helm-values/longhorn-values.yaml
```

The sample status page uses a Deployment, a ClusterIP Service, health probes, resource limits and a non-root security context. It is illustrative; review and pin its image by digest and establish a secure ingress before production use. The root Kustomization explicitly lists resources; adding a directory does not automatically enroll it in deployment. The Helm values file is managed separately from Kustomize.

```sh
kubectl kustomize examples/k3s-homelab/k3s
# After selecting and verifying the intended cluster context:
kubectl diff -k examples/k3s-homelab/k3s
kubectl apply -k examples/k3s-homelab/k3s
kubectl -n devops rollout status deployment/status-page
kubectl -n devops get deployment,service,pods
kubectl -n devops port-forward service/status-page 8080:80
```

`kubectl diff` and `apply` contact the selected cluster; use a dedicated scoped identity and review changes first. The example itself does not run these commands or install an agent. An existing CI pipeline may apply an explicit allowlist on a push, with Helm releases separately gated; this is push-based deployment, not automatic continuous reconciliation. Design the pipeline so lint and deployment failures block appropriately, use least-privilege RBAC, pin images and chart versions, verify rollouts, and document whether deletion/pruning is supported. A controller such as Flux or Argo CD would be a separate architectural choice.

## Registry, ingress, and observability

A registry hosted in Kubernetes can have an internal Service address for in-cluster pushes, while **node containerd image pulls originate from the nodes**, outside Kubernetes pod DNS. If an internal registry is used, configure a reachable registry mirror in the nodes' `/etc/rancher/k3s/registries.yaml` through Nix, use TLS and authentication appropriate to the trust boundary, and restart k3s in a controlled rollout when its registry config changes. Verify name resolution, reachability, image pull authorization and certificate validation from each node. Do not assume a NodePort or a loopback connection alone provides authentication or safe exposure.

With bundled Traefik and ServiceLB disabled, select and install a reviewed ingress/controller or private overlay integration separately. Examples include a Tailscale ingress/load balancer or an ingress controller behind private routing. Confirm authentication, TLS, access boundaries and recovery before exposing applications. The monitoring host can observe endpoints, while cluster monitoring may use a separately installed Prometheus/Grafana stack with storage and alerting configured in the application repository.
