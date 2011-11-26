require 'i18n'
# require 'domainatrix'

module Rack
  class I18nLocaleSwitcher
    
    DEFAULT_OPTIONS = {
      :param  => 'locale',
      :source => [ :param, :path, :host, :header ]
    }.freeze

    def initialize(app, options = {})
      @app = app
      
      invalid_options = (options.keys - DEFAULT_OPTIONS.keys)
      
      if invalid_options.any?
        raise ArgumentError, "Invalid option(s) #{ invalid_options.map(&:inspect).join(', ') }" 
      end
      
      @options = DEFAULT_OPTIONS.merge(options)
      @options[:source] = Array(@options[:source]) unless @options[:source].is_a?(Array)
    end

    def call(env)
      I18n.locale = I18n.default_locale
      
      @options[:source].each do |source|
        if locale = send(:"get_locale_from_#{source}", env)
          I18n.locale = locale
          break
        end
      end
            
      @app.call(env)
    end

    private

    def get_locale_from_param(env)
      env['QUERY_STRING'] =~ /\b#{ @options[:param] }=([^&]+)\b/
      to_available_locale($1)
    end

    def get_locale_from_path(env)
      env['PATH_INFO'] =~ /^\/([^\/]+)/
      to_available_locale($1)
    end

    def get_locale_from_host(env)
      env['SERVER_NAME'] =~ /^([^.]+)\.[^.]+\.[^.]+/i
      to_available_locale($1)
    end

    def get_locale_from_header(env)
      locale = nil
      if accept = env['HTTP_ACCEPT_LANGUAGE']
        locales = accept.scan(/([^;,]+)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?/i)
        locales.sort_by{ |loc| 1 - (loc.last || 1).to_f }.each do |loc|
          break if locale = to_available_locale(loc.first)
        end
      end
      locale
    end
    
    def to_available_locale(locale)
      if locale =~ /^([a-z]{1,8})(-[a-z]{1,8})?$/i
        locale = :"#{ $1.downcase }#{ ($2 || '').upcase }"
        locale if I18n.available_locales.include?(locale)
      end
    end
  end
end