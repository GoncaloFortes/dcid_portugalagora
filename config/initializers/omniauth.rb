OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FB_APP_ID'], ENV['FB_APP_SECRET'],
    scope: 'email,public_profile', display: 'popup',
    client_options: {
      site: 'https://graph.facebook.com/v2.2',
      authorize_url: "https://www.facebook.com/v2.2/dialog/oauth"
    }
end
