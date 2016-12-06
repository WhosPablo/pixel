module QuestionHelper

  def self.set_headlessness(question, viewer)
    unless question.is_recipient viewer or question.belongs_to viewer
      question.headless = true
      question.user = nil # To avoid a programming error causing a leak of information
    end
    question
  end

end