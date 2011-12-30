Kietter
=======
Author: Yoichi Hirai 2011
for license, see LICENSE

installation
------------

Prerequisites:

* R is necessary.  http://www.r-project.org/
* Moreover, the ppcor package of R is necessary.  http://cran.freestatistics.org/web/packages/ppcor/
* Using your twitter account, register an application on http://dev.twitter.com

There are some missing files in the repository.  On each file, you need to fill in XXX.

./config/initializers/secret_token.rb according to your taste.
    # Be sure to restart your server when you modify this file.
    
    # Your secret key for verifying the integrity of signed cookies.
    # If you change this key, all old signed cookies will become invalid!
    # Make sure the secret is at least 30 characters and all random,
    # no regular words or you'll be exposed to dictionary attacks.
    Kietter::Application.config.secret_token = 'XXX'

./config/database.yml according to your database setting.

config/initializers/omniauth.rb according to dev.twitter.com (register your own application)
    Rails.application.config.middleware.use OmniAuth::Builder do
      case Rails.env
      when 'production'
        provider :twitter, 'XXX', 'XXX'
      when 'development'
        provider :twitter, 'XXX', 'XXX'
      end
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    end
    
    Twitter.configure do |config|
      case Rails.env
      when 'production'
        config.consumer_key = 'XXX'
        config.consumer_secret = 'XXX'
      when 'development'
        config.consumer_key = 'XXX'
        config.consumer_secret = 'XXX'
      end
    end

config/initializers/exception_notification.rb according to your needs
    Kietter::Application.config.middleware.use ExceptionNotifier,
      :email_prefix => "[ERROR] ",
      :sender_address => 'XXX',
      :exception_recipients => ['XXX']

The rest should be similar to other rails 3 application.

1. bundle install
2. rails server (or anything)


