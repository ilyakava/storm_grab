require 'nokogiri'
require 'erb'
require_relative './architizer_helpers'
require 'csv'

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

  def scrape_projektydomov(last_page = 50)
    @website_data["projektydomov"] = {}

    (1..last_page).each do |page_num|
      doc = Nokogiri::HTML(open("http://www.projektydomov.eu/en/list-of-companies/architects/#{page_num}/"))
      # there are many identical nodes for each title, the first of a series of nodes
      # contains architect information, the next identical are discarded, hence the hash
      nodes = doc.css('div[itemtype="http://schema.org/Organization"]').reverse
      names = nodes.map do |node|
        node.css('div.txt > h2 > a > span').first.text
      end
      locations = nodes.map do |node|
        node.css('div.txt > p.loc').children.map(&:text).join
      end
      websites = nodes.map do |node|
        node.css('div.txt > ul.list_3 > li > a').text
      end
      emails = nodes.map do |node|
        node.css('div.txt > ul.list_3 > li.l > a').first.attributes["href"].value.sub('mailto:', '')
      end
      nodes.length.times do |i|
        @website_data["projektydomov"][names[i]] = {
          "name" => names[i],
          "google_search" => "https://www.google.com/#q=#{google_queryify(names[i])}",
          "architizer_search" => "http://architizer.com/search/q/q:#{architizer_queryify(names[i])}/",
          "website" => websites[i],
          "location" => locations[i],
          "email" => emails[i],
          "source" => "projektydomov #{page_num}"
        }
      end
      puts "#{(100 * page_num / last_page.to_f).floor} % of projektydomov done"
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

  def export_csv
    @website_data.each_pair do |website, all_data|
      CSV.open("#{website}.csv", 'w:UTF-8') do |f|
        name, data = all_data.first
        f << data.keys
        all_data.each_pair do |name, data|
          f<< data.values.map { |e| e.force_encoding(Encoding.find("UTF-8")) }
        end
      end
    end
  end
end