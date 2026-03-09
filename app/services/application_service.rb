# app/services/application_service.rb
class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result, :do]

  def self.call(...)
    new(...).call
  end
end
