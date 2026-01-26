# Configure default URL options for production environment
# These are used by url_helpers (e.g., for generating document URLs in SMS messages)

Rails.application.configure do
  # Set host and protocol from environment variables
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost:3000"),
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }

  # Also configure for routes
  Rails.application.routes.default_url_options[:host] = ENV.fetch("APP_HOST", "localhost:3000")
  Rails.application.routes.default_url_options[:protocol] = ENV.fetch("APP_PROTOCOL", "http")
end
