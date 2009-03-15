require 'rubygems'
require 'ferret'
require 'svm'

#replace the one in svm.rb
def _convert_to_svm_node_array(a)  
  data = svm_node_array(a.size + 1)
  svm_node_array_set(data,a.size,-1,0)
  i = 0
  a.each {|x|
    svm_node_array_set(data, i, x, 1)
    i += 1
  }
  return data
end

class FeatureDictionary
  def initialize filename
    @h = {}
    i = 1
    File.open(filename).each_line{ |line|
      @h[line.strip] = i
      i += 1
    }
  end
  
  def [] k
    v = @h[k]
    v ? v : 0
  end
end

class Classifier
  def initialize name
    filename = File.expand_path(File.join(File.dirname(__FILE__), name))
    @feature_dictionary = FeatureDictionary.new(filename + ".dict")
    @model = Model.new(filename + ".model")
  end

  def predict text
    words = tokenize(text)
    features = words.map {|word| @feature_dictionary[word]}
    features.sort!
    features.uniq!
    features.reject! {|x| x == 0}
    @model.predict(features).to_i
  end
  
private
  def tokenize(text)
    result = []
    analyzer = Ferret::Analysis::StandardAnalyzer.new([], true)
    stream = analyzer.token_stream(:nouse, text)
    token = stream.next
    while token
      result << token.text
      token = stream.next
    end
    return result
  end
end

class SpamFilter
  def initialize
    @classifier = Classifier.new "spamfilter"
  end
  
  def is_spam?(text)
    @classifier.predict(text) == 1
  end
end

class SentimentClassifier
  def initialize
    @classifier = Classifier.new "sentiment"
  end
  
  def process text
    sentences = split_sentence(text)
    result = ''
    sentences.each {|s|
      i = @classifier.predict(s)
      result << "<span class='#{int2name(i)}'>#{s}</span>"
    }
    return result
  end

private  

  def split_sentence text
    text.gsub!(/<.*?>/, '') #remove html tag, like <span class='other'>, </span>
    text.gsub!('vs.', 'vs') #the '.' in 'vs.' will fool our sentence spliter  
    text.reverse.split(/(?=(?:\A|\s+)[.!?])/).map { |s|
      s.reverse
    }.reverse
  end
  
  def int2name i
    case i
    when 1 
      'negative'
    when 3
      'positive'
    else
      'other'
    end
  end
end

if $0 == __FILE__
  classifier = Classifier.new "spamfilter"
  p classifier.predict("Getting very excited about the impending trip to the ferret races! And now all planned for term - thanks ms mailmerge!")
  p classifier.predict("Thoughtbot releases update for Paperclip plugin. You can now do things like add rounded corners, invert, rotate and more. http://is.gd/euhE")
  p classifier.predict('Writing test in Rails is a slippery slope. Start w/ Shoulda, then have to modify reg. tests, then need factory_girl, then... etc. etc. etc.')
  
  classifier = SentimentClassifier.new
  p classifier.process('I love it! it rocks!')
  p classifier.process('so ugly, it sucks')
end
 


