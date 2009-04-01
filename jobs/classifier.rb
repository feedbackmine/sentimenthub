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
    @stop_words = read_lines(filename + ".stopwords")
    @phrases = read_lines(filename + ".phrases")
  end

  def predict text
    words = tokenize(text, @stop_words, @phrases)
    features = words.map {|word| @feature_dictionary[word]}
    features.sort!
    features.uniq!
    features.reject! {|x| x == 0}
    @model.predict(features).to_i
  end
  
private
  def tokenize(text, stop_words, phrases)
    result = []
    tokenizer = Tokenizer.new(text)
    while token = tokenizer.next
      token.downcase!
      next if stop_words.has_key?(token)
      result << token
    end
    
    phrases.empty? ? result : resemble_phrases(result, phrases)
  end
  
  def resemble_phrases(words, phrases)
    result = []
    i = 0
    while i < words.length
      three_words_phrase = (i < words.length - 2) ? "#{words[i]} #{words[i+1]} #{words[i+2]}" : nil
      two_words_phrase   = (i < words.length - 1) ? "#{words[i]} #{words[i+1]}" : nil
      if three_words_phrase && phrases.has_key?(three_words_phrase)
        result << three_words_phrase
        i += 3
      elsif two_words_phrase && phrases.has_key?(two_words_phrase)
        result << two_words_phrase
        i += 2
      else
        result << words[i]
        i += 1
      end
    end
    
    return result
  end
  
  def read_lines file
    h = {}
    File.readlines(file).map {|l| h[l.rstrip] = true} if File.exist?(file)
    return h
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
 


