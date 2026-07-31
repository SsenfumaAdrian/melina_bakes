/// Input validation utilities shared across the application.
abstract final class Validators {
  Validators._();

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates a name field.
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '\$fieldName is required';
    }
    if (value.length < 2) {
      return '\$fieldName must be at least 2 characters';
    }
    if (value.length > 100) {
      return '\$fieldName must be less than 100 characters';
    }
    return null;
  }

  /// Validates a phone number.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}\$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates that a value is not empty.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '\$fieldName is required';
    }
    return null;
  }

  /// Validates a numeric value.
  static String? numeric(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.isEmpty) {
      return '\$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '\$fieldName must be a valid number';
    }
    return null;
  }

  /// Validates a positive number.
  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '\$fieldName must be greater than zero';
    }
    return null;
  }

  /// Validates a URL.
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?\$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates that two passwords match.
  static String? passwordsMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
