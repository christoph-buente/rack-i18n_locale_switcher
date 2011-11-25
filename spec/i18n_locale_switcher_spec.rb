require 'rack/i18n_locale_switcher'
require 'rack/test'

describe Rack::I18nLocaleSwitcher do

  include Rack::Test::Methods

  def app
    Rack::Builder.new {
      map "/" do
        use Rack::I18nLocaleSwitcher
        run lambda { |env| [200, {}, "Coolness"] }
      end
    }.to_app
  end

  before do
    I18n.available_locales = [:en, :'en-US', :de, :'de-DE', :es]
    I18n.default_locale = :en
  end

  it "should set the locale to default locale" do
    get '/'
    I18n.locale.should eql(I18n.default_locale)
  end

  context 'request param' do

    it "should set the I18n locale" do
      get '/', :locale => 'de'
      last_request.url.should include('?locale=de')
      I18n.locale.should eql(:de)
    end

    it "should only allow available locales" do
      get '/', :locale => 'xx'
      I18n.locale.should eql(I18n.default_locale)
    end
  end

  context 'from path prefix ' do

    it "should set the I18n locale" do
      get '/de/'
      I18n.locale.should eql(:de)
    end
  end

  context 'from subdomain' do

    it "should set the I18n locale" do
      get 'http://de.example.com/'
      I18n.locale.should eql(:de)
    end
  end

  context 'from top level domain' do

    it "should set the I18n locale" do
      get 'http://example.de/'
      I18n.locale.should eql(:de)
    end
  end

  context 'from accept-language header' do

    it "should override the client requested locale" do
      get '/' , {}, {'HTTP_ACCEPT_LANGUAGE' => "de, de-de,en;q=0.5"}
      I18n.locale.should eql(:de)
    end
  end
end