import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';

class Tweezes extends StatefulWidget {
  const Tweezes({Key? key}) : super(key: key);

  @override
  State<Tweezes> createState() => _TweezesState();
}

class _TweezesState extends State<Tweezes> {
  @override
  Widget build(BuildContext context) {
    final TextStyle? contentTheme = Theme.of(context).textTheme.bodyText1;
    final String content = "Good morniiiinngggg :)))))";
    String formattedDate =
        DateFormat('dd-MM-yyyy - kk:mm').format(DateTime.now());

    return AspectRatio(
        aspectRatio: 5 / 2,
        child: Card(
            child: Column(
          children: [
            Row(
              children: <Widget>[
                const Expanded(
                  flex: 1,
                  child: CircleAvatar(
                    child: Text('P'),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[Text("Pedro")],
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
                        Text(content, style: contentTheme),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 10),
                LikeButton(
                  onTap: onLikeButtonTapped,
                ),
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
                const SizedBox(width: 90),
                Text(formattedDate)
              ],
            )
          ],
        )));
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    return !isLiked;
  }
}

//         child: Column(children: const <Widget>[
//           _TweezDetails(),
//           _Tweez(),
//           _TweezButtons()
//         ]),
//       ),
//     );
//   }
// }

// class _Tweez extends StatelessWidget {
//   const _Tweez({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 3,
//       child: Row(
//         children: <Widget>[_TweezData()],
//       ),
//     );
//   }
// }

// class _TweezData extends StatelessWidget {
//   const _TweezData({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final TextStyle? summaryTheme = Theme.of(context).textTheme.bodyText1;
//     final String summary = "Good morniiiinngggg :)))))";

//     return Expanded(
//       flex: 3,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           const SizedBox(height: 20),
//           Text(summary, style: summaryTheme),
//         ],
//       ),
//     );
//   }
// }

// class _TweezDetails extends StatelessWidget {
//   const _TweezDetails({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[_UserImage(), _Username()],
//       // children: <Widget>[_Username()],
//     );
//   }
// }

// class _Username extends StatelessWidget {
//   const _Username({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 7,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text("Pedro29"),
//         ],
//       ),
//     );
//   }
// }

// class _UserImage extends StatelessWidget {
//   const _UserImage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: 1,
//       child: CircleAvatar(
//         child: const Text('P'),
//       ),
//     );
//   }
// }

// class _TweezButtons extends StatefulWidget {
//   const _TweezButtons({Key? key}) : super(key: key);

//   @override
//   State<_TweezButtons> createState() => __TweezButtonsState();
// }

// class __TweezButtonsState extends State<_TweezButtons> {
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     String formattedDate = DateFormat('dd-MM-yyyy - kk:mm').format(now);
//     return Row(
//       children: [
//         const SizedBox(width: 10),
//         LikeButton(
//           onTap: onLikeButtonTapped,
//         ),
//         const SizedBox(width: 10),
//         IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.comment),
//         ),
//         const SizedBox(width: 10),
//         IconButton(
//           onPressed: () {},
//           icon: const Icon(Icons.share),
//         ),
//         const SizedBox(width: 90),
//         Text(formattedDate)
//       ],
//     );
//   }


