require 'i18n'
require 'rack/utils'

module Rack
  class I18nLocaleSwitcher
    include ::Rack::Utils

    LOCALE_PATTERN = '([a-zA-Z]{2,3})(-[a-zA-Z]{2,3})?'.freeze
    
    SOURCES   = [ :param, :path, :host, :header, :cookie ].freeze
    REDIRECTS = [ :param, :path, :host ].freeze
    
    DEFAULT_OPTIONS = {
      :param          => 'locale',
      :cookie         => 'locale',
      :source         => SOURCES,
      :redirect       => nil,
      :canonical      => false,
      :except         => nil,
      :save_to_cookie => false
    }.freeze

    def initialize(app, options = {})
      @app = app
      
      invalid_options = (options.keys - DEFAULT_OPTIONS.keys)
      
      if invalid_options.any?
        raise ArgumentError, "Invalid option(s) #{ invalid_options.map(&:inspect).join(', ') }" 
      end
      
      options = DEFAULT_OPTIONS.merge(options)

      @save_to_cookie = options[:save_to_cookie]
      @cookie         = options[:cookie]
      @param          = options[:param]
      @canonical      = options[:canonical]
      @except         = options[:except]

      @sources = options[:source]      
      @sources = Array(@sources) unless @sources.is_a?(Array)

      invalid_sources = @sources - SOURCES

      if invalid_sources.any?
        raise ArgumentError, "Invalid source(s) #{ invalid_sources.map(&:inspect).join(', ') }" 
      end

      @redirect = options[:redirect]

      unless @redirect.nil? || REDIRECTS.include?(@redirect)
        raise ArgumentError, "Invalid redirect option #{ @redirect.inspect }" 
      end
    end

    def call(env)
      return @app.call(env) if env['PATH_INFO'] =~ @except

      I18n.locale = I18n.default_locale

      env['PATH_INFO'].gsub!(/([^\/])\/$/, '\1')

      request = Rack::Request.new(env)
      request_url = request.url

      I18n.locale = @sources.to_enum.map do |src|
        send(:"extract_locale_from_#{src}", env)
      end.find {|e| !!e} || I18n.default_locale

      if @redirect
        unless @canonical && I18n.locale == I18n.default_locale
          send(:"set_locale_in_#@redirect", env)
        end

        if request.url != request_url
          env['PATH_INFO'] = '' if env['PATH_INFO'] == '/'
          return [ 301, { 'Location' => request.url }, ["Redirecting"]]
        end
      end

      if @save_to_cookie
        status, headers, body, *rest = @app.call(env)
        save_locale_in_cookies(headers)
        [status, headers, body, *rest]
      else
        @app.call(env)
      end
    end

    private
    
    def extract_locale_from_param(env)
      query_string = env['QUERY_STRING'].gsub(/\b#{ @param }=#{ LOCALE_PATTERN }(?:&|$)/, '')
      locale = available_locale($1, $2)
      if locale && @redirect
        env['QUERY_STRING'] = query_string.gsub(/&$/, '')        
      end
      locale
    end

    def extract_locale_from_path(env)
      path_info = env['PATH_INFO'].gsub(/^\/#{ LOCALE_PATTERN }\b/, '')
      locale = available_locale($1, $2)
      if locale && @redirect
        env['PATH_INFO'] = path_info
      end
      locale
    end

    def extract_locale_from_host(env)
      env['HTTP_HOST'] ||= "#{ env['SERVER_NAME'] }:#{ env['SERVER_PORT'] }"            

      http_host = env['HTTP_HOST'].gsub(/^#{ LOCALE_PATTERN }\./, '')
      locale = available_locale($1, $2)
      if locale && @redirect
        env['HTTP_HOST']   = http_host
        env['SERVER_NAME'] = http_host.gsub(/:\d+$/, '')
      end
      locale
    end

    def extract_locale_from_header(env)
      locale = nil            
      if accept = env['HTTP_ACCEPT_LANGUAGE']
        locales = accept.scan(/#{ LOCALE_PATTERN }\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?/i)
        locales.sort_by{ |loc| 1 - (loc.last || 1).to_f }.each do |loc|
          break if locale = available_locale(*loc[0,2])
        end
      end      
      locale
    end

    REGEXP_LOCALE_PATTERN = Regexp.new(LOCALE_PATTERN)

    def extract_locale_from_cookie(env)
      return unless REGEXP_LOCALE_PATTERN.match(cookies(env)[@cookie])
      available_locale($1, $2)
    end

    def cookies(env)
      parse_cookies(env) || {}
    end

    def set_locale_in_param(env)
      env['QUERY_STRING'] << '&' unless env['QUERY_STRING'].empty?
      env['QUERY_STRING'] << "#{ @param }=#{ I18n.locale }"
    end

    def set_locale_in_path(env)
      env['PATH_INFO'] = "/#{ I18n.locale }#{ env['PATH_INFO'] }".gsub(/\/$/, '')
    end

    def set_locale_in_host(env)
      env['HTTP_HOST']   = "#{ I18n.locale }.#{ env['HTTP_HOST'] }"
      env['SERVER_NAME'] = "#{ I18n.locale }.#{ env['SERVER_NAME'] }"
    end

    def save_locale_in_cookies(headers)
      set_cookie_header!(headers, @cookie, { value: I18n.locale, path: '/'})
    end

    def available_locale(language, region)
      if language
        locale = :"#{ language.downcase }#{ (region || '').upcase }"
        locale if I18n.available_locales.include?(locale)
      end
    end

    HTTP_COOKIE = 'HTTP_COOKIE'.freeze

    def parse_cookies(env)
      parse_cookies_header env[HTTP_COOKIE]
    end

    def parse_cookies_header(header)
      cookies = parse_query(header, ';,') { |s| unescape(s) rescue s }
      cookies.each_with_object({}) { |(k,v), hash| hash[k] = Array === v ? v.first : v }
    end
  end
end
