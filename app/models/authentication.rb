class Authentication < ActiveRecord::Base
  belongs_to :user
  def attr_accessible
    params.require(:authentication).permit(:user_id, :provider, :uid)
  end
end
