import 'dart:math';

import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ModeListWithBuilderExamplePage extends StatelessWidget {
  ModeListWithBuilderExamplePage({Key? key}) : super(key: key);

  final faker = Faker.instance;
  final random = Random();
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelList (width Builder)'),
      ),
      body: SafeArea(
        bottom: false,
        child: AlphabetSearchView.modelList(
          decoration: AlphabetSearchDecoration.fromContext(
            context,
            titleStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
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
          onItemTap: (_, __, item) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(item.title),
            ));
          },
          buildItem: (_, __, item) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.25),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: Image.network(
                                'https://picsum.photos/seed/${random.nextInt(1000)}/150/150')
                            .image,
                      ),
                      border: Border.all(
                        width: 5,
                        color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(.1)
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
