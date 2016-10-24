class LinkedState < ActiveRecord::Base
  belongs_to :state, touch: true

  validates_presence_of :state_id, :linked_id
  validates_uniqueness_of :state_id
  validate :not_in_use_check

  def not_in_use_check
    unless Tripnote.where(main_state_id: state_id).empty?
      errors.add(:state_id, "the state you're linking is in use for some Logbooks.")
    end
  end
end
