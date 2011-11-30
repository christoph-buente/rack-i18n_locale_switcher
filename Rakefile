#coding:utf-8
require 'rake'
require 'echoe'

Echoe.new('rack-i18n_locale_switcher', '0.5.2') do |p|

 p.description = "Detects the current locale from query parameter, path prefix, host or accept header."
 p.url         = "http://github.com/christoph-buente/rack-i18n_locale_switcher"
 p.author      = ["Christoph Bünte", "Andreas Korth"]
 p.email       = ["info@christophbuente.de", "andreas.korth@gmail.com"]

 p.retain_gemspec = true

 p.ignore_pattern = %w{
   Gemfile
   Gemfile.lock
   vendor/**/*
   tmp/*
   log/*
   *.tmproj
 }

 p.runtime_dependencies     = [ "rack", "i18n" ]
 p.development_dependencies = [ "echoe", "rspec", "rack-test" ]
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
 spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
 spec.pattern = 'spec/**/*_spec.rb'
 spec.rcov = true
end

task :default => :spec