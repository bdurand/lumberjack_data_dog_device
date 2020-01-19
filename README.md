# Lumberjack DataDog Device

[![Build Status](https://travis-ci.org/bdurand/lumberjack_data_dog_device.svg?branch=master)](https://travis-ci.org/bdurand/lumberjack_data_dog_device)
[![Maintainability](https://api.codeclimate.com/v1/badges/372103b5d762c765a16e/maintainability)](https://codeclimate.com/github/bdurand/lumberjack_data_dog_device/maintainability)

This gem provides a logging device that produces JSON output that matches the standard fields defined for [DataDog logging](https://docs.datadoghq.com/logs/processing/attributes_naming_convention/).

* The time will be sent as "timestamp" with a precision in microseconds.

* The severity will be sent as "status" with a string label (DEBUG, INFO, WARN, ERROR, FATAL).

* The progname will be sent as "logger.name"

* The pid will be sent as "pid".

* The message will be sent as "message". In addition, if the message is an exception, the error message, class, and backtrace will be sent as "error.message", "error.kind", and "error.trace".

* If the "error" tag contains an exception, it will be sent as "error.message", "error.kind", and "error.trace".

* A duration can be sent as a number of seconds in the "duration" tag or as a number of milliseconds in the "duration_ms" tag or as a number of nanoseconds in the "duration_ns" tag.

* All other tags are sent as is. If a tag name includes a dot, it will be sent as a nested JSON structure.

This device extends from [`Lumberjack::JsonDevice`]().

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
