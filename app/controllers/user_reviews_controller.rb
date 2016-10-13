class UserReviewsController < ApplicationController
  def new
    @user_review = UserReview.new
  end

  def create
    @user_review = UserReview.new(user_review_params)

    respond_to do |format|
      if @user_review.save
        user_photo = UserPhoto.create(id: @user_review.id)

        # 画像のアップロード対応
        if params[:images]
          params[:images].each { |image|
            user_photo.image = image
            user_photo.save
          }
        end

        # format.html { redirect_to @article, notice: 'Article was successfully created.' }
        # format.json { render :show, status: :created, location: @article }
      else
        # format.html { render :new }
        # format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def user_review_params
    params.require(:user_review).permit(:body, :image)
  end
end
