import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/main.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key, required this.getSearchResults}) : super(key: key);

  final void Function(String) getSearchResults;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return CupertinoTextField(
          prefix: const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Icon(Icons.search),
          ),
          decoration: BoxDecoration(
            // gradient: const LinearGradient(colors: <Color>[
            //   Colors.orangeAccent,
            //   primary,
            // ], begin: Alignment.centerLeft, end: Alignment.centerRight),
            color: darkDynamic?.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          onChanged: (query) {
            setState(() {
              ref.read(queryProvider.notifier).state = query;
              query.isNotEmpty ? widget.getSearchResults(query) : null;
            });
          },
        );
      },
    );
  }
}
