locals {
  rule_files = fileset(var.rules_directory, "**/*.json")
  
  rules = {
    for file in local.rule_files :
    trimsuffix(basename(file), ".json") => jsondecode(templatefile("${var.rules_directory}/${file}", {ACCOUNT_ID = var.account_id}))
  }
  
  scheduled_rules = {
    for name, rule in local.rules :
    name => rule if can(rule.cron_pattern) && rule.cron_pattern != null
  }
  
  event_rules = {
    for name, rule in local.rules :
    name => rule if can(rule.integration_code) && rule.integration_code != null
  }
}

resource "aws_cloudwatch_event_rule" "scheduled" {
  for_each = local.scheduled_rules

  name                = each.value.name
  schedule_expression = "cron(${each.value.cron_pattern})"
  is_enabled          = var.enabled
  event_bus_name      = var.event_bus_name
}

resource "aws_cloudwatch_event_rule" "event" {
  for_each = local.event_rules

  name           = each.value.name
  is_enabled     = var.enabled
  event_bus_name = var.event_bus_name

  event_pattern = jsonencode({
    detail-type = ["IntegratorEvent"]
    detail = {
      IntegrationCode = [each.value.integration_code]
    }
  })
}

resource "aws_cloudwatch_event_target" "scheduled" {
  for_each = {
    for pair in flatten([
      for rule_name, rule in local.scheduled_rules : [
        for idx, target_arn in rule.targets : {
          key        = "${rule_name}-${idx}"
          rule_name  = rule_name
          target_arn = target_arn
          index      = idx
        }
      ]
    ]) : pair.key => pair
  }

  rule           = aws_cloudwatch_event_rule.scheduled[each.value.rule_name].name
  arn            = replace(each.value.target_arn, "$ACCOUNT_ID", var.account_id)
  role_arn       = var.role_arn
}

resource "aws_cloudwatch_event_target" "event" {
  for_each = {
    for pair in flatten([
      for rule_name, rule in local.event_rules : [
        for idx, target_arn in rule.targets : {
          key        = "${rule_name}-${idx}"
          rule_name  = rule_name
          target_arn = target_arn
          index      = idx
        }
      ]
    ]) : pair.key => pair
  }

  rule           = aws_cloudwatch_event_rule.event[each.value.rule_name].name
  target_id      = "target-${each.value.index}"
  arn            = replace(each.value.target_arn, "$ACCOUNT_ID", var.account_id)
  role_arn       = var.role_arn
  event_bus_name = var.event_bus_name
}
