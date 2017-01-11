class LabelCreator

  def self.generate_labels(text)

    if text and text.is_a? String and text.length > 0

      # Create a parser object
      tgr = EngTagger.new

      # Downcase letters after punctuation bc they might be interpreted as pronouns
      text = text.gsub(/(\.|\?|!)\s*([A-Z])+/){ |s| s.downcase }

      # Downcase first letter as its word might be interpreted as a pronoun
      text = text.gsub(/^\s*\S+\s+/){ |s| s.downcase }

      # Add spaces to periods in the text
      text = text.gsub(/\.\s/ , ' . ')

      # Get all words from a tagged output
      words = tgr.get_words(text)

      #TODO look into how to avoid having to filter words with spaces
      single_word_nouns = words.select{ | word | !word.include? " "}#.keys.each { | w | w.downcase.gsub /\W+/, ' '}
      multiple_words = {}

      words.select{ | word | word.include? " "}.each do | word |
        split_word = word.first.split(" ")
        if split_word.all? { |e| single_word_nouns.include?(e) }
          # split_word.each { | e | single_word_nouns.delete(e) }
          multiple_words[word.first.singularize] = 1
        end
      end

      single_word_singular = {}
      single_word_nouns.keys.each { | key | single_word_singular[key.singularize] = 1}

      multiple_words.merge(single_word_singular)
    end
  end
end

