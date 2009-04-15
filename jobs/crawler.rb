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

  COLUMNS = [:project_id, :created_at, :title, :description, :url, :polarity, :author_image, :author_name, :author_url, :source, :url_id]

  def initialize
    @logger = Logger.new('log/crawler.log')
    @language_detector = LanguageDetector.new
    @spam_filter = SpamFilter.new
    @sentiment_classifier = SentimentClassifier.new
  end
  
  def crawl feedbacks, source, project_id, url, use_spam_filter
    @logger.info url
    xml = open(url)
    doc = Nokogiri::HTML(xml)
    doc.xpath("//entry").each do |entry|
      title = entry.at("./title").content
      content = entry.at("./content").content
      
      language = @language_detector.detect(content)
      if language != 'en'
        puts "#{language}: #{title}"
        next
      end
      
      if use_spam_filter && @spam_filter.is_spam?(content)
        puts "spam: #{title}"
        next
      end
      
      polarity, description = @sentiment_classifier.process(content)
      published = Time.zone.parse(entry.at("./published").content)
      link = entry.at("./link[@rel='alternate']")["href"]
      author_image = entry.at("./link[@rel='image']")["href"] rescue nil
      author_name = entry.at("./author/name").content
      author_url = entry.at("./author/uri").content
      
      feedbacks << [project_id, published, title, description, link, polarity, author_image, author_name, author_url, source, project_id.to_s + link]
    end
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
    @logger.info e.message
    @logger.info e.backtrace.join("\n")
  end
  
  def run projects
    projects.each {|p|
      feedbacks = []
      crawl(feedbacks, Feedback::TWITTER, p.id, p.crawl_twitter_url, p.use_spam_filter)
      crawl(feedbacks, Feedback::BLOG,    p.id, p.crawl_blog_url,    p.use_spam_filter)
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
