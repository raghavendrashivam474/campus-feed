import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    // Check if email ends with valid college domain
    final isValidDomain = AppConstants.validEmailDomains.any(
      (domain) => value.toLowerCase().endsWith(domain.toLowerCase()),
    );

    if (!isValidDomain) {
      return AppConstants.invalidEmailDomain;
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }

    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.passwordTooShort;
    }

    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.usernameRequired;
    }

    if (value.length < AppConstants.minUsernameLength) {
      return AppConstants.usernameTooShort;
    }

    if (value.length > AppConstants.maxUsernameLength) {
      return AppConstants.usernameTooLong;
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return AppConstants.invalidUsername;
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Post content validation
  static String? validatePostContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write something';
    }

    if (value.trim().length < 10) {
      return 'Post must be at least 10 characters';
    }

    if (value.length > AppConstants.maxPostLength) {
      return 'Post is too long (max ${AppConstants.maxPostLength} characters)';
    }

    return null;
  }

  // Comment validation
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Comment cannot be empty';
    }

    if (value.length > AppConstants.maxCommentLength) {
      return 'Comment is too long (max ${AppConstants.maxCommentLength} characters)';
    }

    return null;
  }
}