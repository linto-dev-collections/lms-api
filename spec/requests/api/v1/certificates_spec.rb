# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Certificates", type: :request do
  path "/api/v1/certificates" do
    get "修了証一覧" do
      tags "Certificates"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "修了証一覧取得成功" do
        schema type: :object,
               properties: {
                 certificates: { type: :array, items: { "$ref" => "#/components/schemas/certificate" } }
               },
               required: %w[certificates]

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        before do
          enrollment = create(:enrollment, :completed, user: student)
          create(:certificate, :issued, enrollment: enrollment)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["certificates"].size).to eq(1)
        end
      end
    end
  end

  path "/api/v1/certificates/{certificate_number}" do
    parameter name: :certificate_number, in: :path, type: :string, required: true

    get "修了証詳細（認証不要）" do
      tags "Certificates"
      produces "application/json"

      response "200", "修了証取得成功" do
        schema "$ref" => "#/components/schemas/certificate"

        let(:enrollment) { create(:enrollment, :completed) }
        let(:cert) { create(:certificate, :issued, enrollment: enrollment) }
        let(:certificate_number) { cert.certificate_number }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["certificate_number"]).to eq(cert.certificate_number)
        end
      end

      response "404", "修了証が見つからない" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:certificate_number) { "CERT-UNKNOWN1" }

        run_test!
      end
    end
  end
end
