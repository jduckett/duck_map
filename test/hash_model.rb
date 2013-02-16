# the purpose of this class is to help reduce the amount of testing code
# required for the tests.  tests were becoming very large and difficult to understand
# when looking at them later.
# hopefully, this will solve more problems than it could create....
class HashModel

  ##################################################################################
  def self.models

    unless defined?(@@models)
      @@models = {}
    end

    return @@models
  end

  ##################################################################################
  def self.get_model(file_spec)

    if self.models[file_spec].blank?
      base_dir = File.expand_path(File.dirname(__FILE__))
      self.models[file_spec] = YAML.load_file(File.join(base_dir, "#{file_spec}.yml"))
    end

    return self.models[file_spec]
  end

  ##################################################################################
  def self.verify(file_spec, target = {}, key = :all)
    succeed = true

    source = self.get_model(file_spec)

    unless key.eql?(:all)
      source = source[key]
    end

    begin
        self.verify_value(source, target)
    rescue Exception => e
      succeed = false
      #puts "verify FAILED: forward direction #{e}"
    end

    begin
        self.verify_value(target, source)
    rescue Exception => e
      succeed = false
      #puts "verify FAILED: backward direction #{e}"
    end

    return succeed
  end

  ##################################################################################
  def self.verify_value(source, target)
    succeed = true

    if source.kind_of?(Hash)

      source.each do |pair|

        if target.has_key?(pair.first)
          unless self.verify_value(pair.last, target[pair.first])
            raise Exception, "fail sub-value match: #{pair.last}  target: #{target[pair.first]}"
          end
        else
          raise Exception, "target does not have key: #{pair.first}  target: #{target}"
        end

      end

    else

      if source.class.name.eql?(target.class.name)
        unless source.eql?(target)
          raise Exception, "fail value match -> source: #{source}  target: #{target}"
        end
      else
        raise Exception, "fail class match -> source: #{source}  target: #{target}"
      end

    end

    return succeed
  end

end














