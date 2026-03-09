# frozen_string_literal: true

RSpec.shared_examples "unauthorized response" do
  response "401", "認証エラー" do
    let(:Authorization) { "Bearer invalid_token" }

    schema "$ref" => "#/components/schemas/error_response"
    run_test!
  end
end

RSpec.shared_examples "forbidden response" do
  response "403", "権限エラー" do
    schema "$ref" => "#/components/schemas/error_response"
    run_test!
  end
end

RSpec.shared_examples "not found response" do
  response "404", "リソースが見つからない" do
    schema "$ref" => "#/components/schemas/error_response"
    run_test!
  end
end
