# Rack::I18nLocaleSwitcher

This Rack middleware determines the I18n language from various sources.

A language, or locale, can be encode within an HTTP requests in various ways. Let's have a look at the following request url:

    http://es.example.it/tr/?locale=de

To extract the correct language from such a request, you probably don't want to hardcode it into you application. This middleware extracts the desired locale from this request in the following order:

* request parameter
* url path
* subdomain
* top level domain
* session parameter
* HTTP Accept-language header

Sound's good, gimme the code!

## Rails

    # file application.rb

    require  'rack/i18n_locale_switcher'
    config.middleware.use(Rack::I18nLocaleSwitcher)

Sinatra

    require 'rack/i18n_locale_switcher'
    use Rack::I18nLocaleSwitcher, :i18n_locale_switcher


## Travis Build Status

[![alt text][2]][1]

  [1]: http://travis-ci.org/#!/christoph-buente/rack-i18n_locale_switcher
  [2]: https://secure.travis-ci.org/christoph-buente/rack-i18n_locale_switcher.png
  
  