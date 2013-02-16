require 'test_helper'

class LoggerTest < ActiveSupport::TestCase

  DEBUG = 0
  INFO = 1
  WARN = 2
  ERROR = 3
  FATAL = 4
  UNKNOWN = 5

  test "should return DEBUG for :debug" do
    assert DuckMap.logger.to_severity(:debug).eql?(DEBUG)
  end

  test "should return INFO for :info" do
    assert DuckMap.logger.to_severity(:info).eql?(INFO)
  end

  test "should return WARN for :warn" do
    assert DuckMap.logger.to_severity(:warn).eql?(WARN)
  end

  test "should return ERROR for :error" do
    assert DuckMap.logger.to_severity(:error).eql?(ERROR)
  end

  test "should return FATAL for :fatal" do
    assert DuckMap.logger.to_severity(:fatal).eql?(FATAL)
  end

  test "should return UNKNOWN for :unknown" do
    assert DuckMap.logger.to_severity(:unknown).eql?(UNKNOWN)
  end

  test "should return :debug for DEBUG" do
    assert DuckMap.logger.to_severity(DEBUG).eql?(:debug)
  end

  test "should return :info for INFO" do
    assert DuckMap.logger.to_severity(INFO).eql?(:info)
  end

  test "should return :warn for WARN" do
    assert DuckMap.logger.to_severity(WARN).eql?(:warn)
  end

  test "should return :error for ERROR" do
    assert DuckMap.logger.to_severity(ERROR).eql?(:error)
  end

  test "should return :fatal for FATAL" do
    assert DuckMap.logger.to_severity(FATAL).eql?(:fatal)
  end

  test "should return :unknown for UNKNOWN" do
    assert DuckMap.logger.to_severity(UNKNOWN).eql?(:unknown)
  end

  test "should set log level to :debug" do
    DuckMap.logger.log_level = :debug
    assert DuckMap.logger.log_level.eql?(DEBUG)
  end

  test "should set log level to :info" do
    DuckMap.logger.log_level = :info
    assert DuckMap.logger.log_level.eql?(INFO)
  end

  test "should set log level to :warn" do
    DuckMap.logger.log_level = :warn
    assert DuckMap.logger.log_level.eql?(WARN)
  end

  test "should set log level to :error" do
    DuckMap.logger.log_level = :error
    assert DuckMap.logger.log_level.eql?(ERROR)
  end

  test "should set log level to :fatal" do
    DuckMap.logger.log_level = :fatal
    assert DuckMap.logger.log_level.eql?(FATAL)
  end

  test "should set log level to :unknown" do
    DuckMap.logger.log_level = :unknown
    assert DuckMap.logger.log_level.eql?(UNKNOWN)
  end

end
