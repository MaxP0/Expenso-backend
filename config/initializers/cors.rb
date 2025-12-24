# frozen_string_literal: true

# CORS for separate frontend (React on S3, Vite dev server)
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch(
      "FRONTEND_ORIGIN",
      "http://localhost:5173"
    )

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      max_age: 600
  end
end