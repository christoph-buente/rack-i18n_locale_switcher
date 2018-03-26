require 'rack/i18n_locale_switcher'
require 'rack/test'

describe Rack::I18nLocaleSwitcher do

  include Rack::Test::Methods

  let :options do
    {}
  end

  let :app do
    opts = options
    rack = Rack::Builder.new do
      map "/" do
        use Rack::I18nLocaleSwitcher, opts
        run lambda { |env| [200, {}, "Coolness"] }
      end
    end
    rack.to_app
  end

  before do
    I18n.available_locales = [:en, :'en-US', :de, :'de-DE', :es]
    I18n.default_locale = :en
  end

  it "should fall back to the locale to default locale" do
    get "http://example.com/some/path"
    I18n.locale.should eql(I18n.default_locale)

    get "http://www.example.com/"
    I18n.locale.should eql(I18n.default_locale)
  end

  it "should not accept invalid options" do
    expect {
      Rack::I18nLocaleSwitcher.new("app", :not_an_option => "foo")
    }.to raise_error(ArgumentError, "Invalid option(s) :not_an_option")

    expect {
      Rack::I18nLocaleSwitcher.new("app", :source => [ :not_a_source ])
    }.to raise_error(ArgumentError, "Invalid source(s) :not_a_source")

    expect {
      Rack::I18nLocaleSwitcher.new("app", :redirect => :not_a_source)
    }.to raise_error(ArgumentError, "Invalid redirect option :not_a_source")
  end

  context "with custom sources" do

    let :options do
      { :source => [ :header, :host ] }
    end

    it "should honor the sequence" do
      get "http://de.example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "es"}
      I18n.locale.should eql(:es)

      get "http://de.example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "foo"}
      I18n.locale.should eql(:de)

      get "http://de.example.com"
      I18n.locale.should eql(:de)
    end

    it "should ignore other sources" do
      get "http://example.com?locale=de"
      I18n.locale.should eql(:en)

      get "http://example.com/de"
      I18n.locale.should eql(:en)
    end
  end

  context "request param" do

    it "should set the locale" do
      get "http://example.com?locale=de"
      I18n.locale.should eql(:de)

      get "http://example.com?locale=en-US"
      I18n.locale.should eql(:'en-US')

      get "http://example.com/some/path?foo=bar&locale=es&param=value"
      I18n.locale.should eql(:es)
    end

    it 'should not change the query string unless redirect is used' do
      get "http://example.com?locale=de"
      last_request.env['QUERY_STRING'].should eql('locale=de')

      get "http://example.com?locale=en-US"
      last_request.env['QUERY_STRING'].should eql('locale=en-US')

      get "http://example.com/some/path?foo=bar&locale=es&param=value"
      last_request.env['QUERY_STRING'].should eql('foo=bar&locale=es&param=value')
    end

    it "should not set an unavailable locale" do
      get "http://example.com?locale=xx"
      I18n.locale.should eql(I18n.default_locale)
    end

    context "name" do

      let :options do
        { :param => "lang" }
      end

      it "should be configurable" do
        get "http://example.com?lang=de"
        I18n.locale.should eql(:de)
      end
    end
  end

  context "from path prefix " do

    it "should set the I18n locale" do
      get "http://example.com/de/some/path/"
      I18n.locale.should eql(:de)

      get "http://example.com/en-us"
      I18n.locale.should eql(:'en-US')
    end

    it 'should not change path if not using redirect' do
      get "http://example.com/de/some/path/"
      last_request.env['PATH_INFO'].should eql('/de/some/path/')

      get "http://example.com/en-us"
      last_request.env['PATH_INFO'].should eql('/en-us')
    end
  end

  context "from host" do

    it "should set the I18n locale" do
      get "http://de.example.com/"
      I18n.locale.should eql(:de)

      get "http://de-de.example.com/"
      I18n.locale.should eql(:'de-DE')
    end

    it "should not change host if not using redirect" do
      get "http://de.example.com/"
      last_request.env['SERVER_NAME'].should eql('de.example.com')
      last_request.env['HTTP_HOST'].should eql('de.example.com')

      get "http://de-de.example.com/"
      I18n.locale.should eql(:'de-DE')
      last_request.env['SERVER_NAME'].should eql('de-de.example.com')
      last_request.env['HTTP_HOST'].should eql('de-de.example.com')
    end
  end

  context "from accept-language header" do

    it "should override the client requested locale" do
      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "de-de,de,en;q=0.5"}
      I18n.locale.should eql(:'de-DE')

      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "en;q=0.5,en-US;q=0.8,es;q=0.7"}
      I18n.locale.should eql(:'en-US')
    end
  end

  context "from cookie" do
    it "should set the i18n locale" do
      get "http://example.com", nil, { "HTTP_COOKIE" => "locale=de-de" }
      I18n.locale.should eql(:'de-DE')

      get "http://example.com", nil, { "HTTP_COOKIE" => "locale=en-US" }
      I18n.locale.should eql(:'en-US')

      get "http://example.com", nil, { "HTTP_COOKIE" => "" }
      I18n.locale.should eql(I18n.default_locale)
    end
  end

  shared_examples_for "a redirect with the default locale" do

    it "should redirect to the canonical URL" do
      %w{ 
        http://en.example.com
        http://example.com/en
        http://example.com?locale=en
      }.each do |url|
        get url
        last_response.should be_redirect
        last_response.location.should eql("http://example.com")
      end
    end

    it "should not redirect if the locale was set in the accept header" do
      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "en"}
      last_response.should_not be_redirect
    end
  end

  context "redirect to path" do

    let :options do
      { :redirect => :path }
    end

    it "should not redirect if the locale was set with the path" do
      %w{ 
        http://example.com/de
        http://example.com/en
        http://example.com/en/
        http://example.com/en/foo/bar
      }.each do |url|
        get url
        last_response.should_not be_redirect
      end
    end

    it "should redirect if the locale was set by other means" do
      {
        "http://en.example.com"        => "http://example.com/en",
        "http://en.example.com/de"     => "http://example.com/de",
        "http://de.example.com"        => "http://example.com/de",
        "http://example.com?locale=de" => "http://example.com/de"
      }.each do |url, redirect_url|
        get url
        last_response.should be_redirect
        last_response.location.should eql(redirect_url)
      end
    end

    it "should redirect if the locale was set with an accept header" do
      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "de"}
      last_response.should be_redirect
      last_response.location.should eql("http://example.com/de")
    end

    context "canonical" do

      let :options do
        { :redirect => :path, :canonical => true }
      end

      it_should_behave_like "a redirect with the default locale"
    end
  end

  context "host" do

    let :options do
      { :redirect => :host }
    end

    it "should not redirect if the locale was set with the host" do
      %w{ 
        http://de.example.com
        http://en.example.com/
        http://en.example.com/foo/bar
      }.each do |url|
        get url
        last_response.should_not be_redirect
      end
    end

    it "should redirect if the locale was set by other means" do
      {
        "http://example.com/en"        => "http://en.example.com",
        "http://en.example.com/de"     => "http://de.example.com",
        "http://example.com/de"        => "http://de.example.com",
        "http://example.com?locale=de" => "http://de.example.com"
      }.each do |url, redirect_url|
        get url
        last_response.should be_redirect
        last_response.location.should eql(redirect_url)
      end
    end

    it "should redirect if the locale was set with an accept header" do
      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "de"}
      last_response.should be_redirect
      last_response.location.should eql("http://de.example.com")
    end

    context "canonical" do

      let :options do
        { :redirect => :host, :canonical => true }
      end

      it_should_behave_like "a redirect with the default locale"
    end
  end

  context "param" do

    let :options do
      { :redirect => :param }
    end

    it "should not redirect if the locale was set with a param" do
      %w{ 
        http://example.com?locale=de
        http://example.com/?locale=en
        http://example.com/foo/bar?locale=en
      }.each do |url|
        get url
        last_response.should_not be_redirect
      end
    end

    it "should redirect if the locale was set by other means" do
      {
        "http://example.com/en"           => "http://example.com?locale=en",
        "http://de.example.com/foo/bar"   => "http://example.com/foo/bar?locale=de",
        "http://example.com/de"           => "http://example.com?locale=de",
        "http://en.example.com?locale=de" => "http://example.com?locale=de"
      }.each do |url, redirect_url|
        get url
        last_response.should be_redirect
        last_response.location.should eql(redirect_url)
      end
    end

    it "should redirect if the locale was set with an accept header" do
      get "http://example.com" , nil, {"HTTP_ACCEPT_LANGUAGE" => "de"}
      last_response.should be_redirect
      last_response.location.should eql("http://example.com?locale=de")
    end

    context "canonical" do

      let :options do
        { :redirect => :param, :canonical => true }
      end

      it_should_behave_like "a redirect with the default locale"
    end

    context "exceptions" do

      let :options do
        { :redirect => :path, :except => /^\/assets/ }
      end

      it "should not redirect if the path is exempt" do
        [ "http://example.com/assets",
          "http://de.example.com/assets/foo/bar",
          "http://example.com/assets/"
        ].each do |url|
          get url
          last_response.should_not be_redirect
        end
      end
    end
  end

  context "save_to_cookie" do
    let(:options) do
      { save_to_cookie: true, cookie: 'cookie_name_for_locale' }
    end

    [
      ["path", "http://example.com/es", {}, {}],
      ["param", "http://example.com", { 'locale' => 'es' }, {}],
      ["host", "http://es.example.com", {}, {}],
      ["headers", "http://example.com", {}, { "HTTP_ACCEPT_LANGUAGE" => "es" }],
      ["cookie", "http://example.com", {}, { "HTTP_COOKIE" => "cookie_name_for_locale=es" }],
    ].each do |src, url, params, env|
      it "should set locale in the cookie header when reading from #{src}" do
        get url, params, env
        I18n.locale.should eq(:es)
        last_response.header.should include("Set-Cookie")
        last_response.header["Set-Cookie"].should match(/cookie_name_for_locale/)
        last_response.header["Set-Cookie"].should match(/=es/)
      end
    end
  end
end
