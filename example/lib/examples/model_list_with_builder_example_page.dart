import 'dart:math';

import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataItem {
  final String name;
  final String website;
  final String genre;
  final String birthdate;

  DataItem({
    required this.name,
    required this.website,
    required this.genre,
    required this.birthdate,
  });
}

class ModeListWithBuilderExamplePage extends StatefulWidget {
  const ModeListWithBuilderExamplePage({Key? key}) : super(key: key);

  @override
  State<ModeListWithBuilderExamplePage> createState() =>
      _ModeListWithBuilderExamplePageState();
}

class _ModeListWithBuilderExamplePageState
    extends State<ModeListWithBuilderExamplePage> {
  final faker = Faker.instance;

  final random = Random();

  final formatter = DateFormat('dd/MM/yyyy');

  late List<DataItem> listItems;

  @override
  void initState() {
    super.initState();
    listItems = List.generate(500, (e) {
      return DataItem(
        name: '${faker.name.firstName()} ${faker.name.lastName()}',
        birthdate: formatter.format(faker.date.past(DateTime.now())),
        website: faker.internet.url(),
        genre: faker.music.genre(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelList (width Builder)'),
      ),
      body: SafeArea(
        bottom: false,
        child: AlphabetSearchView<DataItem>.list(
          decoration: AlphabetSearchDecoration.fromContext(
            context,
            titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          list: listItems
              .map(
                (e) => AlphabetSearchModel<DataItem>(
                  title: e.name,
                  subtitle: e.genre,
                  data: e,
                ),
              )
              .toList(),
          onItemTap: (_, __, item) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(item.title),
            ));
          },
          buildItem: (_, index, item) {
            // return ListTile(
            //   title: Text(item.title),
            //   subtitle: Text(item.data.name),
            // );
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(.1)),
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
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
