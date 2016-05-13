A certain URL is an http folder containing a list of zip files. Each zip file contains a bunch of xml files. Each xml file contains 1 news report.

This application downloads all of the zip files, extracts out the xml files, and publishes the content of each xml file to a redis list called “NEWS_XML”.

The application is idempotent. It can be run multiple times and not get duplicate data in the redis list.

_**NOTE:** `'NEWS_XML'` (the name originally given to me in the e-mail) is an invalid list name for redis, the list name must be in lowercase letters._

## Environment Information
I wrote and tested this Ruby application in a **Ubuntu 14.04.3 trusty** environment, using **Ruby 2.3.0**.

## Dependencies
This application makes use of the following libraries and gems:
- `open_uri`: For downloading the .zip files from the HTTP server
- [rubyzip](https://github.com/rubyzip/rubyzip): Gem for accessing the .zip file contents using Ruby
- [redis-rb](https://github.com/redis/redis-rb): Redis client gem for Ruby.
- [nokogiri](http://www.nokogiri.org/): HTML Parsing gem

## Redis
Some useful Redis commands:

- `LLEN <list>`: Check length of a list
- `DEL <key>`: Delete a list