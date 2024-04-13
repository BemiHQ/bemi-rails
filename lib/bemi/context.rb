# frozen_string_literal: true

require 'active_record'

class Bemi
  def self.set_context(context)
    Thread.current[:bemi_context] = context
  end

  def self.context
    Thread.current[:bemi_context]
  end

  def self.append_context
    Proc.new do |sql, adapter = ActiveRecord::Base.connection|
      if adapter.write_query?(sql)
        "#{sql} /*Bemi #{Bemi.context.to_json} Bemi*/"
      else
        sql
      end
    end
  end
end

ActiveRecord.query_transformers << Bemi.append_context
