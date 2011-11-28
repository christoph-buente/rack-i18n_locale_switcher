# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-i18n_locale_switcher}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph B\303\274nte, Andreas Korth"]
  s.date = %q{2011-11-29}
  s.description = %q{Detects the current locale from query parameter, path prefix, host or accept header.}
  s.email = ["info@christophbuente.de", "andreas.korth@gmail.com"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "lib/rack/i18n_locale_switcher.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README.md", "Rakefile", "lib/rack/i18n_locale_switcher.rb", "rack-i18n_locale_switcher.gemspec", "spec/rack/i18n_locale_switcher_spec.rb"]
  s.homepage = %q{http://github.com/christoph-buente/rack-i18n_locale_switcher}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rack-i18n_locale_switcher", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-i18n_locale_switcher}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Detects the current locale from query parameter, path prefix, host or accept header.}

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
