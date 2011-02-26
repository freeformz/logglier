Overview
--------

Posts Logger messages to Loggly using the HTTP API.


Usage
-----

  require 'logglier'

  log = Logglier.new(<INPUT URL>)

  log.info("hello from logglier")


### With Rails

config/environments/production.rb

  RailsApplication::Application.configure do
    config.logger = Logglier.new(<INPUT URL>)
  end


TODO
-----

* Alternative https implementations (Typheous, Excon, etc). May be
  faster?
* Option to use Syslog (via UDP and/or TCP) inputs. Possibly faster than
  the https inputs.
* Do logging in a seperate thread. Is this useful? Too complex?
