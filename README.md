Flutter component for list and search a simple or complex data items, similar to contact list.

## Demo ([live](ericferreira1992.github.io/alphabet-search-view)):

![](demo.gif)

## Features
- Search/filter items;
- Customization (default is app Theme);
- Build your own Widget to show;
- Easy to use (Besides being beautifull 💅🏼);

## Usage

Adding in `pubspec.yaml`:
```yaml
dependencies:
  alphabet_search_view: ^1.0.0
```

Import it where you want to use:
```dart
import 'package:alphabet_search_view/alphabet_search_view.dart';
```

### Example:

Simple use:
```dart
final myStringList = [
    'Katlego Dhaval',
    'Belenos Haniya',
    'Alaattin Ísak',
    'Ephraim Ríghnach',
    'Heli Jerahmeel',
];

AlphabetSearchView.stringList(
    list: myStringList,
),
```

Model:
```dart
final myModelList = [
    AlphabetSearchModel(title: 'Katlego Dhaval', subtitle: 'Dad'),
    AlphabetSearchModel(title: 'Belenos Haniya', subtitle: 'Friend'),
    AlphabetSearchModel(title: 'Alaattin Ísak', subtitle: 'Friend'),
    AlphabetSearchModel(title: 'Ephraim Ríghnach', subtitle: 'Uncle'),
    AlphabetSearchModel(title: 'Heli Jerahmeel', subtitle: 'Friend'),
];

AlphabetSearchView.modelList(
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

AlphabetSearchView.stringList(
    list: myStringList,
    buildItem: (context, index, item) => Card(
        child: Text(item.title),
    ),
),
```  

With tap callback:
```dart
AlphabetSearchView.stringList(
    list: myStringList,
    onItemTap: (context, index, item) {
        print(item.title);
    },
),
```  

## Customization

```dart
AlphabetSearchView.stringList(
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
    list: myStringList,
),
```  