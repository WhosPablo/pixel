class LabelCreator

  def self.generate_labels(text)

    # Create a parser object
    tgr = EngTagger.new

    # Downcase letters after punctuation bc they might be interpreted as pronouns
    text = text.gsub(/(\.|\?|!)\s*([A-Z])+/){ |s| s.downcase }

    # Downcase first letter as its word might be interpreted as a pronoun
    text = text.gsub(/^\s*\S+\s+/){ |s| s.downcase }

    # Get all words from a tagged output
    #TODO look into how to avoid having to filter words with spaces
    words = tgr.get_words(text).select{ | word | !word.include? " "}
    words
  end
end

