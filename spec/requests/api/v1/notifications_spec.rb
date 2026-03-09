# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Notifications", type: :request do
  path "/api/v1/notifications" do
    get "通知一覧" do
      tags "Notifications"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "通知一覧取得成功" do
        schema type: :object,
               properties: {
                 notifications: { type: :array, items: { "$ref" => "#/components/schemas/notification" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" },
                 unread_count: { type: :integer }
               },
               required: %w[notifications meta unread_count]

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)["Authorization"] }

        before do
          create(:notification, user: user)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["notifications"]).not_to be_empty
          expect(data).to have_key("unread_count")
        end
      end
    end
  end

  path "/api/v1/notifications/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    patch "通知を既読にする" do
      tags "Notifications"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          read: { type: :boolean }
        }
      }

      response "200", "既読化成功" do
        schema "$ref" => "#/components/schemas/notification"

        let(:user) { create(:user) }
        let(:notification) { create(:notification, user: user) }
        let(:id) { notification.id }
        let(:Authorization) { auth_headers_for(user)["Authorization"] }
        let(:params) { { read: true } }

        run_test! do
          expect(notification.reload.read_at).to be_present
        end
      end
    end
  end

  path "/api/v1/notifications/read_all" do
    post "全通知を既読にする" do
      tags "Notifications"
      security [ bearer_auth: [] ]

      response "204", "全既読化成功" do
        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)["Authorization"] }

        before do
          create_list(:notification, 3, user: user)
        end

        run_test! do
          expect(user.notifications.unread.count).to eq(0)
        end
      end
    end
  end
end
