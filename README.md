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


Input URLs
-------

### HTTP Inputs
    Logglier.new('https://logs.loggly.com/inputs/<id>')

The id is provided by loggly, look at the input's details page

### Syslog UDP Inputs

    Logglier.new('udp://<hostname>:<port>/<facility>')

The facility is optional and defaults to 16 (local0) if none is
specified.


TODO
-----

* key=value Loggly stuff.
* Alternative https implementations (Typheous, Excon, etc). May be
  faster?
* Option to use Syslog TCP inputs. Possibly faster than the https inputs.
* Do logging in a seperate thread. Is this useful? Too complex?
