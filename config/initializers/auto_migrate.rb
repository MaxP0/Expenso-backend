# frozen_string_literal: true

# Optional safety valve for platforms where you don't have shell access.
# Enable once (temporarily) via env vars:
#   AUTO_MIGRATE=true
#   AUTO_SEED=true
# Then redeploy. After the DB is initialized, disable these flags.

return unless ENV["AUTO_MIGRATE"] == "true"

# Never run migrations during rake tasks/build steps (e.g. assets:precompile on Render).
# We only want to run this in the actual web process at boot time.
if defined?(Rake) && Rake.respond_to?(:application) && Rake.application&.top_level_tasks&.any?
  return
end

Rails.application.config.after_initialize do
  begin
    require "rake"

    Rails.application.load_tasks

    Rails.logger.info("[auto_migrate] Running db:prepare")
    Rake::Task["db:prepare"].invoke

    if ENV["AUTO_SEED"] == "true"
      Rails.application.eager_load!
      Rails.logger.info("[auto_migrate] Running db:seed")
      Rake::Task["db:seed"].invoke
    end

    Rails.logger.info("[auto_migrate] Done")
  rescue StandardError => e
    Rails.logger.error("[auto_migrate] Failed: #{e.class}: #{e.message}")
    raise
  end
end
