Flutter component for list and search a simple or complex data items, similar to contact list.

## Demo ([live](http://ericferreira1992.github.io/alphabet-search-view/)):

![](https://github.com/ericferreira1992/alphabet-search-view/raw/main/demo.gif)

## Features
- Search/filter items;
- Customization (default is app Theme);
- Build your own Widget to show;
- Easy to use (Besides being beautiful 💅🏼);

## Usage

Adding in `pubspec.yaml`:
```yaml
dependencies:
  alphabet_search_view: ^2.0.0
```

Import it where you want to use:
```dart
import 'package:alphabet_search_view/alphabet_search_view.dart';
```

### Example:

Specific String use:
```dart
final myStringList = [
    'Katlego Dhaval',
    'Belenos Haniya',
    'Alaattin Ísak',
    'Ephraim Ríghnach',
    'Heli Jerahmeel',
];

AlphabetSearchView<String>.list(
    list: myStringList.map((e) => AlphabetSearchModel<String>(title: e, data: e)).toList(),
```

General use:
```dart
final myModelList = [
    AlphabetSearchModel<MyModel>(title: 'Katlego Dhaval', subtitle: 'Dad', data: myDataModel_1),
    AlphabetSearchModel<MyModel>(title: 'Belenos Haniya', subtitle: 'Friend', data: myDataModel_2),
    AlphabetSearchModel<MyModel>(title: 'Alaattin Ísak', subtitle: 'Friend', data: myDataModel_3),
    AlphabetSearchModel<MyModel>(title: 'Ephraim Ríghnach', subtitle: 'Uncle', data: myDataModel_4),
    AlphabetSearchModel<MyModel>(title: 'Heli Jerahmeel', subtitle: 'Friend', data: myDataModel_5),
];

AlphabetSearchView<MyModel>.list(
    list: myModelList,
),
```

With build:
```dart
final myStringList = [
    'Katlego Dhaval',
    'Belenos Haniya',
    'Alaattin Ísak',
    'Ephraim Ríghnach',
    'Heli Jerahmeel',
];

AlphabetSearchView<String>.list(
    list: myStringList.map((e) => AlphabetSearchModel<String>(title: e, data: e)).toList(),
    buildItem: (context, index, item) => Card(
        child: Text(item.title),
    ),
),
```  

With tap callback:
```dart
AlphabetSearchView<String>.list(
    list: myStringList.map((e) => AlphabetSearchModel<String>(title: e, data: e)).toList(),
    onItemTap: (context, index, item) {
        print(item.title);
    },
),
```  

## Customization

```dart
AlphabetSearchView<String>.list(
    decoration: AlphabetSearchDecoration.fromContext(
        context,
        withSearch?: false, // default is: true
        titleStyle?: TextStyle(...), // default is: TextTheme.subtitle1
        subtitleStyle?: TextStyle(...), // default is: TextTheme.bodyText2
        letterHeaderTextStyle?: TextStyle(...), // default is: TextTheme.headline2
        dividerThickness?: double, // default is: 1
        color?: Color, // default is: ColorScheme.primary
        backgroundColor?: Color, // default is: Theme.scaffoldBackgroundColor
    ),
    list: myStringList.map((e) => AlphabetSearchModel<String>(title: e, data: e)).toList(),
),
```  