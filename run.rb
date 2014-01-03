require 'nokogiri'
require 'open-uri'
require 'erb'

class ScrapeArchitects

  attr_accessor :website_data

  def initialize
    @website_data = {}
    scrape_archdaily()
    self
  end

  def html_safe(string)
    URI::encode(string.gsub('&', '') + ' Architizer')
  end

  def scrape_archdaily(last_page = 5)
    @website_data["archdaily"] = {}

    (1..last_page).each do |page_num|
      doc = Nokogiri::HTML(open("http://www.archdaily.com/page/#{page_num}/"))
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
          "google_search" => "https://www.google.com/#q=#{html_safe(names[i])}",
          "link" => links[i],
          "source" => "archdaily page #{page_num}"
        }
      end
      puts "#{(100 * page_num / last_page.to_f).floor} % of archdaily done"
    end
  end

  def build_html
    b = binding
    ERB.new(<<-'END_DATA'.gsub(/^\s+/, ""), 0, "", "@html").result b
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
        <body>
          <table>
            <tbody>
              <th>
                <td>Architect Co</td>
                <td>Google Search</td>
                <td>Personal Link</td>
                <td>Project Title</td>
                <td>Source</td>
                <td><%= @website_data.keys.first %></td>
              </th>
              <% @website_data.keys.each do |website| %>
                <% @website_data[website].each_pair do |title, info_hash| %>
                  <tr>
                    <td><%= info_hash["name"] %></td>
                    <td><a target="_blank" href="<%= info_hash["google_search"] %>">Google</a></td>
                    <td><a target="_blank" href="<%= info_hash["link"] %>">Personal</a></td>
                    <td><%= title %></td>
                    <td><%= info_hash["source"] %></td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </table>
        </body>
      <html>
    END_DATA
  end

  def export_html
    File.open("table.html", "w") do |io|
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
