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
  final String tweezId;
  final List userLiked;

  // arguments of Tweezes object
  const Tweezes(this.content, this.date, this.username, this.profilePicture,
      this.likes, this.image, this.tweezId, this.userLiked,
      {Key? key})
      : super(key: key);

  @override
  State<Tweezes> createState() => _TweezesState();
}

class _TweezesState extends State<Tweezes> {

  @override
  Widget build(BuildContext context) {
    final TextStyle? contentTheme = Theme.of(context).textTheme.bodyText1;

    // get the currently connected user
    final User connectedUser = FirebaseAuth.instance.currentUser!;

    // check if the current user has liked the tweez
    CollectionReference tweezDoc =
        FirebaseFirestore.instance.collection('tweezes');

    DateTime dates = DateTime.parse(widget.date.toDate().toString());

    return AspectRatio(
        // adjust card size
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

                          // if click on the username, redirect to the user profile page
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
              // autosize the card
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
                            // text of the tweez
                            Text(widget.content, style: contentTheme),
                          ],
                        ),
                        Expanded(
                          // flex: 5,
                          child: Center(
                            child:
                                // image of the tweez if there is an image
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
              // buttons
              children: [
                const SizedBox(width: 10),
                FutureBuilder(
                    future: tweezDoc.doc(widget.tweezId).get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong',
                            textAlign: TextAlign.center);
                      }
                      if (snapshot.connectionState == ConnectionState.done) {

                        // if already liked by the current user
                        if (snapshot.data!.exists) {
                          if (snapshot.data!["user_liked"]?.contains(connectedUser.displayName)){
                            return LikeButton(
                            likeCount: widget.likes,
                            isLiked: true,
                            onTap: onLikeButtonTapped,
                          );
                          }
                          
                        }
                      }
                      // if not liked yet
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

  // like or unlike tweez
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    final String? connectedUser =
        FirebaseAuth.instance.currentUser!.displayName;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('tweezes')
        .doc(widget.tweezId)
        .get();

    if (!isLiked && snapshot.exists) {
      snapshot.reference.update({
        "likes": FieldValue.increment(1),
        "user_liked": FieldValue.arrayUnion([connectedUser])
      });
    }
    if (isLiked && snapshot.exists) {
      snapshot.reference.update({
        "likes": FieldValue.increment(-1),
        "user_liked": FieldValue.arrayRemove([connectedUser])
      });
      // }
    }
    return !isLiked;
  }
}
