# frozen_string_literal: true

# Optional safety valve for platforms where you don't have shell access.
# Enable once (temporarily) via env vars:
#   AUTO_MIGRATE=true
#   AUTO_SEED=true
# Then redeploy. After the DB is initialized, disable these flags.

return unless ENV["AUTO_MIGRATE"] == "true"

begin
  require "rake"

  Rails.application.load_tasks

  Rails.logger.info("[auto_migrate] Running db:prepare")
  Rake::Task["db:prepare"].invoke

  if ENV["AUTO_SEED"] == "true"
    Rails.logger.info("[auto_migrate] Running db:seed")
    Rake::Task["db:seed"].invoke
  end

  Rails.logger.info("[auto_migrate] Done")
rescue StandardError => e
  Rails.logger.error("[auto_migrate] Failed: #{e.class}: #{e.message}")
  raise
end
