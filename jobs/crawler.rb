#!/usr/bin/env ./script/runner

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'language_detector'
require 'ar-extensions/adapters/mysql'
require 'ar-extensions/import/mysql'
require File.dirname(__FILE__) + '/classifier.rb'

class Crawler

  COLUMNS = [:project_id, :created_at, :description, :url]

  def initialize
    @logger = Logger.new('log/crawler.log')
    @language_detector = LanguageDetector.new
    @spam_filter = SpamFilter.new
    @sentiment_classifier = SentimentClassifier.new
  end
  
  def crawl project_id, url
    @logger.info url
    feedbacks = []
    xml = open(url)
    doc = Nokogiri::HTML(xml)
    doc.xpath("//entry").each do |entry|
      title = entry.at("./title").content
      
      next unless @language_detector.detect(title) == 'en'
      next if @spam_filter.is_spam?(title)
      
      content = @sentiment_classifier.process(title)
      published = Time.zone.parse(entry.at("./published").content)
      link = entry.at("./link")["href"]
      
      feedbacks << [project_id, published, content, link]
    end
    return feedbacks
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
    @logger.info e.message
    @logger.info e.backtrace.join("\n")
    return []
  end
  
  def run
    Project.find(:all).each {|p|
      feedbacks = crawl(p.id, p.crawl_url)
      Feedback.import(COLUMNS, feedbacks, {:validate => false, :timestamps => false, :ignore => true}) unless feedbacks.empty?
    }
  end
end

crawler = Crawler.new
crawler.run
