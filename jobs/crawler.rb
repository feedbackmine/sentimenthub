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

  COLUMNS = [:project_id, :created_at, :description, :url, :polarity, :author_image, :author_name, :author_url, :source, :url_id]

  def initialize
    @logger = Logger.new('log/crawler.log')
    @language_detector = LanguageDetector.new
    @spam_filter = SpamFilter.new
    @sentiment_classifier = SentimentClassifier.new
  end
  
  def crawl project_id, url, use_spam_filter
    @logger.info url
    feedbacks = []
    xml = open(url)
    doc = Nokogiri::HTML(xml)
    doc.xpath("//entry").each do |entry|
      title = entry.at("./title").content
      
      language = @language_detector.detect(title)
      if language != 'en'
        puts "#{language}: #{title}"
        next
      end
      
      if use_spam_filter && @spam_filter.is_spam?(title)
        puts "spam: #{title}"
        next
      end
      
      polarity, content = @sentiment_classifier.process(title)
      published = Time.zone.parse(entry.at("./published").content)
      link = entry.at("./link[@rel='alternate']")["href"]
      author_image = entry.at("./link[@rel='image']")["href"]
      author_name = entry.at("./author/name").content
      author_url = entry.at("./author/uri").content
      
      feedbacks << [project_id, published, content, link, polarity, author_image, author_name, author_url, Feedback::TWITTER, project_id.to_s + link]
    end
    return feedbacks
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
    @logger.info e.message
    @logger.info e.backtrace.join("\n")
    return []
  end
  
  def run projects
    projects.each {|p|
      feedbacks = crawl(p.id, p.crawl_twitter_url, p.use_spam_filter)
      Feedback.import(COLUMNS, feedbacks, {:validate => false, :timestamps => false, :ignore => true}) unless feedbacks.empty?
    }
  end
end

crawler = Crawler.new
if ARGV.length == 0
  crawler.run(Project.find(:all))
else
  projects = []
  ARGV.each {|name| projects << Project.find_by_name(name)}
  crawler.run projects
end
