output "dashboard_url" {
  value = module.dashboard.dashboard_url
}

output "alarm_names" {
  value = module.alarms.alarm_names
}

output "log_group_name" {
  value = module.logs_insights.log_group_name
}

output "xray_sampling_rule_name" {
  value = module.xray.sampling_rule_name
}