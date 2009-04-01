class Feedback < ActiveRecord::Base
  belongs_to :project
  serialize  :description
  
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
    when 1 
      'negative'
    when 2
      'mixed'
    when 3
      'positive'
    else #0
      'other'
    end
  end
  
  #'msaleem (Muhammad Saleem)' -> msaleem
  def author_id
    author_name.split(' ').first
  end
end
