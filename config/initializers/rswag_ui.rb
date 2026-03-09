# frozen_string_literal: true

Rswag::Ui.configure do |c|
  c.openapi_endpoint "/api-docs/v1/openapi.yaml", "LMS API V1"

  c.config_object["deepLinking"] = true
  c.config_object["displayRequestDuration"] = true
  c.config_object["docExpansion"] = "list"
  c.config_object["filter"] = true
  c.config_object["tryItOutEnabled"] = true
end
