# frozen_string_literal: true

require 'active_support/concern'

module Bemi::ChangeQueryHelpers
  extend ActiveSupport::Concern

  included do
    scope :before, ->(hash) { where('before @> ?', hash.to_json) }
    scope :after, ->(hash) { where('after @> ?', hash.to_json) }
    scope :context, ->(hash) { where('context @> ?', hash.to_json) }

    scope :created, -> { where(operation: 'CREATE') }
    scope :updated, -> { where(operation: 'UPDATE') }
    scope :deleted, -> { where(operation: 'DELETE') }

    scope :asc, -> { order(committed_at: :asc) }
    scope :desc, -> { order(committed_at: :desc) }

    self.filter_attributes = (Rails.respond_to?(:filter_parameters) ? Rails.configuration.filter_parameters : []).map do |filter|
      if filter == :_key
        /(?<!primary_)key/ # don't filter out primary_key
      else
        filter
      end
    end
  end

  def diff
    result = {}

    (before.keys | after.keys).each do |key|
      next if before[key] == after[key]
      result[key] = [before[key], after[key]]
    end

    result
  end
end
