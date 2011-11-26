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
    get 'http://example.com/some/path'
    I18n.locale.should eql(I18n.default_locale)

    get 'http://www.example.com/'
    I18n.locale.should eql(I18n.default_locale)
  end
  
  it "should not accept invalid options" do
    expect { 
      Rack::I18nLocaleSwitcher.new('app', :not_an_option => 'foo') 
    }.to raise_error(ArgumentError, "Invalid option(s) :not_an_option")
  end
  
  context 'with custom sources' do
    
    let :options do
      { :source => [ :header, :host ] }
    end
    
    it "should honor the sequence" do
      get 'http://de.example.com' , {}, {'HTTP_ACCEPT_LANGUAGE' => "es"}
      I18n.locale.should eql(:es)

      get 'http://de.example.com' , {}, {'HTTP_ACCEPT_LANGUAGE' => "foo"}
      I18n.locale.should eql(:de)

      get 'http://de.example.com'
      I18n.locale.should eql(:de)
    end

    it "should ignore other sources" do
      get 'http://example.com?locale=de'
      I18n.locale.should eql(:en)

      get 'http://example.com/de'
      I18n.locale.should eql(:en)
    end
  end

  context 'request param' do

    it "should set the locale" do
      get 'http://example.com?locale=de'
      I18n.locale.should eql(:de)

      get 'http://example.com?locale=en-US'
      I18n.locale.should eql(:'en-US')

      get 'http://example.com/some/path?foo=bar&locale=es&param=value'
      I18n.locale.should eql(:es)
    end

    it "should not set an unavailable locale" do
      get 'http://example.com?locale=xx'
      I18n.locale.should eql(I18n.default_locale)
    end
    
    context 'name' do
      
      let :options do
        { :param => 'lang' }
      end
      
      it "should be configurable" do
        get 'http://example.com?lang=de'
        I18n.locale.should eql(:de)
      end
    end
  end

  context 'from path prefix ' do

    it "should set the I18n locale" do
      get 'http://example.com/de/some/path/'
      I18n.locale.should eql(:de)

      get 'http://example.com/en-us'
      I18n.locale.should eql(:'en-US')
    end
  end

  context 'from host' do

    it "should set the I18n locale" do
      get 'http://de.example.com/'
      I18n.locale.should eql(:de)

      get 'http://de-de.example.com/'
      I18n.locale.should eql(:'de-DE')
    end
  end

  context 'from accept-language header' do

    it "should override the client requested locale" do
      get 'http://example.com' , {}, {'HTTP_ACCEPT_LANGUAGE' => "de-de,de,en;q=0.5"}
      I18n.locale.should eql(:'de-DE')

      get 'http://example.com' , {}, {'HTTP_ACCEPT_LANGUAGE' => "en;q=0.5,en-US;q=0.8,es;q=0.7"}
      I18n.locale.should eql(:'en-US')
    end
  end
end