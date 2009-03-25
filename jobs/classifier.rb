require 'rubygems'
require 'tokenizer'
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
    tokenizer = Tokenizer.new(text)
    while token = tokenizer.next
      result << token.downcase
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
  
  OTHER = 0
  POSITIVE = 1
  MIXED = 2
  NEGATIVE = 3
  
  def process text
    number_of_positive = 0
    number_of_negative = 0
    sentences = split_sentence(text)
    result = []
    sentences.each {|s|
      i = @classifier.predict(s)
      result << [i, s]
      number_of_positive += 1 if i == POSITIVE
      number_of_negative += 2 if i == NEGATIVE
    }
    
    if number_of_positive > 0  && number_of_negative == 0
      overall =  POSITIVE
    elsif number_of_positive == 0 && number_of_negative > 0
      overall =  NEGATIVE
    elsif number_of_positive > 0  && number_of_negative > 0
      overall =  MIXED
    else
      overall = OTHER
    end
    
    return [overall, result]
  end

private  

  def split_sentence text
    text.gsub!(/<.*?>/, '') #remove html tag, like <span class='other'>, </span>
    text.gsub!('vs.', 'vs') #the '.' in 'vs.' will fool our sentence spliter  
    text.reverse.split(/(?=(?:\A|\s+)[.!?])/).map { |s|
      s.reverse
    }.reverse
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
 


