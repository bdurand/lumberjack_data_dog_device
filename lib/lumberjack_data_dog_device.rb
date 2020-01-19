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
          value = remove_empty_values(value)
          next if value.nil?

          if name == "error" && value.is_a?(Exception)
            copy[name] = {
              "kind" => value.class.name,
              "message" => value.message,
              "trace" => value.backtrace
            }
          elsif name.include?(".")
            names = name.split(".")
            next_value_in_hash(copy, names, value)
          else
            copy[name] = value
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

      def next_value_in_hash(hash, keys, value)
        key = keys.first
        if keys.size == 1
          hash[key] = value
        else
          current = hash[key]
          unless current.is_a?(Hash)
            current = {}
            hash[key] = current
          end
          next_value_in_hash(current, keys[1, keys.size], value)
        end
      end
    end

    class DurationFormatter
      def initialize(multiplier)
        @multiplier = multiplier
      end

      def call(value)
        if value.is_a?(Numeric)
          value = (value.to_f * @multiplier).round
        end
        { "duration" => value }
      end
    end

    DATA_DOG_MAPPING = {
      time: "timestamp",
      severity: "status",
      progname: ["logger", "name"],
      pid: "pid",
      message: MessageExceptionFormatter.new,
      duration: DurationFormatter.new(1_000_000_000),
      duration_ms: DurationFormatter.new(1_000_000),
      duration_ns: "duration",
      tags: DataDogTagsFormatter.new
    }.freeze

    def initialize(stream_or_device)
      super(stream_or_device, mapping: DATA_DOG_MAPPING)
    end

  end
end
