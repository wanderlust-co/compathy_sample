class UserMailerPreview < ActionsMailer::Preview
  def like_user_review
    UserMailer.like_user_review()
end