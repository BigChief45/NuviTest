A certain URL is an http folder containing a list of zip files. Each zip file contains a bunch of xml files. Each xml file contains 1 news report.


This application downloads all of the zip files, extracts out the xml files, and publishes the content of each xml file to a redis list called “NEWS_XML”.


The application is idempotent. It can be run multiple times and not get duplicate data in the redis list. 