# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.1

### Added

- Add optional max_message_length to limit the length of message payload.

### Changed

- Format non-hashes in log messages as strings to prevent stack overflow on objects that cannot be serialized to JSON.

## 1.0.0

### Added

- Initial release
