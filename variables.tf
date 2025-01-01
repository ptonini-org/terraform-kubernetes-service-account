variable "name" {}

variable "namespace" {}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "create_token" {
  default = true
}

variable "cluster_roles" {
  type = map(object({
    name = optional(string)
    rules = list(object({
      api_groups        = list(string)
      resources         = list(string)
      verbs             = list(string)
      resource_names    = list(string)
      non_resource_urls = list(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "cluster_role_bindings" {
  type     = list(string)
  default  = []
  nullable = false
}