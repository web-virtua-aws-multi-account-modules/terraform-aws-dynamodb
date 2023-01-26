###Read###
resource "aws_appautoscaling_target" "table_read" {
  count = var.autoscaling_read != null ? 1 : 0

  max_capacity       = var.autoscaling_read.max_capacity
  min_capacity       = var.read_capacity
  resource_id        = "table/${aws_dynamodb_table.create_dynamodb.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "table_read_policy" {
  count = var.autoscaling_read != null ? 1 : 0

  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.table_read[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    scale_in_cooldown  = try(var.autoscaling_read.scale_in_cooldown, 50)
    scale_out_cooldown = try(var.autoscaling_read.scale_out_cooldown, 40)
    target_value       = try(var.autoscaling_read.target_value, 45)
  }
}

###Write###
resource "aws_appautoscaling_target" "table_write" {
  count = var.autoscaling_write != null ? 1 : 0

  max_capacity       = var.autoscaling_write.max_capacity
  min_capacity       = var.write_capacity
  resource_id        = "table/${aws_dynamodb_table.create_dynamodb.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "table_write_policy" {
  count = var.autoscaling_write != null ? 1 : 0

  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.table_write[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    scale_in_cooldown  = try(var.autoscaling_write.scale_in_cooldown, 50)
    scale_out_cooldown = try(var.autoscaling_write.scale_out_cooldown, 50)
    target_value       = try(var.autoscaling_write.target_value, 50)
  }
}

###Index###
resource "aws_appautoscaling_target" "index_read" {
  count = var.autoscaling_indexes != null ? length(var.autoscaling_indexes) : 0

  max_capacity       = var.autoscaling_indexes[count.index].read_max_capacity
  min_capacity       = var.autoscaling_indexes[count.index].read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.create_dynamodb.name}/index/${var.autoscaling_indexes[count.index].index_name}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "index_read_policy" {
  count = var.autoscaling_indexes != null ? length(var.autoscaling_indexes) : 0

  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.index_read[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.index_read[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.index_read[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.index_read[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    scale_in_cooldown  = try(var.autoscaling_indexes[count.index].scale_in_cooldown, var.autoscaling_defaults.scale_in_cooldown)
    scale_out_cooldown = try(var.autoscaling_indexes[count.index].scale_out_cooldown, var.autoscaling_defaults.scale_out_cooldown)
    target_value       = try(var.autoscaling_indexes[count.index].target_value, var.autoscaling_defaults.target_value)
  }
}

resource "aws_appautoscaling_target" "index_write" {
  count = var.autoscaling_indexes != null ? length(var.autoscaling_indexes) : 0

  max_capacity       = var.autoscaling_indexes[count.index].write_max_capacity
  min_capacity       = var.autoscaling_indexes[count.index].write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.create_dynamodb.name}/index/${var.autoscaling_indexes[count.index].index_name}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "index_write_policy" {
  count = var.autoscaling_indexes != null ? length(var.autoscaling_indexes) : 0

  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.index_write[count.index].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.index_write[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.index_write[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.index_write[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    scale_in_cooldown  = try(var.autoscaling_indexes[count.index].scale_in_cooldown, var.autoscaling_defaults.scale_in_cooldown)
    scale_out_cooldown = try(var.autoscaling_indexes[count.index].scale_out_cooldown, var.autoscaling_defaults.scale_out_cooldown)
    target_value       = try(var.autoscaling_indexes[count.index].target_value, var.autoscaling_defaults.target_value)
  }
}
