# AWS DynamoDB for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a DynamoDB across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of DynamoDB configurations for this module:

- DynamoDB table
- Auto scaling table and index

## Usage exemples

### Simple DynamoDB table

```hcl
module "dynamodb_table_simple" {
  source = "web-virtua-aws-multi-account-modules/dynamodb/aws"

  name        = "tf-dynamodb-table-simple"
  hash_key    = "id"
  range_key   = "title"
  table_class = "STANDARD"

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "TitleIndex"
      non_key_attributes = ["id"]
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
    }
  ]

  providers = {
    aws = aws.alias_profile_a
  }
}
```

### DynamoDB table with auto scaling

```
module "dynamodb_table_scaling" {
  source = "web-virtua-aws-multi-account-modules/dynamodb/aws"

  name           = "tf-dynamodb-table-scaling"
  hash_key       = "id"
  range_key      = "title"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "TitleIndex"
      non_key_attributes = ["id"]
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
      write_capacity     = 10
      read_capacity      = 10
    }
  ]

  autoscaling_read = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  autoscaling_write = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  autoscaling_indexes = [
    {
      index_name         = "TitleIndex"
      read_max_capacity  = 31
      read_min_capacity  = 10
      write_max_capacity = 30
      write_min_capacity = 10
    }
  ]

  providers = {
    aws = aws.compute_dev
  }
}
```

### DynamoDB table with replication and KMS

```hcl
module "dynamodb_table_replica" {
  source = "web-virtua-aws-multi-account-modules/dynamodb/aws"

  name             = "tf-dynamodb-table-replica"
  hash_key         = "id"
  range_key        = "title"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_key.primary.arn

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "TitleIndex"
      non_key_attributes = ["id"]
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
    }
  ]

  replica_regions = [{
    region_name            = "us-east-2"
    kms_key_arn            = aws_kms_key.secondary.arn
    propagate_tags         = true
    point_in_time_recovery = true
  }]

  providers = {
    aws = aws.alias_profile_a
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| name | `string` | `-` | yes | Name of the DynamoDB table | `-` |
| billing_mode | `string` | `PAY_PER_REQUEST` | no | Controls how you are billed for read/write throughput and how you manage capacity, can be PROVISIONED or PAY_PER_REQUEST | `*`PAY_PER_REQUEST <br> `*`PROVISIONED |
| hash_key | `string` | `null` | no | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `-` |
| range_key | `string` | `null` | no | The attribute to use as the range (sort) key. Must also be defined as an attribute | `-` |
| read_capacity | `number` | `null` | no | The number of read units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0 | `-` |
| write_capacity | `number` | `null` | no | The number of write units for this table. If the billing_mode is PROVISIONED, this field should be greater than 0 | `-` |
| stream_enabled | `bool` | `false` | no | Indicates whether Streams are to be enabled (true) or disabled (false) | `*`false <br> `*`true |
| stream_view_type | `string` | `null` | no | When an item in the table is modified, StreamViewType determines what information is written to the table's stream, cam be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES | `*`KEYS_ONLY <br> `*`NEW_IMAGE <br> `*`OLD_IMAGE <br> `*`NEW_AND_OLD_IMAGES |
| table_class | `string` | `null` | no | The storage class of the table, can be STANDARD and STANDARD_INFREQUENT_ACCESS | `*`STANDARD <br> `*`STANDARD_INFREQUENT_ACCESS |
| timeouts_create | `string` | `10m` | no | Create Terraform resource management timeouts | `-` |
| timeouts_update | `string` | `60m` | no | Update Terraform resource management timeouts | `-` |
| timeouts_delete | `string` | `10m` | no | Delete Terraform resource management timeouts | `-` |
| server_side_encryption_enabled | `bool` | `false` | no | Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK) | `*`false <br> `*`true |
| server_side_encryption_kms_key_arn | `string` | `null` | no | The ARN of the CMK that should be used for the AWS KMS encryption. This attribute should only be specified if the key is different from the default DynamoDB CMK, alias/aws/dynamodb | `-` |
| ttl_enabled | `bool` | `false` | no | Indicates whether ttl is enabled | `*`false <br> `*`true |
| ttl_attribute_name | `string` | `-` | no | The name of the table attribute to store the TTL timestamp in | `-` |
| point_in_time_recovery_enabled | `bool` | `false` | no | Whether to enable point-in-time recovery | `*`false <br> `*`true |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to DynamoDB | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to resources | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| attributes | `list(object)` | `[]` | no | List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `-` |
| local_secondary_indexes | `list(object)` | `[]` | no | Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource | `-` |
| global_secondary_indexes | `list(object)` | `[]` | no | Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | `-` |
| replica_regions | `list(object)` | `[]` | no | Region names for creating replicas for a global DynamoDB table | `-` |
| autoscaling_read | `object` | `null` | no | A map of read autoscaling settings. `max_capacity` is the only required key. See example in examples/autoscaling | `-` |
| autoscaling_write | `object` | `null` | no | A map of write autoscaling settings. `max_capacity` is the only required key. See example in examples/autoscaling | `-` |
| autoscaling_defaults | `object` | `null` | no | A map of default autoscaling settings | `-` |
| autoscaling_indexes | `list(object)` | `[]` | no | Define the cors rules to buckes | `-` |


## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.create_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_appautoscaling_policy.any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
## Outputs

| Name | Description |
|------|-------------|
| `dynamodb` | DynamoDB table |
| `dynamodb_table_arn` | ARN of the DynamoDB table |
| `dynamodb_table_id` | ID of the DynamoDB table |
| `dynamodb_table_stream_arn` | The ARN of the Table Stream. Only available when var.stream_enabled is true |
| `dynamodb_table_stream_label` | A timestamp, in ISO 8601 format of the Table Stream. Only available when var.stream_enabled is true |
