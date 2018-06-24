require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Urarusu
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.assets.paths << Rails.root.join('app', 'assets')
    config.assets.precompile += ['*.js', '*.css', '*.svg', '*.eot', '*.woff', '*.woff2', '*.ttf', ]
    config.autoload_paths += %W(#{config.root}/lib)
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      if html_tag.to_s.include?("class=")
        html_tag.gsub("class=\"","class=\"error ").html_safe
      else
        html_tag.gsub("name=\"","class=\"error\" name=\"").html_safe
      end
    end

    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.action_controller.default_url_options = { trailing_slash: true }
    config.paths.add 'lib', eager_load: true
    config.autoload_paths += Dir["#{config.root}/decorators/**/"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
