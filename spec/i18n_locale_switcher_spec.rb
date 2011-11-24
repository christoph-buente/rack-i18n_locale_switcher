require "spec_helper"

describe "Rack::I18nLocaleSwitcher" do

  def app
    Rack::Builder.new {
      map "/" do
        use Rack::I18nLocaleSwitcher
        run lambda { |env| [200, {}, "Coolness"] }
      end
    }.to_app
  end


  it "should detect locale from Accept-Language-Header" do
    get '/', {'Accept-Language' => 'en-US, en'}
    I18n.locale.should == :en
  end



end