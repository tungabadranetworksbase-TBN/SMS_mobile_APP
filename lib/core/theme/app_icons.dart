import 'package:flutter/material.dart';

/// Tungabadra Networks LMS — Semantic Icon Mapping
///
/// Ensures the exact same icon is used for the same concept everywhere.
class AppIcons {
  AppIcons._();

  // Navigation
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData menu = Icons.menu_rounded;
  
  // Actions
  static const IconData search = Icons.search_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData settings = Icons.settings_outlined;
  
  // Status
  static const IconData success = Icons.check_circle_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData info = Icons.info_outline_rounded;
  
  // LMS Specific
  static const IconData course = Icons.menu_book_rounded;
  static const IconData video = Icons.play_circle_fill_rounded;
  static const IconData document = Icons.picture_as_pdf_rounded;
  static const IconData quiz = Icons.quiz_rounded;
  static const IconData assignment = Icons.assignment_rounded;
  static const IconData user = Icons.person_outline_rounded;
  
  // Sizes
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
