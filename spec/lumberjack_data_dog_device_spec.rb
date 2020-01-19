require 'spec_helper'

describe Lumberjack::DataDogDevice do

  let(:device) { Lumberjack::DataDogDevice.new(output) }
  let(:output) { StringIO.new }

  describe "entry_as_json" do
    it "should output the fields the DataDog format" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "message", "test", 12345, "foo" => "bar", "baz" => "boo")
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "logger" => { "name" => entry.progname },
        "pid" => entry.pid,
        "message" => entry.message,
        "foo" => "bar",
        "baz" => "boo"
      })
    end

    it "should set the thread tag as logger.thread if present" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "message", "test", 12345, "thread" => "mythread")
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "logger" => { "name" => entry.progname, "thread_name" => "mythread" },
        "pid" => entry.pid,
        "message" => entry.message
      })
    end

    it "should not include empty tags" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "message", nil, 12345, {})
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "pid" => entry.pid,
        "message" => entry.message
      })
    end

    it "should format the message as an error if it is an exception" do
      error = nil
      begin
        raise RuntimeError.new("boom")
      rescue => e
        error = e
      end

      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, error, nil, nil, {})
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => error.inspect,
        "error" => {
          "kind" => "RuntimeError",
          "message" => "boom",
          "trace" => error.backtrace
        }
      })
    end

    it "should expand the error tag if it is an exception" do
      error = nil
      begin
        raise RuntimeError.new("boom")
      rescue => e
        error = e
      end

      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "an error occurred", nil, nil, "error" => error)
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "error" => {
          "kind" => "RuntimeError",
          "message" => "boom",
          "trace" => error.backtrace
        }
      })
    end

    it "should not expand the error tag if it is not an exception" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "an error occurred", nil, nil, "error" => "error string")
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "error" => "error string"
      })
    end

    it "should convert duration from seconds to nanoseconds" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "test", nil, nil, "duration" => 1.2)
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "duration" => 1_200_000_000
      })
    end

    it "should convert duration_ms from milliseconds to nanoseconds" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "test", nil, nil, "duration_ms" => 1200)
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "duration" => 1_200_000_000
      })
    end

    it "should convert duration_ns from milliseconds to nanoseconds" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "test", nil, nil, "duration_ns" => 12000)
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "duration" => 12000
      })
    end

    it "should convert dot notated tags to nested JSON" do
      entry = Lumberjack::LogEntry.new(Time.now, Logger::INFO, "test", nil, nil, "http.status_code" => 200, "http.method" => "GET")
      data = device.entry_as_json(entry)
      expect(data).to eq({
        "timestamp" => entry.time.strftime('%Y-%m-%dT%H:%M:%S.%6N%z'),
        "status" => entry.severity_label,
        "message" => entry.message,
        "http" => {
          "status_code" => 200,
          "method" => "GET"
        }
      })
    end
  end

end
