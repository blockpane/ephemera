# API Gateway object
resource "aws_api_gateway_rest_api" "apigw" {
  name        = "api_gw_${var.app_name}"
  description = "${var.app_name} API Gateway"
}

# POST method for /save endpoint
resource "aws_api_gateway_resource" "save" {
   rest_api_id = aws_api_gateway_rest_api.apigw.id
   parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
   path_part   = "save"
}

resource "aws_api_gateway_method" "save" {
   rest_api_id   = aws_api_gateway_rest_api.apigw.id
   resource_id   = aws_api_gateway_resource.save.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_save" {
   rest_api_id = aws_api_gateway_rest_api.apigw.id
   resource_id = aws_api_gateway_method.save.resource_id
   http_method = aws_api_gateway_method.save.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda_save.invoke_arn
}

# POST method for /view endpoint
resource "aws_api_gateway_resource" "view" {
   rest_api_id = aws_api_gateway_rest_api.apigw.id
   parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
   path_part   = "view"
}

resource "aws_api_gateway_method" "view" {
   rest_api_id   = aws_api_gateway_rest_api.apigw.id
   resource_id   = aws_api_gateway_resource.view.id
   http_method   = "POST"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_view" {
   rest_api_id = aws_api_gateway_rest_api.apigw.id
   resource_id = aws_api_gateway_method.view.resource_id
   http_method = aws_api_gateway_method.view.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.lambda_view.invoke_arn
}

# Deployment. Add this later https://medium.com/coryodaniel/til-forcing-terraform-to-deploy-a-aws-api-gateway-deployment-ed36a9f60c1a
resource "aws_api_gateway_deployment" "deployment" {
   depends_on = [
     aws_api_gateway_integration.lambda_save,
     aws_api_gateway_integration.lambda_view,
   ]

   rest_api_id = aws_api_gateway_rest_api.apigw.id
   stage_name  = "v1"
}

resource "aws_lambda_permission" "apigw_save" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda_save.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   # source_arn = "${aws_api_gateway_rest_api.apigw.execution_arn}/*/*"
   source_arn = "${aws_api_gateway_rest_api.apigw.execution_arn}/*/${aws_api_gateway_method.save.http_method}${aws_api_gateway_resource.save.path}"
}

resource "aws_lambda_permission" "apigw_view" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda_view.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   # source_arn = "${aws_api_gateway_rest_api.apigw.execution_arn}/*/*"
   source_arn = "${aws_api_gateway_rest_api.apigw.execution_arn}/*/${aws_api_gateway_method.view.http_method}${aws_api_gateway_resource.view.path}"
}

# OPTIONS method for /save endpoint
resource "aws_api_gateway_method" "save_options_method" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.save.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "save_options" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.save.id
    http_method   = aws_api_gateway_method.save_options_method.http_method
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.save_options_method]
}
resource "aws_api_gateway_integration" "save_options_integration" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.save.id
    http_method   = aws_api_gateway_method.save_options_method.http_method
    type          = "MOCK"
    request_templates = {
    "application/json": "{\"statusCode\": 200}"
    }
    depends_on = [aws_api_gateway_method.save_options_method]
}
resource "aws_api_gateway_integration_response" "save_options_integration_response" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.save.id
    http_method   = aws_api_gateway_method.save_options_method.http_method
    status_code   = aws_api_gateway_method_response.save_options.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'${var.scheme}://${var.bucket_name}'"
    }
    depends_on = [aws_api_gateway_method_response.save_options]
}

# OPTIONS method for /view endpoint
resource "aws_api_gateway_method" "view_options_method" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.view.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "view_options" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.view.id
    http_method   = aws_api_gateway_method.view_options_method.http_method
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.view_options_method]
}
resource "aws_api_gateway_integration" "view_options_integration" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.view.id
    http_method   = aws_api_gateway_method.view_options_method.http_method
    type          = "MOCK"
    request_templates = {
    "application/json": "{\"statusCode\": 200}"
    }
    depends_on = [aws_api_gateway_method.view_options_method]
}
resource "aws_api_gateway_integration_response" "view_options_integration_response" {
    rest_api_id   = aws_api_gateway_rest_api.apigw.id
    resource_id   = aws_api_gateway_resource.view.id
    http_method   = aws_api_gateway_method.view_options_method.http_method
    status_code   = aws_api_gateway_method_response.view_options.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'${var.scheme}://${var.bucket_name}'"
    }
    depends_on = [aws_api_gateway_method_response.view_options]
}