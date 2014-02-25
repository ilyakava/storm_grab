require 'nokogiri'
require 'erb'
require 'csv'
require_relative './architizer_helpers'

class SearchArchitizer

  include ArchitizerHelpers

  attr_accessor :website_data

  def initialize(list_queries, csv = false)
    # sanitize queries a little bit
    @queries = list_queries.map { |query| query.gsub(/\s+/, ' ').gsub(/\[|\]/, '') }
    @website_data = {}
    scrape_architizer
    if csv
      export_csv
      puts "double click on table.csv"
    else
      export_html
      puts "double click on table.html"
    end
    nil
  end

  def build_html
    ERB.new(File.read("auto_searcher.rhtml"), 0, "", "@html").result binding
  end

  def export_html(outfile_name = "table.html")
    File.open(outfile_name, "w") do |io|
      io << build_html
    end
  end

  def export_csv(outfile_name = "table.csv")
    CSV.open(outfile_name, "w") do |io|
      io << ['Architect Co', 'Architizer Search', 'Found']
      @website_data.each_pair do |arch_co, values|
        found_bool = values["results?"] ? 'Found' : 'NOT FOUND'
        io << [arch_co, values["architizer_search"], found_bool]
      end
    end
  end

  def scrape_architizer
    @queries.each_with_index do |query, idx|
      request_url = "http://architizer.com/search/q/q:#{architizer_queryify(query)}/"
      response = Nokogiri::HTML(open(request_url))
      no_result_node = response.css('div.no-results')
      @website_data[query] = {
        "architizer_search" => request_url,
        "results?" => no_result_node.empty?
      }
      puts "#{(100.0 * idx / @queries.length).ceil}% done"
    end
  end
end