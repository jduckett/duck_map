class TablelessModel < ActiveRecord::Base
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new( name.to_s, default, sql_type.to_s, null )
  end
   
  def self.columns()
    @columns ||= [];
  end
   
  def self.columns_hash
    h = {}
    for c in self.columns
      h[c.name] = c
    end
    return h
  end
   
  def self.column_defaults
    Hash[self.columns.map {|col|
      [col.name, col.default]
    }]
  end

  def self.descends_from_active_record?
    return true
  end

  def persisted?
    return false
  end

  # override the save method to prevent exceptions
  def save( validate = true )
    validate ? valid? : true
  end
end
