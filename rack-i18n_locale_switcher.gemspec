# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rack-i18n_locale_switcher"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph B\u{fc}nte, Andreas Korth"]
  s.date = "2011-11-24"
  s.description = "Detects the current locale from url, domain, parameter, session or accept header."
  s.email = ["info@christophbuente.de", "andreas.korth@gmail.com"]
  s.extra_rdoc_files = ["lib/rack/i18n_locale_switcher.rb"]
  s.files = ["Rakefile", "lib/rack/i18n_locale_switcher.rb", "spec/i18n_locale_switcher_test.rb", "spec/spec_helper.rb", "Manifest", "rack-i18n_locale_switcher.gemspec"]
  s.homepage = "http://github.com/christoph-buente/rack-i18n_locale_switcher"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rack-i18n_locale_switcher"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "rack-i18n_locale_switcher"
  s.rubygems_version = "1.8.11"
  s.summary = "Detects the current locale from url, domain, parameter, session or accept header."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end
