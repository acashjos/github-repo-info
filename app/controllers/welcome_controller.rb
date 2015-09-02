require 'nokogiri'
require 'open-uri'

class WelcomeController < ApplicationController
  def index
  end

  # A rest POST endpoint returning JSON
  def get_data
    @resp_data = {}
    @resp_data['url'] = params[:url].gsub(/\/$/, '')
    @resp_data['status'] = false

    begin
      # Check if a repo URL is passed
      if (@resp_data['url']+"/").match("^(http(s)?:\/\/)?([\w]+\.)?github\.com\/(.*)\/(.*)\/$")
        # Create issue url from repo url
        issue_url = @resp_data['url']+'/issues/'
        # Find ISO8601 format date inorder to send with request
        h24 = (Time.now.utc - 24*60*60).iso8601
        d7 = (Time.now.utc - 24*60*60*7).iso8601

        # Scrape open issues
        @data ||= Nokogiri::HTML(open(issue_url))
        open_issues = @data.search('//*[@id="js-issues-toolbar"]//div[contains(@class, "table-list-header-toggle") and contains(@class, "left")]/a[1]').text.gsub('Open', '').squish()

        # Scrape open issues with 24hr
        @data = Nokogiri::HTML(open(URI::encode(issue_url+'?utf8=✓&q=is:issue+is:open+created:>='+h24)))
        open_issue_24h = @data.search('//*[@id="js-issues-toolbar"]//div[contains(@class, "table-list-header-toggle") and contains(@class, "left")]/a[1]').text.gsub('Open', '').squish()

        # Scrape open issues with 7 days
        @data = Nokogiri::HTML(open(URI::encode(issue_url+'?utf8=✓&q=is:issue+is:open+created:<='+d7)))
        open_issue_7d = @data.search('//*[@id="js-issues-toolbar"]//div[contains(@class, "table-list-header-toggle") and contains(@class, "left")]/a[1]').text.gsub('Open', '').squish()

        # Scrape open issues with last 7days and 24hr
        @data = Nokogiri::HTML(open(URI::encode(issue_url+'?utf8=✓&q=is:issue+is:open+created:'+d7+'..'+h24)))
        open_issue_7d_24h = @data.search('//*[@id="js-issues-toolbar"]//div[contains(@class, "table-list-header-toggle") and contains(@class, "left")]/a[1]').text.gsub('Open', '').squish()

        # feed into resp hash
        @resp_data['open_issues'] = open_issues
        @resp_data['open_issues_24h'] = open_issue_24h
        @resp_data['open_issues_7d'] = open_issue_7d
        @resp_data['open_issues_7d_24h'] = open_issue_7d_24h
        @resp_data['status'] = true
      else
        @resp_data['error'] = 'Invalid Github repo URL!'
      end
    rescue => e
      puts e
      @resp_data['error'] = 'scrapping error'
    end

    render json: @resp_data
  end
end
