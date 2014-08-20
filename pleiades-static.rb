#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'
require 'json'
require 'haml'

places_csv, names_csv, locations_csv = ARGV

def render_place(place)
  template = IO.read(File.join('pleiades-static-place.haml'))
  $haml_engine ||= Haml::Engine.new(template, :format => :html5)
  open("places/#{place['id']}.html",'w') {|file|
    file.write($haml_engine.render(Object.new, :place => place))
  }
end

places = {}
$stderr.puts "Parsing places..."
CSV.foreach(places_csv, :headers => true) do |row|
  places[row["id"]] = row.to_hash
end

$stderr.puts "Parsing names..."
CSV.foreach(names_csv, :headers => true) do |row|
  unless places[row["pid"]].nil?
    places[row["pid"]]["names"] ||= []
    places[row["pid"]]["names"] << row.to_hash
  end
end

$stderr.puts "Parsing locations..."
CSV.foreach(locations_csv, :headers => true) do |row|
  unless places[row["pid"]].nil?
    places[row["pid"]]["locations"] ||= []
    places[row["pid"]]["locations"] << row.to_hash
  end
end

$stderr.puts "Writing HTML output..."
places.each_key do |id|
  render_place(places[id])
end