module Api
  module V1
    class NotificationsController < BaseController
      # GET /api/v1/notifications
      def index
        notifications = current_user.notifications.newest_first
        pagy, records = pagy(:offset, notifications)

        render json: {
          notifications: records.map { |n| serialize(n, with: NotificationSerializer) },
          meta: pagy_metadata(pagy),
          unread_count: current_user.notifications.unread.count
        }
      end

      # PATCH /api/v1/notifications/:id
      def update
        notification = current_user.notifications.find(params[:id])
        authorize! notification, with: NotificationPolicy

        if params[:read] == true || params[:read] == "true"
          notification.mark_as_read!
        end

        render json: serialize(notification, with: NotificationSerializer)
      end

      # POST /api/v1/notifications/read_all
      def read_all
        current_user.notifications.unread.update_all(read_at: Time.current)
        head :no_content
      end
    end
  end
end
