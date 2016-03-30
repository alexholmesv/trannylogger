json.array!(@translators) do |translator|
  json.extract! translator, :id, :name, :email
  json.url translator_url(translator, format: :json)
end
