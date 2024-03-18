resource "aws_cloudwatch_event_rule" "lambda_every_10_minutes" {
  name                = "lambda-every-10-minutes"
  description         = "Runs every 10 minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "trigger_lambda_on_schedule" {
  rule      = aws_cloudwatch_event_rule.lambda_every_10_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${local.function_name}"
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_every_10_minutes.arn
}
