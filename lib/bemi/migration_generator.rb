# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

class Bemi
  class MigrationGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    def create_migration_file
      migration_template 'migration.rb.erb', File.join(db_migrate_path, "bemi_migration.rb")
    end

    private

    def migration_version
      "[#{ActiveRecord::VERSION::STRING.to_f}]"
    end
  end
end
