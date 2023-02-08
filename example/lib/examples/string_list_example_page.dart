import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';

class StringListExamplePage extends StatelessWidget {
  StringListExamplePage({Key? key}) : super(key: key);

  final Faker faker = Faker.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StringList'),
      ),
      body: SafeArea(
        bottom: false,
        child: AlphabetSearchView<String>.list(
          list: List.generate(
              500,
              (e) => AlphabetSearchModel<String>(
                    title: faker.name.firstName() + ' ' + faker.name.lastName(),
                    data: faker.name.firstName() + ' ' + faker.name.lastName(),
                  )).toList(),
        ),
      ),
    );
  }
}
