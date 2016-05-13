#!/usr/bin/env ruby

require 'open-uri'
require 'zip'
require "redis"
require "nokogiri"

# For recording running time
beginning_time = Time.now

# Redis list to push
# NOTE: 'NEWS_XML' (the name originally given to me in the e-mail) is an invalid list name for redis.
# The list name must be in lowercase letters
REDIS_LIST = 'news_xml'

BASE_URL = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts'

# Initiate localhost Redis connection
# If you need to connect to a remote server or a different port:
# redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)
redis = Redis.new

# IDEMPOTENCY!: Clear list, if exists
redis.del(REDIS_LIST)

# Get the HTTP server .zip files directory page HTML content
zip_directories_html = open(BASE_URL, 'rb').read

# Now we can use Nokogiri gem to parse the HTML and obtain each href value
# This is not the approach I had in mind but I couldn't find a way to
# iterate through al files in the HTTP server directory using open-uri.
zip_files = []
zip_directories_html.each_line do |line|
    line_data = Nokogiri::HTML(line)
    href_value = line_data.xpath('//@href')
    
    # Add the .zip file name to our array
    zip_files.push(href_value.text) if href_value.text.include? ".zip"
end

# Iterate through our zip file names array
zip_files.each do |z|
    # Download the Zip file using Open-URI and keep it in memory
    puts "Downloading #{z} ..."
    zip_file = open("#{BASE_URL}/#{z}", "rb")
    
    # Open the zip file and iterate over each XML file
    puts "Opening #{z} ..."
    Zip::File.open(zip_file) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
            puts "Sending contents of file #{entry.name} to Redis list '#{REDIS_LIST}'..."
        
            # Read XML file (entry) contents into memory
            xml_content = entry.get_input_stream.read
            
            # Push it to the redis list
            redis.lpush(REDIS_LIST, xml_content)
        end
    end
    
    # Finally, close the current .zip file
    zip_file.close
end

end_time = Time.now
puts "Task finished. Total time elapsed: #{(end_time - beginning_time)*1000} milliseconds"