require 'sqlite3'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ':memory:')
ActiveRecord::Schema.define do
  create_table :todos, force: true do |t|
    t.string :task
    t.boolean :completed
  end

  create_table :changes, force: true do |t|
    t.string :table
    t.string :primary_key
    t.datetime :committed_at
    t.string :operation
    t.json :before
    t.json :after
    t.json :context
  end
end

class BemiChange < ActiveRecord::Base
  include Bemi::ChangeQueryHelpers
  self.table_name = 'changes'
end

class Todo < ActiveRecord::Base
  include Bemi::RecordQueryHelpers
  bemi_change_class 'BemiChange'
end
