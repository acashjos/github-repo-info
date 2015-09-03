require 'json'
require 'net/http'
require 'uri'

class WelcomeController < ApplicationController
  def index
  end

  # A REST POST type endpoint returning JSON
  def get_data
    resp_data = {}
    resp_data['url'] = params[:url].gsub(/\/$/, '')
    resp_data['status'] = false

    begin
      # Check if a repo URL is passed
      if (resp_data['url']+"/").match("^(http(s)?:\/\/)?([\w]+\.)?github\.com\/(.*)\/(.*)\/$")
        # Get repo name from URL
        repo_name = resp_data['url'].gsub(/(http(s)?:\/\/)?([\w]+\.)?github\.com\//, "")
        # Generate API URL
        url = "https://api.github.com/search/issues?q=repo:"+repo_name+'+state:open'
        # Find ISO8601 format date inorder to send with request
        h24 = (Time.now.utc - 24*60*60).iso8601
        d7 = (Time.now.utc - 24*60*60*7).iso8601

        # Scrape open issues
        response = Net::HTTP.get_response(URI.parse(url))
        open_issues = JSON.load(response.body)['total_count'].to_i

        # Scrape issues opened in last 24hrs
        response = Net::HTTP.get_response(URI.parse(URI::encode(url+'+created:>='+h24)))
        open_issue_24h = JSON.load(response.body)['total_count'].to_i

        # Scrape issues opened in last 7days
        response = Net::HTTP.get_response(URI.parse(URI::encode(url+'+created:<='+d7)))
        open_issue_7d = JSON.load(response.body)['total_count'].to_i

        # Scrape open issues within last 7days and 24hr
        response = Net::HTTP.get_response(URI.parse(URI::encode(url+'+created:'+d7+'..'+h24)))
        open_issue_7d_24h = JSON.load(response.body)['total_count'].to_i

        # feed into resp hash
        resp_data['open_issues'] = open_issues
        resp_data['open_issues_24h'] = open_issue_24h
        resp_data['open_issues_7d'] = open_issue_7d
        resp_data['open_issues_7d_24h'] = open_issue_7d_24h
        resp_data['status'] = true
      else
        resp_data['error'] = 'Invalid Github repo URL!'
      end
    rescue => e
      puts e
      resp_data['error'] = 'scrapping error'
    end

    render json: resp_data
  end
end
