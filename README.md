RfidScanner
===========

This is designed to run on a Linux system (requires evdev) with multiple USB
HID RFID readers and network connectivity.

It reads RFID tag events off the taggers and logs these events to a remote API.

Installation
------------

* Install ruby, rubygems, and bundler
* Clone this repo and `cd` into it
* `bundle`
* Install non-gem `https://github.com/Spakman/ruby_evdev`:
  `ruby extconf.rb && make && sudo make install`

Local Usage
-----------

* Plug in your USB HID RFID readers.
* To display reads on to STDOUT:

    bin/rfid_scanner --stdout

Remote Server Usage
-------------------

* To log reads to a remote server:

    bin/rfid_scanner --endpoint=http://myapp.whatever.com/api

* The app will register new readers with the server.

* The app will save its reader configuration to `./readers.json`

Server API
----------

* Create a reader:

    POST <endpoint>/readers
    Params: hostname, identifier
    Response Type: application/json
    Response Body: { id: 12345 }
    Response Head: 201 CREATED if creating a new reader record
    Response Head: 201 CREATED if an existing reader record was found

* Create a scan:

    POST <endpoint>/scans
    Params: reader_id, rfid_number, timestamp
    Response Body: None
    Response Head: 201 CREATED

Requests of application/json are accepted.
Param parsing adheres to Rails param parsing.
