require "spec_helper"

describe "Rack::I18nLocaleSwitcher" do

  before do
    I18n.available_locales = [:en, :'en-US', :de, :'de-DE']
    I18n.default_locale = :en
  end

  def app
    Rack::Builder.new {
      map "/" do
        use Rack::I18nLocaleSwitcher
        run lambda { |env| [200, {}, "Coolness"] }
      end
    }.to_app
  end

  it "should set the locate to default locale" do
    get '/'
    I18n.locale.should eql(I18n.default_locale)
  end

  context 'from request params' do

    it "should set the I18n locale" do
      get '/', :locale => 'de'
      last_request.url.should include('?locale=de')
      I18n.locale.should eql(:de)
    end

    it "should disallow other locales than the available locales" do
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

    before do
      default_host = 'de.example.com'
    end

    xit "should set the I18n locale" do
      get '/'
      I18n.locale.should eql(:de)
    end
  end

  context 'from top level domain' do

    before do
      default_host = 'example.de'

      it "should set the I18n locale" do
        get '/'
        I18n.locale.should eql(:de)
      end
    end


  end

  context 'from accept-language header' do

    it "should override the client requested locale" do
      header "Accept-Language", "de, en"
      get '/'
      I18n.locale.should eql(:de)
    end

  end

  context 'from session' do
    xit "should override the users session locale" do
      request.session['locale'] = :de
      get '/', :locale => 'en'
      I18n.locale.should eql(:en)
    end


  end

  context 'from default' do
  end

end