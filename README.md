ScanLogger
==========

This is designed to run on a Linux system (requires evdev) with multiple USB
HID RFID readers and network connectivity.

It reads RFID scans off the readers and logs these to a remote API.

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

    bin/scan_logger

Remote Server Usage
-------------------

* Plug in your USB HID RFID readers.
* To log reads to a remote server:

    bin/scan_logger http://myapp.whatever.com/api

* The app will register new readers with the server.
* The app will save its reader configuration to `./readers.json`

Server API
----------

The API endpoint you specify should support the following subpaths.  For
example, if you specify http://app.com/api, then you should support
`POST http://app.com/api/readers`.

* Create a reader:

    POST <endpoint>/readers
    Accept: multipart/form-data
    Params: hostname, identifier
    Response Type: text/plain
    Response Body: 12345 (the id of the newly created reader)
    Response Head: 201 CREATED if creating a new reader record
    Response Head: 201 CREATED if an existing reader record was found

* Create a scan:

    POST <endpoint>/scans
    Accept: multipart/form-data
    Params: reader_id, rfid_number, timestamp
    Response Body: None
    Response Head: 201 CREATED

TODO
====

* Sometimes it wedges, and I'm not sure why.  I think it only happens when
unplugging/replugging a lot, but I should test that it works fine with lots of
scans.  Once it wedges, `kill -TTIN _PID_` to get it to dump Thread backtraces.
