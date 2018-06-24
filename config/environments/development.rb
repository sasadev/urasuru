Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # config for action mailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  CA_FILE = case RUBY_PLATFORM
              when /darwin/
                '/usr/share/curl/curl-ca-bundle.crt' # Mac OS X
              when /freebsd/
                '/usr/ports/security/ca-roots/files/ca-root.crt'
              when /linux/
                '/etc/pki/tls/certs/ca-bundle.crt'
              else
                # 'c:\work\curl-ca-bundle.crt' # ... Windows
            end
  # テスト環境 https://pt01.mul-pay.jp/ext/js/token.js
  # 本番環境 https://p01.mul-pay.jp/ext/js/token.js
  ###### Configuration of ip restriction (管理機能のアクセス制限) ##########
  IP_RESTRICTION_FOR_ADMIN = false
  ALLOW_IP_FOR_ADMIN       = ['127.0.0.1']
  MAINTE_MODE              = true
  MAINTE_ALLOW_IP          = ALLOW_IP_FOR_ADMIN
end