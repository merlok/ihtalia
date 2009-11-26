#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'rexml/document'

IP=ARGV[0]

xml_country = Net::HTTP.get_response(URI.parse("http://iwa-wsdl2ruby.heroku.com/api/location.xml?ip=" + IP)).body 
xml_latlon = Net::HTTP.get_response(URI.parse("http://tiw.blogginggeek.com/resources/iwa/ip2geo/getGeoLoc.php?ip=" + IP)).body

doc_country = REXML::Document.new(xml_country)
doc_latlon = REXML::Document.new(xml_latlon)

country = doc_country.elements['countryname'].to_s.gsub(/<(\/|)countryname>/, "")
latitude = doc_latlon.elements['LOCATION/LATITUDE'].to_s.gsub(/<(\/|)LATITUDE>/, "")
longitude = doc_latlon.elements['LOCATION/LONGITUDE'].to_s.gsub(/<(\/|)LONGITUDE>/, "")

puts "Country: #{country} Latitude: #{latitude} Longitude #{longitude}"

puts "http://maps.google.com/maps?q=#{latitude},#{longitude}&iwloc=A&hl=en"
