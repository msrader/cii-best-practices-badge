# frozen_string_literal: true
# require 'json' # uncomment if you need to access GitHub
require 'nokogiri'
require 'open-uri'
# WARNING: The JSON parser generates a 'normal' Ruby hash.
# Be sure to use strings, NOT symbols, as a key when accessing JSON-parsed
# results (because strings and symbols are distinct in basic Ruby).

class BuildDetective < Detective
  # Individual detectives must identify their inputs, outputs
  INPUTS = %i(repo_url).freeze  # Input Hash required for Search
  OUTPUTS = [].freeze # Output Hash required to set database values.  Please see
  # database schema for allowed valuses to be set.
  # Setup and major work goes here.  Do not attempt to return anything from this
  # part of the code as it causes crashes.
  puts "I got here"

  def analyze(_evidence, current)
    repo_url = current[:repo_url]
    @doc = Nokogiri::HTML(open(repo_url))
    return {} if repo_url.blank?
    @results = {}

    @doc.css('a').each do |link|
      if link['href'] =~ /CMakeLists.txt/
        puts "**********\nFound Makefile\n************"
      end
    end
    if @doc.xpath('CMakeLists.txt').blank?
      puts "No Joy"
    else
      puts "Found CMakeLists"
    end
    {


      # Your return has to go here.  This reformats the hashed return into
      # chief understands.  Remember the output must corrospond to one of the
      # values in the database structure.
      # Typically This would be in the form.

      # {
      #  value: 'Met',  # or Unmet
      #  confidence: 3, # or what ever you think it should be.
      #  explanation: "My Text to appear in the evidence field"
      # }
    }
  end
end
