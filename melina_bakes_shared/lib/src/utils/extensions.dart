/// Useful Dart extensions shared across the application.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }

  /// Converts snake_case to camelCase.
  String get toCamelCase {
    final parts = split('_');
    if (parts.isEmpty) return this;
    return parts.first + parts.skip(1).map((p) => p.capitalize).join();
  }

  /// Truncates the string to [maxLength] with an optional [suffix].
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '\${substring(0, maxLength - suffix.length)}\$suffix';
  }

  /// Returns true if the string is a valid email.
  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$');
    return regex.hasMatch(this);
  }

  /// Returns true if the string is a valid phone number.
  bool get isValidPhone {
    final regex = RegExp(r'^\+?[0-9]{10,15}\$');
    return regex.hasMatch(replaceAll(RegExp(r'\s'), ''));
  }
}

extension DateTimeExtensions on DateTime {
  /// Formats the date as a relative time string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if the date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if the date is in the future.
  bool get isFuture => isAfter(DateTime.now());
}

extension ListExtensions<T> on List<T> {
  /// Returns a new list with duplicates removed based on [key].
  List<T> distinctBy<K>(K Function(T item) key) {
    final seen = <K>{};
    return where((item) => seen.add(key(item))).toList();
  }

  /// Groups items by the result of [key].
  Map<K, List<T>> groupBy<K>(K Function(T item) key) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final k = key(item);
      map.putIfAbsent(k, () => []).add(item);
    }
    return map;
  }
}
