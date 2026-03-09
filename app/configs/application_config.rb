# app/configs/application_config.rb
class ApplicationConfig < Anyway::Config
  class << self
    def instance
      @instance ||= new
    end
  end
end
