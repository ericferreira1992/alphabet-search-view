import 'dart:async';
import 'dart:math';

import 'package:async/async.dart' show StreamGroup;
import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AlphabetSearchView<T> extends StatefulWidget {
  final List<AlphabetSearchModel<T>> _list;
  final AlphabetSearchDecoration? _decoration;
  final void Function(
      BuildContext context, int index, AlphabetSearchModel<T> item)? _onItemTap;
  final Widget Function(
      BuildContext context, int index, AlphabetSearchModel<T> item)? _buildItem;
  final bool _debugMode;

  const AlphabetSearchView._internal({
    Key? key,
    required List<AlphabetSearchModel<T>> list,
    Function(BuildContext context, int index, AlphabetSearchModel<T> item)?
        onItemTap,
    Widget Function(
            BuildContext context, int index, AlphabetSearchModel<T> item)?
        buildItem,
    AlphabetSearchDecoration? decoration,
    required bool debugMode,
  })  : _list = list,
        _buildItem = buildItem,
        _onItemTap = onItemTap,
        _decoration = decoration,
        _debugMode = debugMode,
        super(key: key);

  factory AlphabetSearchView.list({
    Key? key,
    required List<AlphabetSearchModel<T>> list,
    Function(BuildContext context, int index, AlphabetSearchModel<T> item)?
        onItemTap,
    Widget Function(
            BuildContext context, int index, AlphabetSearchModel<T> item)?
        buildItem,
    AlphabetSearchDecoration? decoration,
    bool debugMode = false,
  }) {
    assert(list.isNotEmpty,
        'Property list can\'t be empty, it needs to have at least 1 element on the list.');
    list.sort((a, b) => a.title.compareTo(b.title));
    return AlphabetSearchView._internal(
      key: key,
      list: list
          .where((item) => item.title.isNotEmpty)
          .toList()
          .cast<AlphabetSearchModel<T>>(),
      onItemTap: onItemTap,
      buildItem: buildItem,
      decoration: decoration,
      debugMode: debugMode,
    );
  }

  @override
  State<AlphabetSearchView<T>> createState() => AlphabetSearchViewState<T>();
}

class AlphabetSearchViewState<T> extends State<AlphabetSearchView<T>> {
  late final AlphabetSearchDecoration decoration =
      widget._decoration ?? AlphabetSearchDecoration.fromDefault(context);
  late final bool debugMode = widget._debugMode;
  late final searchTextController = TextEditingController(text: '');

  final key = GlobalKey();
  final letterScrollController = ScrollController();
  final itemScrollController = ItemScrollController();
  final itemScrollListener = ItemPositionsListener.create();

  late final currentLetterController = CurrentLetterController(
    widget._list.first.letter,
  );
  late final targetLetterController = TargetLetterController(null);

  late final Function(
          BuildContext context, int index, AlphabetSearchModel<T> item)?
      onItemTap = widget._onItemTap;
  late final Widget Function(
          BuildContext context, int index, AlphabetSearchModel<T> item)?
      buildItem = widget._buildItem;

  late List<AlphabetSearchModel<T>> filteredList = widget._list;

  LetterChar? get targetLetter => targetLetterController.value;

  set targetLetter(value) => targetLetterController.value = value;

  LetterChar? get currentLetter => currentLetterController.value;

  set currentLetter(value) {
    if (value != currentLetter || targetLetter != null) {
      targetLetterController.emitValue = false;
      targetLetterController.value = null;
      targetLetterController.emitValue = true;
      currentLetterController.value = value;
    }
  }

  int? get currentLetterIndex {
    final letter = targetLetter ?? currentLetter;
    if (letter != null) return letters.indexOf(letter);
    return null;
  }

  String previousSearchText = '';
  bool scrollingToItem = false;
  bool scrollingToLetter = false;
  bool isLetterDragging = false;
  bool isSearching = false;

