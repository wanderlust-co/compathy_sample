module CyUrlEncoder
  def cy_url_encode( str )
    # NOTE: ignore "%" in order to avoid problem of double encode
    URI::encode( str.downcase.strip.
                  delete('[]{}<>.*@"\'/$#!?=|`\\:;').
                  gsub('&','-').
                  gsub(/\s+/,'-').
                  squeeze("-") )
  end
end