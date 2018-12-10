# frozen_string_literal: true

module LunaPark
  module Extensions
    # add description
    module Comparable
      def ==(other)
        return false unless other.is_a?(self.class)

        comparsion_attributes.all? { |attr| send(attr) == other.send(attr) }
      end

      def comparsion_attributes
        raise Errors::AbstractMethod,
              "You must implement #{self.class}#comparsion_attributes method " \
              'to return list of attributes (methods) for full comparsion with #== '\
              'and #differences_structure'
      end
    end
  end
end
