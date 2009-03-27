class Project < ActiveRecord::Base
  define_index do
    indexes name
    set_property :delta => true
  end
  
  has_many :feedbacks
  
  named_scope :featured, :conditions => {:featured => true}
  
  def crawl_url
    "http://search.twitter.com/search.atom?q=#{name}&rpp=100"
  end
end
