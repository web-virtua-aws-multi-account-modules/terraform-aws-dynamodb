
variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are billed for read/write throughput and how you manage capacity, can be PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
  default     = null
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Must also be defined as an attribute"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "The number of read units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0"
  type        = number
  default     = null
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream, cam be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = null
}

variable "table_class" {
  description = "The storage class of the table, can be STANDARD and STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = null
}

variable "timeouts_create" {
  description = "Create Terraform resource management timeouts"
  type        = string
  default     = "10m"
}

variable "timeouts_update" {
  description = "Update Terraform resource management timeouts"
  type        = string
  default     = "60m"
}

variable "timeouts_delete" {
  description = "Delete Terraform resource management timeouts"
  type        = string
  default     = "10m"
}

variable "server_side_encryption_enabled" {
  description = "Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK)"
  type        = bool
  default     = false
}

variable "server_side_encryption_kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption. This attribute should only be specified if the key is different from the default DynamoDB CMK, alias/aws/dynamodb"
  type        = string
  default     = null
}

variable "ttl_enabled" {
  description = "Indicates whether ttl is enabled"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = ""
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "use_tags_default" {
  description = "If true will be use the tags default to DynamoDB"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to VPC"
  type        = map(any)
  default     = {}
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "attributes" { # campos na tabela
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
  type = list(object({
    name               = string
    hash_key           = string
    projection_type    = string
    range_key          = optional(string)
    read_capacity      = optional(number)
    write_capacity     = optional(number)
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "replica_regions" {
  description = "Region names for creating replicas for a global DynamoDB table."
  type = list(object({
    region_name            = string
    kms_key_arn            = optional(string)
    propagate_tags         = optional(bool)
    point_in_time_recovery = optional(bool)
  }))
  default = []
}

####autoscaling####
variable "autoscaling_read" {
  description = "A map of read autoscaling settings. `max_capacity` is the only required key. See example in examples/autoscaling"
  type = object({
    max_capacity       = number
    scale_in_cooldown  = optional(number)
    scale_out_cooldown = optional(number)
    target_value       = optional(number)
  })
  default = null
}

variable "autoscaling_write" {
  description = "A map of write autoscaling settings. `max_capacity` is the only required key. See example in examples/autoscaling"
  type = object({
    max_capacity       = number
    scale_in_cooldown  = optional(number)
    scale_out_cooldown = optional(number)
    target_value       = optional(number)
  })
  default = null
}

variable "autoscaling_defaults" {
  description = "A map of default autoscaling settings"
  type = object({
    scale_in_cooldown  = optional(number)
    scale_out_cooldown = optional(number)
    target_value       = optional(number)
  })
  default = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 70
  }
}

variable "autoscaling_indexes" {
  description = "Define the cors rules to buckes"
  type = list(object({
    index_name         = string
    read_max_capacity  = number
    read_min_capacity  = number
    write_max_capacity = number
    write_min_capacity = number
  }))
  default = null
}
