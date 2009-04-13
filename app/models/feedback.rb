class Feedback < ActiveRecord::Base
  TWITTER = 1

  OTHER    = 0
  NEGATIVE = 1
  MIXED    = 2
  POSITIVE = 3
  
  belongs_to :project
  serialize  :description
  
  named_scope :positive, :conditions => {:polarity => POSITIVE}
  named_scope :negative, :conditions => {:polarity => NEGATIVE}
  named_scope :other,    :conditions => {:polarity => OTHER}
  
  def html_description
    result = ''
    description.each {|s|
      result << "<span class='#{int2name(s[0])}'>#{s[1]}</span>"
    }
    return result 
  end
  
  def text_description
    result = ''
    description.each {|s|
      result << s[1]
    }
    return result 
  end
  
  def reply_url 
    "http://twitter.com/home?status=@#{author_id}"
  end
  
  def author_id
  end
  
private
  def int2name i
    case i
    when NEGATIVE
      'negative'
    when MIXED
      'mixed'
    when POSITIVE
      'positive'
    else
      'other'
    end
  end
  
  #'msaleem (Muhammad Saleem)' -> msaleem
  def author_id
    author_name.split(' ').first
  end
end
