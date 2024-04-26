# frozen_string_literal: true

RSpec.describe Bemi::RecordQueryHelpers do
  after { BemiChange.delete_all }

  describe '#bemi_changes' do
    it 'returns the changes for the record' do
      todo = Todo.create!(task: 'Buy milk', completed: false)
      change = BemiChange.create!(
        table: 'todos',
        primary_key: todo.id,
        committed_at: Time.current,
        operation: 'CREATE',
        before: {},
        after: { task: 'Buy milk', completed: true },
        context: { user_id: 1 },
      )

      expect(todo.bemi_changes).to eq([change])
    end
  end
end
