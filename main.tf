resource "kubernetes_service_account_v1" "this" {

  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }
}

resource "kubernetes_secret_v1" "this" {
  count = var.create_token ? 1 : 0

  metadata {
    generate_name = kubernetes_service_account_v1.this.metadata[0].name
    namespace     = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.this.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

module "cluster_role" {
  source   = "app.terraform.io/ptonini-org/cluster-role/kubernetes"
  version  = "~> 1.0.0"
  for_each = var.cluster_roles
  name     = coalesce(each.value.name, each.key)
  rules    = each.value.rules
  subject = {
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = kubernetes_service_account_v1.this.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  for_each = toset(var.cluster_role_bindings)

  metadata {
    name = "${kubernetes_service_account_v1.this.metadata[0].name}-${index(var.cluster_role_bindings, each.key)}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = each.value
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = kubernetes_service_account_v1.this.metadata[0].namespace
  }
}