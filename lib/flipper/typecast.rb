module Flipper
  module Typecast
    TruthMap = {
      true    => true,
      1       => true,
      'true'  => true,
      '1'     => true,
    }.freeze

    # Internal: Convert value to a boolean.
    #
    # Returns true or false.
    def self.to_boolean(value)
      !!TruthMap[value]
    end

    # Internal: Convert value to an integer.
    #
    # Returns an Integer representation of the value.
    # Raises ArgumentError if conversion is not possible.
    def self.to_integer(value)
      if value.respond_to?(:to_i)
        value.to_i
      else
        raise ArgumentError, "#{value.inspect} cannot be converted to an integer"
      end
    end

    # Internal: Convert value to a set.
    #
    # Returns a Set representation of the value.
    # Raises ArgumentError if conversion is not possible.
    def self.to_set(value)
      return value if value.is_a?(Set)
      return Set.new if value.nil? || value.empty?

      if value.respond_to?(:to_set)
        value.to_set
      else
        raise ArgumentError, "#{value.inspect} cannot be converted to a set"
      end
    end
  end
end
