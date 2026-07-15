output "function_arn" {
  description = "ARN de la funcion Lambda"
  value       = aws_lambda_function.processor.arn
}

output "function_name" {
  description = "Nombre de la funcion Lambda"
  value       = aws_lambda_function.processor.function_name
}

output "execution_role_arn" {
  description = "ARN del rol de ejecucion de la Lambda"
  value       = aws_iam_role.lambda_exec.arn
}