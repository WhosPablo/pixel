module CommentHelper

  def self.has_edit_permission(comment, viewer)
    comment.belongs_to viewer or viewer.is_admin
  end

end