module CyValidateHelper
  def cy_image_url_format
    /\A(|(https?:)?\/\/.+\..+\/.+)\Z/
  end
end

