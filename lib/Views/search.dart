import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/user_page.dart';

class Search extends StatefulWidget {
  final User user;
  const Search(this.user, {Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static const historyLength = 5;
  late List<String> _searchHistory = [];
  late List<String> filteredSearchHistory = [];
  String selectedTerm = "";

  FirebaseFirestore db = FirebaseFirestore.instance;
  late User _currentUser;
  late TextEditingController _controller;

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

  // get the search_history field from the current user collection
  Future<void> getSearchHistory() async {
    DocumentSnapshot reference =
        await db.collection('users').doc(_currentUser.uid).get();

    List<String> history = reference.data()!["search history"].cast<String>();
    // print(history);
    _searchHistory = history.cast<String>();
    // filteredSearchHistory = _searchHistory;
    filteredSearchHistory = filteredSearchTerms(filter: null);
    // return history;
  }

  // update the search history field in the database
  Future<void> setSearchHistory() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .update({'search history': _searchHistory});
  }

  // add searched term item to history in app
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

  // delete a searched item in the history
  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((element) => element == term);
    filteredSearchHistory = filteredSearchTerms(filter: null);
  }

  // delete already searched term and put in first position
  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  // delete input field
  void clearSearch() {
    _controller.clear();
    selectedTerm = "";
  }

  // go to the selected user page
  void showProfile(user) async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UserPage(_currentUser, user[0])),
    );
  }

  

  @override
  void initState() {
    _currentUser = widget.user;

    getSearchHistory();
    _controller = TextEditingController();
    // filteredSearchHistory = filteredSearchTerms(filter: null);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

    setSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference ref = db.collection('users');
    return Scaffold(
        // appBar
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
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
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
              //history
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
                      return Material(
                        color: Colors.white,
                        elevation: 4,
                        child: Builder(builder: (context) {

                          // if the filtered search history list is empty
                          if (filteredSearchHistory.isEmpty &&
                              selectedTerm == "") {
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
                          } 
                          // if the filtered search history list is not empty
                          else {
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
                    // default of futurebuilder
                    return Material(
                        color: Color.fromARGB(255, 255, 255, 255),
                        elevation: 4,
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Start Searching',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ));
                  }),

              //search results
              Builder(builder: (context) {
                if (selectedTerm == "") {
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

                  // filter the users corresponding to the searchterm
                  String limit = "";
                  if (selectedTerm != "") {
                    final strFrontCode =
                        selectedTerm.substring(0, selectedTerm.length - 1);
                    final strEndCode = selectedTerm.characters.last;
                    limit = strFrontCode +
                        String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
                  }

                  return FutureBuilder(
                      future: ref
                          .where("username",
                              isGreaterThanOrEqualTo: selectedTerm)
                          .where("username", isLessThan: limit)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong',
                              textAlign: TextAlign.center);
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          List users = [];
                          // String isFollowing = "Follow";

                          for (var queryDocumentSnapshot
                              in snapshot.data!.docs) {
                            Map<String, dynamic> data =
                                queryDocumentSnapshot.data();
                            var name = data['username'];
                            var bio = data['bio'];
                            var pp = data['profile picture'];
                            users.add([name, bio, pp]);
                          }

                          return Column(
                            children: users
                                .map((term) => Card(
                                    child: InkWell(
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          showProfile(term);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(term[2]),
                                                radius: 24,
                                              ),
                                              title: Text(term[0]),
                                              subtitle: Text(
                                                term[1],
                                                maxLines: 3,
                                              ),
                                            ),
                                          ],
                                        ))

                                    // _controller.clear();
                                    ))
                                .toList(),
                          );
                        }
                        // by default
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
              })
            ],
          ))
        ]));
  }
}
