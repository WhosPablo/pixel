module QuestionHelper

  def self.has_view_permission(question, viewer)
    question.is_recipient viewer or question.belongs_to viewer or viewer.is_admin
  end

  def self.has_edit_permission(question, viewer)
    question.belongs_to viewer or viewer.is_admin
  end

end