# DONE
module DuckMap

  ##################################################################################
  # Simple helper class that tries to find controller and model classes based on a controller name.
  class ClassHelpers

    ##################################################################################
    # Attempts to automagically determine the controller class name based on the named route.
    # returns [Class]
    def self.get_controller_class(controller_name)
      controller = nil

      begin

        controller = "#{controller_name.camelize.pluralize}Controller".constantize

      rescue Exception => e
        # once upon a time, I was logging these exceptions, however, it made the log files very noisy.
        # I expect to have the exceptions occur.  i plan on doing a little more on this area later.
        controller = nil

        begin

          controller = "#{controller_name.camelize.singularize}Controller".constantize

        rescue Exception => e
          # once upon a time, I was logging these exceptions, however, it made the log files very noisy.
          # I expect to have the exceptions occur.  i plan on doing a little more on this area later.
        end
      end

      return controller
    end

    ##################################################################################
    # Attempts to automagically determine the model class name based on the named route.
    # returns [Class]
    def self.get_model_class(controller_name)
      value = nil

      begin

        value = controller_name.camelize.singularize.constantize

      rescue Exception => e
        # once upon a time, I was logging these exceptions, however, it made the log files very noisy.
        # I expect to have the exceptions occur.  i plan on doing a little more on this area later.
      end

      return value
    end

  end
end