  @override
  void initState() {
    itemScrollListener.itemPositions.addListener(() {
      final positions =
          itemScrollListener.itemPositions.value.map((e) => e.index).toList();
      if (positions.isNotEmpty) {
        positions.sort();
        final firstIndex = positions.first;
        final item = filteredList[firstIndex];
        final letter = item.letter;

        if (debugMode) debugPrint('------------------------');

        if (letter != currentLetter) {
          final prevLetter = currentLetter;
          if (setCurrentLetterFromItemList(letter)) {
            if (debugMode) {
              debugPrint(
                  'LETTER - ${letter.value} (${scrollingToItem.toString()} - ${item.title} - $positions)');
              debugPrint('PREV CURRENT - ${prevLetter?.value ?? 'null'}');
              debugPrint('CURRENT - ${letter.value}');
            }
            return;
          }
        }
        if (debugMode) {
          debugPrint(
              'LETTER/CURRENT - ${letter.value}/${currentLetter?.value ?? 'null'} (${scrollingToItem.toString()} - $firstIndex - $positions)');
        }
      }
    });

    searchTextController.addListener(() {
      defineFilteredData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: decoration.backgroundColor,
          padding: const EdgeInsets.only(right: letterSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (decoration.withSearch) buildSearchField(),
              buildScrollList(),
            ],
          ),
        ),
        buildLettersList(),
        buildTargetLetterSearchingTag(),
      ],
    );
  }

  Widget buildLettersList() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: letterSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: decoration.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              spreadRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.builder(
          controller: letterScrollController,
          itemCount: letters.length,
          itemBuilder: (_, index) => StreamBuilder(
            stream: currentLetterController.stream,
            builder: (_, __) {
              final currentLetterIndex = this.currentLetterIndex;
              final letter = letters[index];
              final isActive = filteredList.any((g) => g.letter == letter);
              final isCurrent = (targetLetter ?? currentLetter) == letter;

              final textStyle = Theme.of(context).textTheme.bodyMedium;

              void onDraggingFn(Offset localPosition) {
                final distance = localPosition.dy;
                final aboveDistance =
                    (currentLetterIndex ?? 0) * letterBoxHeight;
                final letterIndex =
                    ((aboveDistance + distance) / letterBoxHeight)
                        .floor()
                        .abs();

                if (letterIndex >= 0 && letterIndex < letters.length) {
                  final probablyLetter = letters[letterIndex];
                  final letterIsActive =
                      filteredList.any((g) => g.letter == probablyLetter);
                  if (letterIsActive && targetLetter != probablyLetter) {
                    targetLetter = probablyLetter;
                    if (debugMode) {
                      debugPrint(
                          '$letterIndex - $probablyLetter (($aboveDistance + $distance) / $letterBoxHeight = ${aboveDistance + distance / letterBoxHeight})');
                    }
                  }
                } else {
                  if (debugMode) {
                    debugPrint(
                        '$letterIndex - WRONG (${distance / letterBoxHeight})');
                  }
                }
              }

              return SizedBox(
                height: letterBoxHeight,
                child: InkWell(
                  onTap: (!isCurrent && isActive)
                      ? () => setCurrentLetterFromLetterList(letter)
                      : null,
                  child: Stack(
                    children: [
                      StreamBuilder(
                        stream: targetLetterController.stream,
                        builder: (_, __) {
                          final isCurrent =
                              (targetLetter ?? currentLetter) == letter;
                          return Center(
                            child: Opacity(
                              opacity: isActive ? 1 : 0.5,
                              child: Text(
                                letter.value,
                                style: isCurrent
                                    ? textStyle?.copyWith(
                                        fontSize: 16, color: decoration.color)
                                    : textStyle?.copyWith(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: const Offset(2, 0),
                          child: GestureDetector(
                            dragStartBehavior: DragStartBehavior.down,
                            onVerticalDragStart: isCurrent
                                ? (d) {
                                    isLetterDragging = true;
                                    onDraggingFn(d.localPosition);
                                  }
                                : null,
                            onVerticalDragUpdate: isCurrent
                                ? (d) => onDraggingFn(d.localPosition)
                                : null,
                            onVerticalDragEnd: isCurrent
                                ? (detail) {
                                    isLetterDragging = false;
                                    if (targetLetter != null) {
                                      setCurrentLetterFromLetterList(
                                          targetLetter!);
                                    }
                                  }
                                : null,
                            child: StreamBuilder(
                              stream: targetLetterController.stream,
                              builder: (_, __) {
                                final isCurrent =
                                    (targetLetter ?? currentLetter) == letter;
                                return Container(
                                  width: isCurrent ? letterBoxHeight : 0,
                                  height: isCurrent ? letterBoxHeight : 0,
                                  decoration: BoxDecoration(
                                    color: decoration.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      isCurrent
                                          ? (targetLetter ?? currentLetter)!
                                              .value
                                          : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTargetLetterSearchingTag() {
    return Align(
      alignment: Alignment.center,
      child: StreamBuilder(
        stream: StreamGroup.merge(
            [targetLetterController.stream, currentLetterController.stream]),
        builder: (_, __) {
          final visible = isLetterDragging && targetLetter != null;
          return AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: visible ? 100 : 0,
              height: visible ? 100 : 0,
              decoration: BoxDecoration(
                color: decoration.color,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: visible
                  ? Center(
                      child: Text(
                        targetLetter!.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 30,
                              color: Colors.white,
                            ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: decoration.dividerThickness,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: Image.memory(
                searchImageBytes,
                color: decoration.color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchTextController,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchTextController.text.isNotEmpty)
            IconButton(
              onPressed: () => setState(() {
                searchTextController.text = '';
              }),
              icon: SizedBox(
                width: 14,
                height: 14,
                child: Image.memory(
                  closeImageBytes,
                  color: decoration.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildScrollList() {
    return Expanded(
      child: GestureDetector(
        onPanStart: (_) => scrollingToItem = false,
        child: ScrollablePositionedList.builder(
          itemPositionsListener: itemScrollListener,
          itemScrollController: itemScrollController,
          itemCount: filteredList.length,
          itemBuilder: (_, index) {
            if (index < 0) {
              return Container();
            }
            final prevItem = index > 0 ? filteredList[index - 1] : null;
            final item = filteredList[index];
            final isStartingNewLetter =
                prevItem != null ? prevItem.title[0] != item.title[0] : true;

            final buildedWidget = buildItem?.call(context, index, item);
            final defaultWidget = Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: decoration.titleTextStyle,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: decoration.subtitleTextStyle,
                    ),
                  ],
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isStartingNewLetter)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, decoration.dividerThickness),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: decoration.color,
                                  width: decoration.dividerThickness * 2,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 6,
                                bottom: 0,
                                left: 8,
                                right: 8,
                              ),
                              child: Text(
                                item.letter.value,
                                style: decoration.letterHeaderTextStyle,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox(height: 0)),
                      ],
                    ),
                  ),
                Divider(
                  height: decoration.dividerThickness,
                  thickness: decoration.dividerThickness,
                ),
                if (onItemTap != null)
                  Material(
                    child: InkWell(
                      child: buildedWidget ?? defaultWidget,
                      onTap: () => onItemTap!(context, index, item),
                    ),
                  ),
                if (onItemTap == null) buildedWidget ?? defaultWidget,
              ],
            );
          },
        ),
      ),
    );
  }

  bool setCurrentLetterFromLetterList(LetterChar letter) {
    if (letter != currentLetter) {
      currentLetter = letter;
      final index = filteredList.indexWhere((e) => e.letter == letter);
      scrollingToItem = true;
      itemScrollController
          .scrollTo(
            index: index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .then((_) => scrollingToItem = false);
      return true;
    } else {
      targetLetter = null;
    }
    return false;
  }

  bool setCurrentLetterFromItemList(LetterChar letter) {
    if (!scrollingToItem && !isLetterDragging) {
      final position = letterScrollController.position;
      final index = letters.indexOf(letter);
      final toUp = index < (currentLetterIndex ?? 0);
      final currentInitOffset = letterScrollController.offset;
      final currentEndOffset = currentInitOffset + position.viewportDimension;
      final indexOffset = (index * letterBoxHeight);
      final isVisible =
          indexOffset.clamp(currentInitOffset, currentEndOffset) == indexOffset;

      currentLetter = letter;

      if (!isVisible) {
        final offset = indexOffset -
            position.viewportDimension +
            (letterBoxHeight * (toUp ? -2 : 2));
        letterScrollController.animateTo(
          max(min(offset, position.maxScrollExtent), 0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      return true;
    }
    return false;
  }

  void defineFilteredData({bool needToSetState = true}) {
    final newText = searchTextController.text.toLowerCase();
    if (newText != previousSearchText) {
      previousSearchText = newText;
      if (newText.isNotEmpty) {
        filteredList = widget._list
            .where((x) =>
                (x.title.toLowerCase() + (x.subtitle?.toLowerCase() ?? ''))
                    .contains(newText))
            .toList();
      } else {
        filteredList = widget._list;
      }

      if (needToSetState) {
        currentLetter =
            filteredList.isNotEmpty ? filteredList.first.letter : null;
        setState(() => isSearching = newText.isNotEmpty);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CurrentLetterController extends _AlphabetValueController<LetterChar> {
  CurrentLetterController(LetterChar letter) : super(letter);
}

class TargetLetterController extends _AlphabetValueController<LetterChar> {
  TargetLetterController(LetterChar? letter) : super(letter);
}

class _AlphabetValueController<T> {
  _AlphabetValueController(T? rawValue) : _value = rawValue;

  T? _value;
  bool emitValue = true;

  final _streamController = StreamController<T?>.broadcast();

  Stream<T?> get stream => _streamController.stream;

  T? get value => _value;

  set value(T? value) {
    if (value != _value) {
      _value = value;
      if (emitValue) {
        _streamController.sink.add(_value);
      }
    }
  }

  void dispose() {
    _streamController.close();
  }
}
