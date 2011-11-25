require 'i18n'
require 'domainatrix'

module Rack
  class I18nLocaleSwitcher
    
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      I18n.locale = extract_locale(env)
      @app.call(env)
    end

    private

    def extract_locale(env)
      request = Rack::Request.new(env)
      uses = [ :param, :path, :subdomain, :tld, :client ]
      uses.each do |use|
        if locale = send(:"extract_locale_from_#{ use }", request)
          unless locale.empty?
            locale = locale.to_sym
            return locale if I18n.available_locales.include?(locale)
          end
        end
      end
      I18n.default_locale
    end

    def extract_locale_from_param(request)
      request.params["locale"]
    end

    def extract_locale_from_path(request)
      request.path_info =~ /^\/(\w{2,3})\b/ && $1
    end

    def extract_locale_from_tld(request)
      Domainatrix.parse(request.url).public_suffix rescue nil
    end

    def extract_locale_from_subdomain(request)
      Domainatrix.parse(request.url).subdomain rescue nil
    end

    def extract_locale_from_client(request)
      if lang = request.env["HTTP_ACCEPT_LANGUAGE"]
        lang = lang.split(",").map { |l|
          l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
          l.split(';q=')
        }.first
        lang.first.split("-").first
      end
    end
  end
end