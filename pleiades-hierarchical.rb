#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'
require 'json'

def walk_connections(id, places, depth = 0, walked_ids = [])
  unless depth > 100
    prefix_string = ""
    depth.times do
      prefix_string += " "
    end

    unless walked_ids.include?(id) || places[id].nil?
      walked_ids << id
      puts "#{prefix_string}#{id} - #{places[id]["title"]}"

      unless places[id]["hasConnectionsWith"].nil?
        connections = places[id]["hasConnectionsWith"].split(',')
        connections.reject{|c| c =~ /[^0-9]/} # strip invalid places
        connections.each do |connection|
          walk_connections(connection, places, depth + 1, walked_ids)
        end
      end
    end
  end
end

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

root_nodes = []
connectionless_nodes = []
childless_nodes = []
parentless_nodes = []
places.each_key do |id|
  if places[id]["connectsWith"].nil?
    parentless_nodes << id
    if places[id]["hasConnectionsWith"].nil?
      connectionless_nodes << id
    else
      root_nodes << id
    end
  end
  if places[id]["hasConnectionsWith"].nil?
    childless_nodes << id
  end
end

$stderr.puts root_nodes.length
$stderr.puts connectionless_nodes.length
$stderr.puts childless_nodes.length
$stderr.puts parentless_nodes.length
$stderr.puts places.size
$stderr.puts

root_nodes.each do |id|
  walk_connections(id, places)
end
