# Rack::I18nLocaleSwitcher

[![alt text][2]][1]

  [1]: http://travis-ci.org/#!/christoph-buente/rack-i18n_locale_switcher
  [2]: https://secure.travis-ci.org/christoph-buente/rack-i18n_locale_switcher.png

This Rack middleware determines the I18n language from various sources.



A language or locale, can be encode within an HTTP requests in various ways. Let's have a look at the following request url:

    http://es.example.it/tr/?locale=de

To extract the correct language from such a request, you probably don't want to hardcode it into you application. This middleware extracts the desired locale from this request in the following order:

* request parameter (de, german)
* url path (tr, turkish)
* subdomain (es, spanish)
* top level domain (it, italian)
* session parameter (not visible in the url, but could be something completely different)
* HTTP Accept-language header (not visible in the url, but could be something completely different)

Sound's good, gimme the code!

## Rails

    # file application.rb

    require  'rack/i18n_locale_switcher'
    config.middleware.use(Rack::I18nLocaleSwitcher)

## Sinatra

    require 'rack/i18n_locale_switcher'
    use Rack::I18nLocaleSwitcher, :i18n_locale_switcher


Q: Ok, but where does the locale go?

A: The middleware uses the ruby internationalization gem [i18n](http://rubygems.org/gems/i18n), which stores the locale in a variable. You can use this variable in your app as

    I18n.locale

Q: How can I define, which locales are available?

A: You can set the available locales before using instantiation the middleware.

    I18n.available_locales = [:de, :en, :es, :it, :tr ]