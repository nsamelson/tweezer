import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final User user;
  const Search(this.user, {Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const historyLength = 5;
  late List<String> _searchHistory = [];
  late List<String> filteredSearchHistory;
  String selectedTerm = "";
  FirebaseFirestore db = FirebaseFirestore.instance;
  late User _currentUser;

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

  Future<void> getSearchHistory() async {
    DocumentSnapshot reference =
        await db.collection('users').doc(_currentUser.uid).get();

    List<String> history = reference.data()!["search history"].cast<String>();
    // print(history);
    _searchHistory = history.cast<String>();
    filteredSearchHistory = _searchHistory;
    // return history;
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

  void clearSearch() {
    _controller.clear();
    selectedTerm = "";
  }

  late TextEditingController _controller;

  @override
  void initState() {
    _currentUser = widget.user;

    _controller = TextEditingController();
    getSearchHistory();
    // filteredSearchHistory = filteredSearchTerms(filter: null);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference ref = db.collection('users');
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
                        onPressed: () {
                          setState(() {
                            clearSearch();
                          });
                        }),
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
                  setState(() {
                    filteredSearchHistory = filteredSearchTerms(filter: text);
                  });
                }),
          ),
        )),
        body: Column(children: [
          Expanded(
              child: ListView(
            children: [
              FutureBuilder(
                  future: ref.doc(_currentUser.uid).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong',
                          textAlign: TextAlign.center);
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return const Text('Document does not exist');
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      // List<String> history =
                      //     snapshot.data!["search history"].cast<String>();
                      // print(history);

                      // _searchHistory = history;

                      return Material(
                        color: Colors.white,
                        elevation: 4,
                        child: Builder(builder: (context) {
                          if (filteredSearchHistory.isEmpty &&
                              _controller.text.isEmpty) {
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
                              // mainAxisAlignment: MainAxisAlignment.center,
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
                      );
                    }
                    return const Text("");
                  }),
              SearchResultsListView(
                searchTerm: selectedTerm,
              )
            ],
          ))
        ]));
  }
}

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;
  FirebaseFirestore db = FirebaseFirestore.instance;

  SearchResultsListView({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  void followUser(user) {
    //TODO: follow user call to db
  }

  void watchProfile(user) {
    //TODO: go to user profile
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference ref = db.collection('users');

    String limit = "";
    if (searchTerm != "") {
      final strFrontCode = searchTerm.substring(0, searchTerm.length - 1);
      final strEndCode = searchTerm.characters.last;
      limit = strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
    }

    return FutureBuilder(
        future: ref
            .where("username", isGreaterThanOrEqualTo: searchTerm)
            .where("username", isLessThan: limit)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                textAlign: TextAlign.center);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            List users = [];
            for (var queryDocumentSnapshot in snapshot.data!.docs) {
              Map<String, dynamic> data = queryDocumentSnapshot.data();
              var name = data['username'];
              var bio = data['bio'];
              var pp = data['profile picture'];
              users.add([name, bio, pp]);
            }
            if (searchTerm == "") {
              return Center(
                  heightFactor: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.search,
                        size: 24,
                      ),
                      Text(
                        'Start searching',
                        style: Theme.of(context).textTheme.headline5,
                      )
                    ],
                  ));
            } else {
              return Column(
                children: users
                    .map((term) => Card(
                        child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () {
                              watchProfile(term);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(term[2]),
                                    radius: 24,
                                  ),
                                  title: Text(term[0]),
                                  subtitle: Text(
                                    term[1],
                                    maxLines: 3,
                                  ),
                                  trailing: TextButton(
                                    child: const Text('Follow'),
                                    onPressed: () {
                                      followUser(term);
                                    },
                                  ),
                                ),
                              ],
                            ))

                        // _controller.clear();
                        ))
                    .toList(),
              );
            }
          }
          return Center(
              heightFactor: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(
                    Icons.search,
                    size: 24,
                  ),
                  Text(
                    'Start searching',
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              ));
        });
  }
}
