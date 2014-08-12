#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'
require 'json'
require 'haml'

def connections_to_array(id, places)
  if places[id]["hasConnectionsWith"].nil?
    return []
  else
    connections = places[id]["hasConnectionsWith"].split(',')
    connections.reject!{|c| c =~ /[^0-9]/} # strip invalid places
    connections.reject!{|c| places[c].nil?} # strip non-existent places
    connections.reject!{|c| c == id}
    return connections.uniq
  end
end

module Haml::Helpers
  def li_connections_for( id, places, walked_ids = [] )
    unless walked_ids.include?(id)
      walked_ids << id
      haml_tag :li do
        haml_tag :a, {href: "http://pleiades.stoa.org/places/#{id}"} do
          haml_concat places[id]["title"]
          haml_concat " - "
          haml_concat id
        end
        haml_concat " (#{places[id]["children"]})" if places[id]["children"] > 0
        connections_to_array(id, places).each do |child|
          haml_tag :ul do
            li_connections_for child, places, walked_ids
          end
        end
      end
    end
  end
end

def walk_connections(id, places, depth = 0, walked_ids = [])
  unless depth > 100
    prefix_string = ""
    depth.times do
      prefix_string += " "
    end

    unless walked_ids.include?(id)
      children = 0
      walked_ids << id
      connections = connections_to_array(id, places)
      connections.each do |connection|
        children += walk_connections(connection, places, depth + 1, walked_ids)
      end

      puts "#{prefix_string}#{id} - #{places[id]["title"]} - #{children}"
      places[id]["children"] = children.to_i
      return children + 1
    end
  end

  return 0
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
  if places[id]["children"] > 0
    places[id]["rootNode"] = true
  end
end

puts

template = IO.read(File.join('pleiades-hierarchical.haml'))
haml_engine = Haml::Engine.new(template, :format => :html5)
open('pleiades-hierarchical.html','w') {|file|
  file.write(haml_engine.render(Object.new, :places => places))
}

# places.sort_by {|k,v| v["children"].nil? ? 0 : v["children"]}.reverse.to_h.each do |k,v|
#   if root_nodes.include?(k)
#     puts "#{k} - #{places[k]["title"]} - #{places[k]["children"]}"
#   end
# end
