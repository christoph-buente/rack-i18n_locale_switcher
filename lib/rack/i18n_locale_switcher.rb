require 'i18n'
require 'domainatrix'

module Rack
  class I18nLocaleSwitcher
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      session = request.session
      locale = extract_locale(request)
      I18n.locale = session["locale"] = (is_present?(locale) ? locale : I18n.default_locale)

      @app.call cleanup_env(env)
    end

    private

    def is_available?(locale)
      not locale.nil? and not locale.empty? and I18n.available_locales.include?(locale.to_sym)
    end

    def extract_locale_from_params(request)
      locale = request.params["locale"]
      locale if is_available?(locale)
    end

    def extract_locale_from_path(request)
      if request.path_info =~ /^\/(\w{2,3})\b/
        $1 if is_available?($1)
      end
    end

    def extract_locale_from_tld(request)
      locale = Domainatrix.parse(request.url).public_suffix rescue nil
      locale if is_available?(locale)
    end

    def extract_locale_from_subdomain(request)
      locale = Domainatrix.parse(request.url).subdomain rescue nil
      locale if is_available?(locale)
    end

    def extract_locale_from_session(request)
      locale = request.session['locale']
      locale if is_available?(locale)
    end

    def extract_locale_from_accept_language(request)
      if lang = request.env["HTTP_ACCEPT_LANGUAGE"]
        lang = lang.split(",").map { |l|
          l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
          l.split(';q=')
        }.first
        locale = symbolize_locale(lang.first.split("-").first)
      else
        locale = I18n.default_locale
      end
      is_available?(locale) ? locale : I18n.default_locale
    end


    def extract_locale(request)
      locale = (  extract_locale_from_params(request)           ||
                  extract_locale_from_path(request)             ||
                  extract_locale_from_subdomain(request)        ||
                  extract_locale_from_tld(request)              ||
                  extract_locale_from_session(request)          ||
                  extract_locale_from_accept_language(request))
      symbolize_locale(locale)
    end

    def cleanup_env env
      %w{REQUEST_URI REQUEST_PATH PATH_INFO}.each do |key|
        if is_present?(env[key]) && env[key].length > 1 && tmp = env[key].split("/")
          tmp.delete_at(1) if tmp[1] =~ %r{^([a-zA-Z]{2})$}
          env[key] = tmp.join("/")
        end
      end
      env
    end


    def is_present?(value)
      !value.to_s.empty?
    end

    def symbolize_locale(locale)
      (is_present?(locale) ?  locale.to_s.downcase.to_sym : nil)
    end

  end
end