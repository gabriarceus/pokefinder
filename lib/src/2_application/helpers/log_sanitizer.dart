import 'package:flutter/foundation.dart';

/// Sanitizes user input or search queries for logging.
///
/// In release mode, queries are redacted to protect user privacy.
String sanitizeQueryForLog(String query, {bool isRelease = kReleaseMode}) {
  return isRelease ? '[REDACTED]' : query;
}
