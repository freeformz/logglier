Overview
--------

Posts Logger messages to Loggly using the HTTP API.


Usage
-----

require 'logger'
require 'logglier'

log = Logger.new(Logglier.new(<INPUT URL>))

log.info("hello from logglier")


TODO
-----

* Alternative https implementations (Typheous, Excon, etc). May be
  faster?
* Option to use Syslog (via UDP and/or TCP) inputs. Possibly faster than
  the https inputs.
* Do logging in a seperate thread. Is this useful? Too complex?
