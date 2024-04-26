# frozen_string_literal: true

RSpec.describe Bemi::ChangeQueryHelpers do
  after { BemiChange.delete_all }

  describe '#diff' do
    it 'returns the diff between before and after' do
      change = BemiChange.new(before: { name: 'Alice' }, after: { name: 'Bob' })
      expect(change.diff).to eq({ 'name' => ['Alice', 'Bob'] })
    end
  end

  describe '.created' do
    it 'returns changes with CREATE operation' do
      change = BemiChange.create!(operation: 'CREATE')
      expect(BemiChange.created).to include(change)
    end
  end

  describe '.asc' do
    it 'returns changes in ascending order' do
      change1 = BemiChange.create!(committed_at: Time.current)
      change2 = BemiChange.create!(committed_at: 1.day.ago)
      expect(BemiChange.asc).to eq([change2, change1])
    end
  end
end
