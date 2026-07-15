output "alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.cloudfront_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.cloudfront_4xx.alarm_name,
    aws_cloudwatch_metric_alarm.apigw_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.apigw_latency.alarm_name,
  ]
}