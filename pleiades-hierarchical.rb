#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'
require 'json'

places_csv, names_csv, locations_csv = ARGV

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