# frozen_string_literal: true

require "active_support/number_helper/number_converter"

module ActiveSupport
  module NumberHelper
    class NumberToRoundedConverter < NumberConverter # :nodoc:
      self.namespace      = :precision
      self.validate_float = true

      def convert
        helper = RoundingHelper.new(options)
        rounded_number = helper.round(number)

        if precision = options[:precision]
          if options[:significant] && precision > 0
            digits = helper.digit_count(rounded_number)
            precision -= digits
            precision = 0 if precision < 0 # don't let it be negative
          end

          formatted_string =
            if rounded_number.finite?
              s = rounded_number.to_s("F")
              a, b = s.split(".", 2)
              if precision != 0
                b << "0" * precision
                a << "."
                a << b[0, precision]
              end
              a
            else
              # Infinity/NaN
              "%f" % rounded_number
            end
        else
          formatted_string = rounded_number
        end

        delimited_number = NumberToDelimitedConverter.convert(formatted_string, options)
        format_number(delimited_number)
      end

      private
        def convert_to_whole_number
          options[:convert_to_whole_number]
        end

        def strip_insignificant_zeros
          options[:strip_insignificant_zeros]
        end

        def format_number(number)
          escaped_separator = Regexp.escape(options[:separator])

          if strip_insignificant_zeros
            number.sub(/(#{escaped_separator})(\d*[1-9])?0+\z/, '\1\2').sub(/#{escaped_separator}\z/, "")
          elsif convert_to_whole_number && number.match?(/(#{escaped_separator})(0+\z)/)
            number.split(options[:separator])[0]
          else
            number
          end
        end
    end
  end
end
