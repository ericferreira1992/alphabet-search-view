import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:example/examples/string_list_example_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'examples/model_list_with_builder_example_page.dart';
import 'examples/model_list_example_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alphabet Search View',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlphabetSearchView (Examples)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StringListExamplePage()),
                ),
                child: const Text('StringList'),
              ),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModelListExamplePage()),
                ),
                child: const Text('ModelList'),
              ),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModeListWithBuilderExamplePage()),
                ),
                child: const Text('ModeList (with Builder)'),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
