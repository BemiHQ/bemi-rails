# frozen_string_literal: true

require 'active_support/concern'

module Bemi::RecordQueryHelpers
  extend ActiveSupport::Concern

  class_methods do
    # Setter
    def bemi_change_class(bemi_change_class_name)
      @@bemi_change_class_name = bemi_change_class_name
    end

    # Getter
    def __bemi_change_class
      raise "Please set the change class name with `bemi_change_class 'BemiChange'`" if !@@bemi_change_class_name
      @@__bemi_change_class ||= @@bemi_change_class_name.constantize
    end
  end

  def bemi_changes
    self.class.__bemi_change_class.where(table: self.class.table_name, primary_key: attributes[self.class.primary_key])
  end
end
