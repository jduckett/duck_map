# DONE
module DuckMap

  # Logger class generates logging information in log/duckmap.log
  class Logger < ::Logger

    CLEAR   = "\e[0m"
    BOLD    = "\e[1m"

    # Colors
    BLACK   = "\e[30m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"

    ##################################################################################
    # Instance of DuckMap::Logger
    def self.logger
      dir = defined?(Rails) ? Rails.root : "."
      return @@logger ||= self.new("#{dir}/log/duckmap.log", INFO)
    end
    
    ##################################################################################
    # Converts a Symbol to a valid log level and vise versa.
    # @return [Object] The return value is based on the argument :key.
    #                    - If you pass a Symbol, you get a log level.
    #                    - If you pass a log level, you get a Symbol.
    def self.to_severity(key)
      key = key.kind_of?(Fixnum) || key.kind_of?(Symbol) ? key : :badkey
      values = {debug: DEBUG, info: INFO, warn: WARN, error: ERROR, fatal: FATAL, unknown: UNKNOWN}
      value = values.map.find {|value| value[key.kind_of?(Symbol) ? 0 : 1].eql?(key)}
      return value.blank? ? nil : value[key.kind_of?(Symbol) ? 1 : 0]
    end

    def to_severity(key)
      return self.class.to_severity(key)
    end

    ##################################################################################
    # Sets the logging level.
    # @param [Symbol, Number] key A value representing the desired logging level.
    #                             Valid values: :debug, :info, :warn, :error, :fatal, :unknown
    #                             DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN
    # @return [Number]
    def self.log_level=(key)
      value = self.to_severity(key)

      unless value.blank?
        @@log_level = value
        self.logger.level = value
      end
      return self.logger.level
    end

    def log_level=(key)
      self.class.log_level = key
    end

    ##################################################################################
    # Gets the current logging level.
    # @return [Number]
    def self.log_level
      @@log_level ||= self.logger.level
      return @@log_level
    end

    def log_level
      return self.class.log_level
    end

    ##################################################################################
    def self.full_exception=(value)
      @@full_exception = value
      return @@full_exception
    end

    def full_exception=(value)
      self.class.full_exception = value
    end

    ##################################################################################
    def self.full_exception
      unless defined?(@@full_exception)
        @@full_exception = false
      end
      return @@full_exception
    end

    def full_exception
      return self.class.full_exception
    end

    ##################################################################################
    def console(msg = nil, progname = nil, &block)
      if self.is_show_console?
        STDOUT.puts msg
      end
      info(msg, progname, &block)
      return nil
    end

    ##################################################################################
    def self.show_console
      unless defined?(@@show_console)
        @@show_console = true
      end
      return @@show_console
    end

    def self.show_console=(value)
      @@show_console = value
    end

    def self.is_show_console?
      return self.show_console
    end

    def show_console
      return self.class.show_console
    end

    def show_console=(value)
      self.class.show_console = value
    end

    def is_show_console?
      return self.class.is_show_console?
    end

    ##################################################################################
    def exception(exception, progname = nil, &block)

      self.error(exception.message, progname, &block)

      base_dir = Rails.root.to_s
      exception.backtrace.each do |x|
        if x.include?(base_dir) || self.full_exception
          self.error(x, progname, &block)
        end
      end

      return nil
    end

    ##################################################################################
    def debug(msg = nil, progname = nil, &block)
      add(DEBUG, color("#{msg}", CYAN), progname, &block)
      return nil
    end

    ##################################################################################
    def error(msg = nil, progname = nil, &block)
      add(ERROR, color("#{msg}", RED), progname, &block)
      return nil
    end

    ##################################################################################
    def fatal(msg = nil, progname = nil, &block)
      add(FATAL, color("#{msg}", RED), progname, &block)
      return nil
    end

    ##################################################################################
    def info(msg = nil, progname = nil, &block)
      add(INFO, "#{msg}", progname, &block)
      return nil
    end

    ##################################################################################
    def warn(msg = nil, progname = nil, &block)
      add(WARN, color("#{msg}", YELLOW), progname, &block)
      return nil
    end

    ##################################################################################
    def unknown(msg = nil, progname = nil, &block)
      add(INFO, color("#{msg}", WHITE), progname, &block)
      return nil
    end

    #############################################################################################
    def color(text, color, bold=false)
      color = self.class.const_get(color.to_s.upcase) if color.is_a?(Symbol)
      bold  = bold ? BOLD : ""
      return "#{bold}#{color}#{text}#{CLEAR}"
    end

  end
end
