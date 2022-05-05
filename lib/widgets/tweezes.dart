import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';

import '../Views/user_page.dart';

class Tweezes extends StatefulWidget {
  final String content;
  final Timestamp date;
  final String username;
  final String profilePicture;
  final int likes;
  final String image;
  const Tweezes(this.content, this.date, this.username, this.profilePicture,
      this.likes, this.image,
      {Key? key})
      : super(key: key);

  @override
  State<Tweezes> createState() => _TweezesState();
}

class _TweezesState extends State<Tweezes> {
  List user_likes = [];
  @override
  Widget build(BuildContext context) {
    final TextStyle? contentTheme = Theme.of(context).textTheme.bodyText1;
    final User connectedUser = FirebaseAuth.instance.currentUser!;
    final String? connectedUsername = connectedUser.displayName;
    Query liked = FirebaseFirestore.instance
        .collection('tweezes')
        .where("username", isEqualTo: widget.username)
        .where("content", isEqualTo: widget.content)
        .where("user_liked", arrayContains: connectedUsername);

    DateTime dates = DateTime.parse(widget.date.toDate().toString());

    return AspectRatio(
        aspectRatio: widget.image == "" ? 5 / 2 : 5 / 4,
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.profilePicture),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          child: Text(widget.username,
                              style: const TextStyle(
                                  fontSize: 17.5, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UserPage(connectedUser, widget.username)),
                            );
                          })
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(widget.content, style: contentTheme),
                          ],
                        ),
                        Expanded(
                          // flex: 5,
                          child: Center(
                            child:
                                Image.network(widget.image, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                              return const Text('');
                            }),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 10),
                FutureBuilder(
                    future: liked.get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong',
                            textAlign: TextAlign.center);
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return LikeButton(
                            likeCount: widget.likes,
                            isLiked: true,
                            onTap: onLikeButtonTapped,
                          );
                        }
                      }
                      return LikeButton(
                        likeCount: widget.likes,
                        isLiked: false,
                        onTap: onLikeButtonTapped,
                      );
                    }),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.comment),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
                Expanded(
                  child: Text(DateFormat('dd-MM-yyyy - kk:mm').format(dates),
                      textAlign: TextAlign.right),
                )
              ],
            )
          ],
        ));
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    final String? connectedUser =
        FirebaseAuth.instance.currentUser!.displayName;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tweezes')
        .where("username", isEqualTo: widget.username)
        .where("content", isEqualTo: widget.content)
        .get();

    if (!isLiked && snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        user_likes.add(connectedUser);
        doc.reference.update({
          "likes": FieldValue.increment(1),
          "user_liked": FieldValue.arrayUnion(user_likes)
        });
      }
    }
    if (isLiked && snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        doc.reference.update({
          "likes": FieldValue.increment(-1),
          "user_liked": FieldValue.arrayRemove(user_likes)
        });
      }
    }
    return !isLiked;
  }
}
