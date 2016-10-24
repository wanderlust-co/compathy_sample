class SpotRoute < ActiveRecord::Base
  validates_presence_of :origin_spot_id, :destination_spot_id, :route_path
end

