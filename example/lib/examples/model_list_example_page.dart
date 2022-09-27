import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModelListExamplePage extends StatelessWidget {
  ModelListExamplePage({Key? key}) : super(key: key);

  final Faker faker = Faker.instance;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelList'),
      ),
      body: SafeArea(
        bottom: false,
        child: AlphabetSearchView.modelList(
          decoration: AlphabetSearchDecoration.fromContext(context,
              titleStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
          list: List.generate(500, (e) {
            final name = faker.name.firstName() + ' ' + faker.name.lastName();
            final info = [
              'Birthdate: ${formatter.format(faker.date.past(DateTime.now()))}.',
              'Music gender: ${faker.music.genre()}.',
              'Website: ${faker.internet.url()}.',
            ];
            return AlphabetSearchModel(
              title: name,
              subtitle: info.join('\n'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
