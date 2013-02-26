module DuckMap

  ##################################################################################
  # LastMod is a Date/Time parsing class.
  class LastMod

    ##################################################################################
    # Parses a DateTime represented as a String into a DateTime value.  If value is String, then, it is parsed
    # and returns a DateTime Object if valid.  Otherwise, it returns nil.  If the value passed is a Date, Time, or DateTime, then,
    # it is returned as is.
    # @param [String] value A DateTime represented as a String to parse or can be a Date, Time, or DateTime value.
    # @return [DateTime] DateTime value.
    def self.to_date(value)
      date_value = nil

      if value.kind_of?(String)

        formats = ["%m/%d/%Y %H:%M:%S", "%m-%d-%Y %H:%M:%S", "%Y-%m-%d %H:%M:%S", "%m/%d/%Y", "%m-%d-%Y", "%Y-%m-%d"]
        Time::DATE_FORMATS.each_value { |x| formats.push(x)}

        formats.each do |format|

          begin

            date_value = Time.strptime(value, format)
            break

          rescue Exception => e
            date_value = nil
          end
          
        end

      elsif value.kind_of?(Date) || value.kind_of?(Time) || value.kind_of?(DateTime)
        date_value = value
        
      end        

      return date_value
    end

  end

end
