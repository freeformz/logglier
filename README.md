Overview
--------

Send logged messages to Loggly using either the HTTP API or Syslog/UDP.

Can be used in place of Ruby's Logger (<http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/>)

In fact, it (currently) returns an instance of Logger.

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
To make sure the http client doesn't block too long read_timeout and
open_timeout are set to 2 seconds by default. This can be overridden
like so:

    Logglier.new(:input_url => 'https://logs.loggle.com/inputs/<id>',
                 :read_timeout => <#>,
                 :open_timeout => <#> )

### Syslog TCP/UDP Inputs

    Logglier.new('[udp|tcp]://<hostname>:<port>/<facility>')

The facility is optional and defaults to 16 (local0) if none is
specified. Facilities are just integers from 0 to 23, see <http://www.faqs.org/rfcs/rfc3164.html>


Logging
-------

Logglier.new returns a ruby Logger object, so take a look at:

http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/

The Logger's logdev has some special format handling though.

### Logging a string

    log.warn "test"

Will produce the following log message in Loggly:

    "<Date> severity=WARN, test"

### Logging a Hash

    log.warn :boom => :box, :bar => :soap

Will produce the following log message in Loggly:

    "<Date> severity=WARN, boom=box, bar=soap"


TODO
-----

* Alternative https implementations (Typheous, Excon, etc). May be
  faster?
* Do logging in a seperate thread. Is this useful? Too complex?
