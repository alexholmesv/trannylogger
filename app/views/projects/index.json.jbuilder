json.array!(@projects) do |project|
  json.extract! project, :id, :client_id, :name, :date_received, :words, :rate, :extras, :total
  json.url project_url(project, format: :json)
end
