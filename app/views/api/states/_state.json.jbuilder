json.cache! [state, I18n.locale], expires_in: 10.hour do
  json.extract!       state, :id, :cc, :lat, :lng
  json.name           state.trans_name(I18n.locale)
  json.original_name  state.name
  json.logbooks_count state.published_tripnotes_count
end

