class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :tripnote, counter_cache: true, touch: true

  validates :user_id,
    :presence => true,
    :uniqueness => { :scope => :tripnote_id }

  validates_presence_of :tripnote_id

  private
  def destroy_activity
    acts = Activity.where( actv_type: CY_ACTV_TYPE_FAVORITE, actv_id: self.id )
    if acts.present?
      acts.destroy_all
    end
  end
end
