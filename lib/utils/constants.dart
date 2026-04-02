import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Campus Feed';
  static const String appTagline = 'Your Anonymous College Community';

  // Valid College Email Domains
  static const List<String> validEmailDomains = [
    '@abes.ac.in',
    '@gmail.com',
  ];

  // Post Categories
  static const List<String> postCategories = [
    '💭 Confession',
    '😂 Funny',
    '😤 Rant',
    '💬 General',
    '📢 Lost & Found',
    '🎉 Events',
  ];

  // Reaction Emojis
  static const List<String> reactions = ['😂', '👍', '💀', '💯'];

  // Constraints
  static const int maxPostLength = 300;
  static const int maxCommentLength = 200;
  static const int maxPostsPerDay = 10;
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int postsPerPage = 15;
  static const int trendingThreshold = 10;
  static const int trendingHoursWindow = 24;

  // 🎨 POLISHED & PREMIUM COLORS
  
  // Primary Purple (Even Softer - Less Eye Strain)
  static const Color primaryPurple = Color(0xFF8B7FD4);     // Soft lavender-purple
  static const Color lightPurple = Color(0xFFA89FE0);       // Lighter lavender
  static const Color darkPurple = Color(0xFF7468C4);        // Muted dark purple
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F7FA);   // Very soft grey
  static const Color cardColor = Color(0xFFFFFFFF);         // Pure white
  static const Color surfaceColor = Color(0xFFFAFBFC);      // Almost white
  
  // Text Colors (Darker for Readability)
  static const Color textPrimary = Color(0xFF1A1D26);       // Almost black (darker)
  static const Color textSecondary = Color(0xFF4A5568);     // Medium dark grey
  static const Color textLight = Color(0xFF9CA3AF);         // Light grey
  static const Color textMuted = Color(0xFFCBD5E1);         // Very light
  
  // Trending Colors (Warm & Soft)
  static const Color trendingLight = Color(0xFFFFF0E6);     // Very soft peach
  static const Color trendingMedium = Color(0xFFFFB088);    // Soft coral
  static const Color trendingDark = Color(0xFFE89B76);      // Muted orange
  
  // Reaction Colors (Soft & Muted)
  static const Color reactionYellow = Color(0xFFF6D365);    // Soft gold (😂)
  static const Color reactionBlue = Color(0xFF7BA3D4);      // Muted sky blue (👍)
  static const Color reactionRed = Color(0xFFD4847A);       // Soft terracotta (💀)
  static const Color reactionPurple = Color(0xFFB8A9E8);    // Soft lavender (💯)
  
  // Category Colors (Soft & Harmonious)
  static const Color confessionColor = Color(0xFFA89FE0);   // Soft lavender
  static const Color funnyColor = Color(0xFFF6D365);        // Soft gold
  static const Color rantColor = Color(0xFFD4847A);         // Soft terracotta
  static const Color generalColor = Color(0xFF7BA3D4);      // Muted sky blue
  static const Color lostFoundColor = Color(0xFF7ECBA1);    // Soft mint
  static const Color eventsColor = Color(0xFFDDA0C8);       // Soft rose

  // Messages
  static const String invalidEmailDomain = 'Please use your ABES email (@abes.ac.in)';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String usernameRequired = 'Username is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String usernameTooShort = 'Username must be at least 3 characters';
  static const String usernameTooLong = 'Username must be less than 20 characters';
  static const String invalidUsername = 'Username can only contain letters, numbers, and underscores';
  
  // Get category color
  static Color getCategoryColor(String category) {
    switch (category) {
      case '💭 Confession':
        return confessionColor;
      case '😂 Funny':
        return funnyColor;
      case '😤 Rant':
        return rantColor;
      case '📢 Lost & Found':
        return lostFoundColor;
      case '🎉 Events':
        return eventsColor;
      default:
        return generalColor;
    }
  }
  
  // Get reaction color
  static Color getReactionColor(String emoji) {
    switch (emoji) {
      case '😂':
        return reactionYellow;
      case '👍':
        return reactionBlue;
      case '💀':
        return reactionRed;
      case '💯':
        return reactionPurple;
      default:
        return primaryPurple;
    }
  }
}