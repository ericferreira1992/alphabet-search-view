import 'package:alphabet_search_view/alphabet_search_view.dart';

class AlphabetSearchModel<T> {
  AlphabetSearchModel({
    required this.title,
    required this.data,
    this.subtitle,
  }) : letter = LetterCharExt.fromString(title);

  final String title;
  final String? subtitle;
  final T data;
  final LetterChar letter;
}
