require 'rubygems'
require 'ferret'
require 'svm'

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
    p features
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

if $0 == __FILE__
  classifier = Classifier.new "spamfilter"
  p classifier.predict("Getting very excited about the impending trip to the ferret races! And now all planned for term - thanks ms mailmerge!")
  p classifier.predict("Thoughtbot releases update for Paperclip plugin. You can now do things like add rounded corners, invert, rotate and more. http://is.gd/euhE")
end
 


