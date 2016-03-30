json.array!(@clients) do |client|
  json.extract! client, :id, :name, :email, :address, :rut
  json.url client_url(client, format: :json)
end
