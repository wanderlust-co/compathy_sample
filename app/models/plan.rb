class Plan < ActiveRecord::Base
  belongs_to :user
  has_many :plan_item_mappings
  has_many :plan_items, through: :plan_item_mappings

  validates_presence_of :user_id
  validates_presence_of :date_from
  validates_presence_of :date_to
  validates_uniqueness_of :public_link_key, allow_nil: true

  # validates :date_to, date: {
  #   # NOTE: as we treat EXIF datetime without timezone, its possible to be differ from real time up to 1 day
  #   after: proc { Time.now - 1.day },
  #   message: "final date must be either now or in the future"
  # }

  # validate :date_from_not_greater_than_date_to

  def date_from_not_greater_than_date_to
    if date_from.present? && date_to.present? && date_from > date_to
      errors.add(:date_from, "initial date must be earlier than final date")
    end
  end

  def is_editable_for?(user)
    (user_id == user.id) || (user.is_employee?)
  end

  def is_accessible_for?(user, key)
    (user.present? && user_id == user.id) ||
      (user.present? && user.is_employee?) ||
      (public_link_key.present? && key == public_link_key)
  end

  def plan_dates
    date_from.upto(date_to).to_a
  end

  def cover_photo_url
    return nil if plan_items.blank?
    # NOTE: want to avoid first spot as it might be an airport of departure
    @cover_photo_url ||= plan_items.to_a.take(3)[-1].spot.state.try(:image_url)
  end

  def gen_public_link_key
    cand = SecureRandom.hex(20)
    while Plan.find_by(public_link_key: cand) do
      cand = SecureRandom.hex(20)
    end
    cand
  end

  def public_link_url
    return nil unless public_link_key
    ENV["CY_FQDN"] + "/sa/plans/#{id}/preview?key=#{public_link_key}"
  end

  def formatted_created_at
    created_at.to_datetime.utc.iso8601.to_s.sub("+00:00", "Z") rescue nil
  end

  def formatted_updated_at
    updated_at.to_datetime.utc.iso8601.to_s.sub("+00:00", "Z") rescue nil
  end
end
