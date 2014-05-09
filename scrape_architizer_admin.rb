require 'mechanize'
require 'csv'
require_relative './architizer_helpers'

class ScrapeArchitectizerAdmin

  include ArchitizerHelpers

  attr_accessor :website_data

  def initialize(username, password, filepath)
    @username = username
    @password = password
    @searches_until_refresh = 100
    search_page = refresh_search_page
    result_hash = execute_searches(search_page, filepath)
    export_csv(result_hash)
    self
  end

  # returns the admin search page
  # search page goes dead soon after 100 queries
  def refresh_search_page
    @agent = Mechanize.new
    menu = login(@agent)
    @searches_until_refresh = 100
    @agent.click(menu.link_with(:href => "/admin/firms/firm/"))
  end

  # if there are many searches that yield no results, all past query params
  # will get stuck in the url
  def soft_refresh_search_page
    @agent.get("http://architizer.com/admin/firms/firm/")
  end

  def login(agent)
    puts "Logging into admin panel..."
    agent.get("http://architizer.com/admin")
    form = agent.page.forms[0]
    form["username"] = @username
    form["password"] = @password
    res = form.submit
    if res.content.match(/Please enter the correct Username and password/i)
      puts "X" * 100
      puts "You have entered an INVALID username and password"
      puts "X" * 100
      raise "You have entered an INVALID username and password"
    else
      puts "Logged In!"
      res
    end
  end

  # returns a hash of result information
  def execute_searches(search_page, filepath)
    puts "searching admin panel for firms provided..."
    website_data = {}
    num = 1
    curr_page = search_page
    ::CSV.foreach(filepath, encoding: 'iso-8859-1:utf-8', headers: true,) do |c|
      print "."
      @searches_until_refresh -= 1
      soft_refresh_search_page if @searches_until_refresh % 4 == 0
      if @searches_until_refresh < 1
        export_csv(website_data, num)
        num += 1
        curr_page = refresh_search_page
      end
      next unless c["Firm Name"]
      search_field = curr_page.form_with(id: "changelist-search")
      unless search_field.nil?
        cleansed_firm_name = clean_firm_name(c["Firm Name"])

        search_field["q"] = cleansed_firm_name
        curr_page = (results_page = search_field.submit)
        any_results = results_page.content.match(/<h4>Nothing found!<\/h4>/).nil?

        website_data[c["Firm Name"]] = { "any_results" => any_results, "results" => [], "other" => (c.fields - [c["Firm Name"]])}
        if any_results
          result_firm_links = results_page.links_with(href: /\/admin\/firms\/firm\/\d+/)
          result_firm_names = result_firm_links.map(&:text)
          website_data[c["Firm Name"]]["results"] += result_firm_names
        end
      else
        website_data[c["Firm Name"]] = { "any_results" => "ERROR", "results" => [] }
      end
    end
    website_data
  end

  # remove general terms from search name that narrow results unnecessarily
  def clean_firm_name(string)
    remove_bad_chars(string.split(" ").reject { |word| is_stop_word?(word) }.compact.join(" "))
  end

  def export_csv(result_hash, num = nil)
    puts "making csv..."
    CSV.open("./table#{'_backup_' + num.to_s if num}.csv", "w") do |f|
      f << %w{Firm_Name Result_True_False Results}
      result_hash.each_pair do |firm_name, res_h|
        f << [firm_name, res_h["any_results"], res_h["results"], *res_h["other"]]
      end
    end
  end
end
