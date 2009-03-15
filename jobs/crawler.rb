#!/usr/bin/env ./script/runner

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'language_detector'
require File.dirname(__FILE__) + '/classifier.rb'

class Crawler
  def initialize
    @logger = Logger.new('log/crawler.log')
    @language_detector = LanguageDetector.new
    @spamfilter = SpamFilter.new
  end
  
  def crawl url
    p url
    xml = open(url)
    doc = Nokogiri::HTML(xml)
    doc.xpath("//entry").each do |entry|
      title = entry.at("./title").content
      
      next unless @language_detector.detect(title) == 'en'
      next if @spamfilter.is_spam?(title)
      
      published = Time.zone.parse(entry.at("./published").content)
      link = entry.at("./link")["href"]
    end
  rescue Exception => e
    puts e
    @logger.info e.message
    @logger.info e.backtrace.join("\n")
  end
  
  def run
    Project.find(:all).each {|p|
      crawl p.crawl_url
    }
  end
end

crawler = Crawler.new
crawler.run
