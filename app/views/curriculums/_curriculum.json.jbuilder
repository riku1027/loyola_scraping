json.extract! curriculum, :id, :name, :registration_code, :start_time, :period, :teacher, :created_at, :updated_at
json.url curriculum_url(curriculum, format: :json)
