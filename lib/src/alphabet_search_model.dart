import 'package:alphabet_search_view/alphabet_search_view.dart';

class AlphabetSearchModel {
  AlphabetSearchModel({
    required this.title,
    this.subtitle,
  }):
    letter = LetterCharExt.fromString(title);

  final String title;
  final String? subtitle;
  final LetterChar letter;
}