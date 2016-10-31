class UserMailer < ActionMailer::Base
  # NOTE: Should put `delay` between receiver and method when calling asynchronously method for UserMailer.
  def welcome( user )
    @user = user

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "welcome", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.welcome.subject")
        ) do |format|
      format.html { render layout: "tmp_user_mailer" }
    end
  end

  # ユーザ登録時に、既に登録していたFacebook 上の友人がいれば、その友人に「あなたが登録しているCompathy にこの人も始めたよ!」とお知らせする
  def friend_start_compathy( user, started_friend )
    @user           = user
    @started_friend = started_friend

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "friend_start_compathy", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.friend_start_compathy.subject",
                          started_friend_name: @started_friend.name), &:html
        )
  end

  # Facebook 上の友人がログブックを作ったらお知らせする
  def friend_create_tripnote( user, created_friend, tripnote )
    @user           = user
    @tripnote       = tripnote
    @created_friend = created_friend

    headers["X-SMTPAPI"] = JSON.generate( { category: "friend_create_tripnote" }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.friend_create_tripnote.subject",
                         tripnote_title: @tripnote.title,
                         created_friend_name: @created_friend.name ), &:html
        )
  end

  # ログブックがお気に入りされたら、作者にお知らせする
  def favorite_tripnote( user, faved_user, tripnote )
    @user        = user
    @faved_user  = faved_user
    @tripnote    = tripnote

    # NOTE: the category name is pretty strange but used in SendGrid Category...
    headers["X-SMTPAPI"] = JSON.generate( { category: [ "store_bookmark", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.favorite_tripnote.subject",
                          faved_user_name: @faved_user.name,
                          tripnote_title: @tripnote.title ), &:html
        )
  end

  # ログブック内のエピソードに行ってみたいが押された場合、エピソード作者にお知らせする (スポットが紐付いている場合)
  def like_user_review( user, liked_user, user_review )
    @user        = user
    @liked_user  = liked_user
    @user_review = user_review
    @tripnote    = user_review.tripnote
    @spot        = user_review.spot     if user_review.spot_id

    # NOTE: the category name is pretty strange but used in SendGrid Category...
    headers["X-SMTPAPI"] = JSON.generate( { category: [ "like_to_user_review", "retention_mail" ]  }, indent: " " )
    set_locale(@user)

    if @spot
      subject = "hoge"
    end

    mail( to: @user.email, subject: subject) { |format| format.html { render layout: "mailer" } }
    # binding.pry
  end

  # ログブック自体にコメントがついた場合に、作者にお知らせする
  def add_comment_to_tripnote( user, commented_user, tripnote )
    @user           = user
    @commented_user = commented_user
    @tripnote       = tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "comment", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.add_comment_to_tripnote.subject",
                          commented_user_name: @commented_user.name,
                          tripnote_title: @tripnote.title ), &:html
        )
  end

  # エピソード自体にコメントがついた場合に、作者にお知らせする
  def add_comment_to_user_review( user, commented_user, user_review )
    @user           = user
    @commented_user = commented_user
    @user_review    = user_review
    @tripnote       = user_review.tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "comment", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.add_comment_to_user_review.subject",
                          commented_user_name: @commented_user.name,
                          tripnote_title: @tripnote.title ), &:html
        )
  end

  # 自分が投稿したエピソードと同じスポットが投稿されたときにお知らせする
  def got_user_review_for_reviewed_spot( user, tripnote, user_review )
    @user               = user
    @user_review        = user_review
    @spot               = user_review.spot
    @just_reviewed_user = user_review.user
    @tripnote           = tripnote

    # NOTE: using old category name "same_spot_to_tripnote" for marketing categorization
    headers["X-SMTPAPI"] = JSON.generate( { category: [ "same_spot_to_tripnote", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.got_user_review_for_reviewed_spot.subject",
                          just_reviewed_user_name: @just_reviewed_user.name)
        ) { |format| format.html { render layout: "mailer" } }
  end

  # 行ってみたい! リストに入っているスポットに関するエピソードが追加されたときにお知らせする
  def got_user_review_for_bookmarked_spot( bookmarking_user, tripnote, user_review )
    @user               = bookmarking_user
    @tripnote           = tripnote
    @user_review        = user_review
    @spot               = user_review.spot
    @just_reviewed_user = user_review.user

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "update_about_bookmarked_spot", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.got_user_review_for_bookmarked_spot.subject",
                         just_reviewed_user_name: @just_reviewed_user.name)
        ) { |format| format.html { render layout: "mailer" } }
  end

  # 自分がコメントしたエピソードに作者からコメントがついたらお知らせする
  def to_commenter_of_user_review_from_owner( user, user_review, comment )
    @user        = user
    @user_review = user_review
    @comment     = comment
    @tripnote    = @user_review.tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "to_commenter_from_owner", "to_commenter", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.to_commenter_of_user_review_from_owner.subject"), &:html
        )
  end

  # 自分がコメントしたエピソードに他の人のコメントがついたらお知らせする
  def to_commenter_of_user_review_from_other( user, user_review, comment )
    @user           = user
    @user_review    = user_review
    @comment        = comment
    @tripnote       = @user_review.tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "to_commenter_from_other", "to_commenter", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.to_commenter_of_user_review_from_other.subject",
                            commented_user_name: @comment.user.name,
                            tripnote_owner_name: @tripnote.user.name), &:html
        )
  end

  # 自分がコメントしたログブックに作者からコメントがついたらお知らせする
  def to_commenter_of_tripnote_from_owner( user, tripnote, comment )
    @user     = user
    @comment  = comment
    @tripnote = tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "to_commenter_from_owner", "to_commenter", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.to_commenter_of_tripnote_from_owner.subject"), &:html
        )
  end

  # 自分がコメントしたログブックに他の人のコメントがついたらお知らせする
  def to_commenter_of_tripnote_from_other( user, tripnote, comment )
    @user           = user
    @comment        = comment
    @tripnote       = tripnote

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "to_commenter_from_other", "to_commenter", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
         subject: I18n.t("user_mailer.to_commenter_of_tripnote_from_other.subject",
                         commented_user_name: @comment.user.name,
                         tripnote_owner_name: @tripnote.user.name), &:html
        )
  end

  # ログブックのPVが一定数に達したら「おめでとう」というお知らせをする
  def arrival_target_value( user, tripnote, pv )
    @user     = user
    @tripnote = tripnote
    @pv       = pv

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "access_count_arrival_mail", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.arrival_target_value.subject",
                          tripnote_title: @tripnote.title,
                          pv: @pv ), &:html
        )
  end

  # 直近2週間で初めてトップコレクターズに選ばれたら、一番順位が高いランキングに対しておめでとうと言う
  def user_ranking_rankedin( user, order, rank )
    @user  = user
    @order = order
    @rank  = rank

    headers["X-SMTPAPI"] = JSON.generate( { category: [ "user_ranking_rankedin", "retention_mail" ] }, indent: " " )
    set_locale(@user)

    mail( to: @user.email,
          subject: I18n.t("user_mailer.user_ranking_rankedin.subject"), &:html
        )
  end

private
  def set_locale(user)
    case user.locale
    when /^ja/
      I18n.locale = :ja
    else
      I18n.locale = :en
    end
  end
end
