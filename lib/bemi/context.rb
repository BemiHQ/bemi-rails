# frozen_string_literal: true

require 'active_record'

class Bemi
  READ_QUERY = ActiveRecord::ConnectionAdapters::AbstractAdapter.build_read_query_regexp(
    :close, :declare, :fetch, :move, :set, :show
  )

  MAX_CONTEXT_SIZE = 1_000_000 # ~1MB

  class << self
    def set_context(ctx)
      Thread.current[:bemi_context] = ctx
    end

    def context
      Thread.current[:bemi_context]
    end

    def append_context
      Proc.new do |sql, adapter = nil| # Adapter is automatically passed only with Rails v7.1+
        if (adapter ? adapter.write_query?(sql) : write_query?(sql)) && ctx = serialized_context
          "#{sql} /*Bemi #{ctx} Bemi*/"
        else
          sql
        end
      end
    end

    private

    def write_query?(sql)
      !READ_QUERY.match?(sql)
    rescue ArgumentError
      !READ_QUERY.match?(sql.b)
    end

    def serialized_context
      return if context.nil?
      return if !context.is_a?(Hash) && !context.respond_to?(:has_key?)

      result = context.to_json
      result if result.size <= MAX_CONTEXT_SIZE
    end
  end
end

ActiveRecord.query_transformers << Bemi.append_context
