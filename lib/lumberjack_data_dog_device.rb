# frozen_string_literal: true

require "lumberjack_json_device"

module Lumberjack
  # This Lumberjack device logs output to another device as JSON formatted text that maps fields
  # to the standard JSON payload for DataDog log collection.
  #
  # See https://docs.datadoghq.com/logs/log_collection
  class DataDogDevice < JsonDevice

    # Formatter to format a messge as an error if it is an exception.
    class MessageExceptionFormatter
      def call(object)
        if object.is_a?(Exception)
          {
            "message" => object.inspect,
            "error" => {
              "kind" => object.class.name,
              "message" => object.message,
              "trace" => object.backtrace,
            }
          }
        else
          { "message" => object }
        end
      end
    end

    # Formatter to remove empty tag values and expand the error tag if it is an exception.
    class DataDogTagsFormatter
      def call(tags)
        copy = {}
        tags.each do |name, value|
          next if value.nil?
          if name == "error" && value.is_a?(Exception)
            copy[name] = {
              "kind" => value.class.name,
              "message" => value.message,
              "trace" => value.backtrace
            }
          else
            copy[name] = remove_empty_values(value)
          end
        end
        copy
      end

      private

      def remove_empty_values(value)
        if value.is_a?(String)
          value unless value.empty?
        elsif value.is_a?(Hash)
          new_hash = {}
          value.each do |key, val|
            val = remove_empty_values(val)
            new_hash[key] = val unless val.nil?
          end
          new_hash unless new_hash.empty?
        elsif value.is_a?(Array)
          new_array = value.collect { |val| remove_empty_values(val) }
          new_array unless new_array.empty?
        else
          value
        end
      end
    end

    DATA_DOG_MAPPING = {
      time: "timestamp",
      severity: "status",
      progname: ["logger", "name"],
      thread: ["logger", "thread_name"],
      pid: "pid",
      message: MessageExceptionFormatter.new,
      tags: DataDogTagsFormatter.new
    }.freeze

    def initialize(stream_or_device)
      super(stream_or_device, mapping: DATA_DOG_MAPPING)
    end

  end
end
