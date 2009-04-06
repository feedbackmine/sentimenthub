class Project < ActiveRecord::Base
  define_index do
    indexes name
    set_property :delta => true
  end
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :feedbacks
  
  named_scope :featured, :conditions => {:featured => true}
  
  def crawl_url
    url = "http://search.twitter.com/search.atom?q=#{name}&rpp=100"
    url += "&phrase=#{CGI.escape(must_have_words)}" unless must_have_words.blank?
    url += "&nots=#{CGI.escape(must_not_have_words)}" unless must_not_have_words.blank?
    url
  end
  
  def to_param  
    name  
  end 
end
