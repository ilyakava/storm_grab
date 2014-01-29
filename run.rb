require 'nokogiri'
require 'open-uri'
require 'erb'
require 'pry'

module ArchitizerHelpers

  def architizer_queryify(string)
    URI::encode(string.gsub('&', ''))
  end

end

class SearchArchitizer

  include ArchitizerHelpers

  attr_accessor :queries, :website_data

  def initialize(list_queries)
    @queries = list_queries
    @website_data = {}
    scrape_architizer
    export_html
    puts "double click on table.html"
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

class ScrapeArchitects

  include ArchitizerHelpers

  attr_accessor :website_data

  def initialize
    @website_data = {}
    fetch_architects
    self
  end

  def fetch_architects
    scrape_archdaily
  end

  def google_queryify(string)
    URI::encode(string.gsub('&', '') + ' Architizer')
  end

  def scrape_archdaily(last_page = 10)
    @website_data["archdaily"] = {}

    (1..last_page).each do |page_num|
      doc = Nokogiri::HTML(open("http://www.archdaily.com/page/#{page_num}/"))
      # there are many identical nodes for each title, the first of a series of nodes
      # contains architect information, the next identical are discarded, hence the hash
      nodes = doc.css('p.specs > strong > a').reverse
      titles = nodes.map do |node|
        node.parent.parent.parent.parent.children[1].children[1].attributes["title"].value
      end
      names = nodes.map(&:children).map(&:first).map(&:text)
      links = nodes.map do |node|
        node.attributes["href"].value
      end
      nodes.length.times do |i|
        @website_data["archdaily"][titles[i]] = {
          "name" => names[i],
          "google_search" => "https://www.google.com/#q=#{google_queryify(names[i])}",
          "architizer_search" => "http://architizer.com/search/q/q:#{architizer_queryify(names[i])}/",
          "link" => links[i],
          "source" => "archdaily page #{page_num}"
        }
      end
      puts "#{(100 * page_num / last_page.to_f).floor} % of archdaily done"
    end
  end

  def build_html
    ERB.new(File.read("blog_condensation.rhtml"), 0, "", "@html").result binding
  end

  def export_html(outfile_name = "table.html")
    File.open(outfile_name, "w") do |io|
      io << build_html
    end
  end
end

if __FILE__ == $0
  puts "if percentage count stalls, press 'Control+c' and check internet availibility"
  a = ScrapeArchitects.new
  a.export_html
  puts "double click on table.html"
end
