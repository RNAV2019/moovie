import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moovie/constants.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key, required this.getSearchResults}) : super(key: key);

  final void Function(String) getSearchResults;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoTextField(
        prefix: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.search),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[
            Colors.orangeAccent,
            primary,
          ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        onChanged: (query) {
          setState(() {
            query.isNotEmpty ? widget.getSearchResults(query) : null;
          });
        },
      ),
    );
  }
}
