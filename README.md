# Lumberjack DataDog Device

[![Continuous Integration](https://github.com/bdurand/lumberjack_data_dog_device/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/lumberjack_data_dog_device/actions/workflows/continuous_integration.yml)
[![Regression Test](https://github.com/bdurand/lumberjack_data_dog_device/actions/workflows/regression_test.yml/badge.svg)](https://github.com/bdurand/lumberjack_data_dog_device/actions/workflows/regression_test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

This gem provides a logging device that produces JSON output that matches the standard fields defined for [DataDog logging](https://docs.datadoghq.com/logs/processing/attributes_naming_convention/).

* The time will be sent as "timestamp" with a precision in microseconds.

* The severity will be sent as "status" with a string label (DEBUG, INFO, WARN, ERROR, FATAL).

* The progname will be sent as "logger.name"

* The pid will be sent as "pid".

* The message will be sent as "message". In addition, if the message is an exception, the error message, class, and backtrace will be sent as "error.message", "error.kind", and "error.trace".

* If the "error" tag contains an exception, it will be sent as "error.message", "error.kind", and "error.trace".

* A duration can be sent as a number of seconds in the "duration" tag or as a number of milliseconds in the "duration_ms" tag or as a number of microsectons in the "duration_micros" tag or as a number of nanoseconds in the "duration_ns" tag.

* All other tags are sent as is. If a tag name includes a dot, it will be sent as a nested JSON structure.

This device extends from [`Lumberjack::JsonDevice`](). It is not tied to Data Dog in any way other than that it is opinionated about how to map and format some log tags. It can be used with other services or pipelines without issue.

You can optionally specify a maximum message length with the `max_message_length` option on the device. Doing so will trucate the message payload to keep it under this number of characters. This option is provided because JSON payloads get messed up and cannot be parsed if they get too big.

## Example

You could log an HTTP request to some of the DataDog standard fields like this:

```ruby
logger.tag("http.method" => request.method, "http.url" => request.url) do
  logger.info("#{request.method} #{request.path} finished in #{elapsed_time} seconds",
    duration: elapsed_time,
    "http.status_code" => response.status
  )
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lumberjack_data_dog_device'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install lumberjack_data_dog_device
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
