module DuckMap

  # This is a small helper used to ensure values in an Array of are a certain type.
  module ArrayHelper

    ##################################################################################
    # Ensures all values in an Array are of a certain type.  This is meant to be used internally
    # by DuckMap modules and classes.
    #
    #     values = ["new_book", "edit_book", "create_book", "destroy_book"]
    #     values = obj.convert_to(values, :symbol)
    #     puts values #=> [:new_book, :edit_book, :create_book, :destroy_book]
    #
    # @param [Array]    values The Array to inspect and convert.
    # @param [Symbol]   type Valid values are :string and :symbol.
    #                        - :string converts all values to a String.
    #                        - :symbol converts all values to a Symbol.
    # @return [Array]
    def convert_to(values, type)
      buffer = []

      if values.kind_of?(Array)

        values.each do |value|

          begin

            if type == :string
              buffer.push(value.to_s)

            elsif type == :symbol
              buffer.push(value.to_sym)

            end

          rescue Exception => e
          end

        end

      else
        buffer = values
      end

      return buffer
    end

  end
end
