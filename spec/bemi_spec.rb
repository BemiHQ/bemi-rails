# frozen_string_literal: true

RSpec.describe Bemi do
  describe '.set_context' do
    it 'sets the context' do
      Bemi.set_context('test1')
      expect(Bemi.context).to eq('test1')

      Bemi.set_context('test2')
      expect(Bemi.context).to eq('test2')
    end
  end

  describe '.append_context' do
    context 'with adapter' do
      it 'appends the context to write SQL queries' do
        Bemi.set_context({ foo: 'bar' })
        sql = "INSERT INTO todos (task) VALUES ('Eat')"
        adapter = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new({})

        result = Bemi.append_context.call(sql, adapter)

        expect(result).to eq("INSERT INTO todos (task) VALUES ('Eat') /*Bemi {\"foo\":\"bar\"} Bemi*/")
      end

      it 'does not append the context to read SQL queries' do
        Bemi.set_context({ foo: 'bar' })
        sql = "SELECT * FROM todos"
        adapter = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new({})

        result = Bemi.append_context.call(sql, adapter)

        expect(result).to eq("SELECT * FROM todos")
      end

      it 'does not append the context if it is too large' do
        Bemi.set_context({ foo: 'a' * 1_000_001 })
        sql = "INSERT INTO todos (task) VALUES ('Eat')"
        adapter = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.new({})

        result = Bemi.append_context.call(sql, adapter)

        expect(result).to eq("INSERT INTO todos (task) VALUES ('Eat')")
      end
    end

    context 'without adapter with Rails < 7.1' do
      it 'appends the context to write SQL queries' do
        Bemi.set_context({ foo: 'bar' })
        sql = "INSERT INTO todos (task) VALUES ('Eat')"

        result = Bemi.append_context.call(sql)

        expect(result).to eq("INSERT INTO todos (task) VALUES ('Eat') /*Bemi {\"foo\":\"bar\"} Bemi*/")
      end

      it 'does not append the context to read SQL queries' do
        Bemi.set_context({ foo: 'bar' })
        sql = "SELECT * FROM todos"

        result = Bemi.append_context.call(sql)

        expect(result).to eq("SELECT * FROM todos")
      end
    end
  end
end
