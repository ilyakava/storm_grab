require 'mechanize'
require 'csv'
require_relative './architizer_helpers'

class ScrapeArchitectizerAdmin

  include ArchitizerHelpers

  attr_accessor :website_data

  def initialize(username, password, filepath)
    @agent = Mechanize.new
    menu = login(username, password)
    search_page = @agent.click(menu.link_with(:href => "/admin/firms/firm/"))
    result_hash = execute_searches(search_page, filepath)
    export_csv(result_hash)
    self
  end

  def login(username, password)
    puts "Logging into admin panel..."
    @agent.get("http://architizer.com/admin")
    form = @agent.page.forms[0]
    form["username"] = username
    form["password"] = password
    res = form.submit
    puts "Logged In!"
    res
  end

  # returns a hash of result information
  def execute_searches(search_page, filepath)
    puts "searching admin panel for firms provided..."
    website_data = {}
    curr_page = search_page
    ::CSV.foreach(filepath, headers: true) do |c|
      print "."
      raise "there is no 'Firm Name' column in the csv you provided, check for extra spaces and typos" unless c["Firm Name"]
      search_field = curr_page.form_with(id: "changelist-search")
      cleansed_firm_name = clean_firm_name(c["Firm Name"])
      search_field["q"] = cleansed_firm_name
      curr_page = (results_page = search_field.submit)
      any_results = results_page.content.match(/<h4>Nothing found!<\/h4>/).nil?

      website_data[c["Firm Name"]] = { "any_results" => any_results, "results" => [] }
      if any_results
        result_firm_links = results_page.links_with(href: /\/admin\/firms\/firm\/\d+/)
        result_firm_names = result_firm_links.map(&:text)
        website_data[c["Firm Name"]]["results"] += result_firm_names
      end
    end
    website_data
  end

  # remove general terms from search name that narrow results unnecessarily
  def clean_firm_name(string)
    string.split(" ").reject { |word| is_stop_word?(word) }.compact.join(" ")
  end

  def export_csv(result_hash)
    puts "making csv..."
    CSV.open("./table.csv", "w") do |f|
      f << %w{Firm_Name Result_True_False}.concat(Array.new(10) { |i| "Result_#{i + 1}"})
      result_hash.each_pair do |firm_name, res_h|
        f << [firm_name, res_h["any_results"], *res_h["results"]]
      end
    end
  end
end
