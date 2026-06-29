import 'package:flutter/material.dart';

typedef CallbackSearch = Function(dynamic);

class SearchForm extends StatelessWidget {
  final TextEditingController? controller;
  final String? result;
  final CallbackSearch? callback;
  const SearchForm({super.key, this.controller, this.result, this.callback});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,fit: FlexFit.loose,
      child:TextField(
        onChanged: (String value) => {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              )
            },
        controller: controller));
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
   String? result;
  final CallbackSearch? callback;
  CustomSearchDelegate({this.result, this.callback});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, query);
          result = query;
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(child: const Text('Ini hasil'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(child: Text(query));
  }
}
