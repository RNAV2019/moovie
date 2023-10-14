import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';

class CategoryChips extends ConsumerStatefulWidget {
  String sortByCategory;
  Null Function(String value) updateSortByCategory;
  CategoryChips(
      {super.key,
      required this.sortByCategory,
      required this.updateSortByCategory});

  @override
  ConsumerState<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends ConsumerState<CategoryChips> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ref.watch(darkModeProvider);
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      return Row(
        children: [
          ChoiceChip(
            label: const Text('Movie'),
            selected: widget.sortByCategory == 'movie',
            selectedColor:
                isDarkMode ? darkDynamic?.primary : lightDynamic?.primary,
            backgroundColor:
                isDarkMode ? darkDynamic?.secondary : lightDynamic?.secondary,
            onSelected: (value) {
              if (value) {
                setState(() {
                  widget.sortByCategory = 'movie';
                  widget.updateSortByCategory('movie');
                  print(widget.sortByCategory);
                });
              }
            },
          ),
          const SizedBox(
            width: 12,
          ),
          ChoiceChip(
            label: const Text('Series'),
            selected: widget.sortByCategory == 'series',
            selectedColor:
                isDarkMode ? darkDynamic?.primary : lightDynamic?.primary,
            backgroundColor:
                isDarkMode ? darkDynamic?.secondary : lightDynamic?.secondary,
            onSelected: (value) {
              if (value) {
                setState(() {
                  widget.sortByCategory = 'series';
                  widget.updateSortByCategory('series');
                  print(widget.sortByCategory);
                });
              }
            },
          )
        ],
      );
    });
  }
}
