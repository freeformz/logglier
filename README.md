Overview
--------

Send logged messages to Loggly using either the HTTP API or Syslog/UDP.

Can be used in place of Ruby's Logger <http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/>


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
specified. Facilities are just integers from 0 to 23, see <http://www.faqs.org/rfcs/rfc3164.html>


TODO
-----

* key=value Loggly stuff.
* Alternative https implementations (Typheous, Excon, etc). May be
  faster?
* Option to use Syslog TCP inputs. Possibly faster than the https inputs.
* Do logging in a seperate thread. Is this useful? Too complex?
