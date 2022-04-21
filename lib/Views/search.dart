import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const historyLength = 5;
  final List<String> _searchHistory = ["hello", "there", "general", "kenobi"];
  late List<String> filteredSearchHistory;
  String selectedTerm = "";
  bool hideSearchHistory = false;

  // filter the search from the history (if I type "t", only "test" will remain)
  List<String> filteredSearchTerms({
    @required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  // add a new searched item to history
  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }
    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filteredSearchTerms(filter: null);
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((element) => element == term);
    filteredSearchHistory = filteredSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    filteredSearchHistory = filteredSearchTerms(filter: null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // The search area here
            title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _controller.clear,
                    ),
                    hintText: 'Search a user...',
                    border: InputBorder.none),
                onSubmitted: (text) {
                  setState(() {
                    addSearchTerm(text);
                    selectedTerm = text;
                    // _controller.clear();
                  });
                },
                onChanged: (text) {
                  // print('First text field: $text');
                  setState(() {
                    filteredSearchHistory = filteredSearchTerms(filter: text);
                  });
                }),
          ),
        )),
        body: Column(
          children: [
            Material(
              color: Colors.white,
              elevation: 4,
              child: Builder(builder: (context) {
                if (filteredSearchHistory.isEmpty && _controller.text.isEmpty) {
                  return Container(
                    height: 56,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Start Searching',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: filteredSearchHistory
                        .map((term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    deleteSearchTerm(term);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  putSearchTermFirst(term);
                                  selectedTerm = term;
                                  _controller.text = term;
                                });

                                // _controller.clear();
                              },
                            ))
                        .toList(),
                  );
                }
              }),
            ),
            Column(
              children: [Text(selectedTerm)],
            )
            // SearchResultsListView(searchTerm: selectedTerm)
          ],
        ));
  }
}

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;

  const SearchResultsListView({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
          ),
          Text(
            'Start searchinggg',
            style: Theme.of(context).textTheme.headline5,
          )
        ],
      ));
    }

    // final fsb = FloatingSearchBar.of(context);

    return ListView(
      children: List.generate(
          50,
          (index) => ListTile(
              title: Text('$searchTerm search result'),
              subtitle: Text(index.toString()))),
    );
  }
}
