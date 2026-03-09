require "rails_helper"

RSpec.describe NotificationPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:notification) { create(:notification, user: user) }

  describe "#update?" do
    it "allows the notification owner" do
      expect(described_class.new(notification, user: user)).to be_allowed_to(:update?)
    end

    it "denies other users" do
      expect(described_class.new(notification, user: other_user)).not_to be_allowed_to(:update?)
    end
  end
end
