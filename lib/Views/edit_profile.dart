import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/profile_page.dart';
import '../validator.dart';

class EditProfile extends StatefulWidget {
  final User user;
  const EditProfile(this.user, {Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final bool _isObscure = true;

  final _usernameTextController = TextEditingController();
  final _bioTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final User _currentUser = widget.user;
    CollectionReference users = db.collection('users');

    print(_currentUser.displayName);
    print(_currentUser.uid);
    return FutureBuilder(
        future: users.doc(_currentUser.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text('Document does not exist');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final Map<String, dynamic> _userData =
                snapshot.data!.data() as Map<String, dynamic>;

            _usernameTextController.text = _userData['username'];
            _bioTextController.text = _userData['bio'];
            _passwordTextController.text = _userData['password'];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit Profile'),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ),
              body: Container(
                padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1))
                                  ],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          _userData['profile picture']))),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  color: Colors.blue,
                                ),
                                child:
                                    const Icon(Icons.edit, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _usernameTextController,
                        validator: (value) => Validator.validateUsername(
                          username: value.toString(),
                        ),
                        decoration: InputDecoration(
                            hintText: "Username",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            )),
                      ),
                      TextFormField(
                        controller: _bioTextController,
                        decoration: InputDecoration(
                            hintText: "Bio",
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            )),
                      ),
                      TextFormField(
                        controller: _passwordTextController,
                        obscureText: _isObscure,
                        validator: (value) => Validator.validatePassword(
                          password: value.toString(),
                        ),
                        decoration: InputDecoration(
                            hintText: "Password",
                            // suffixIcon: IconButton(
                            //   icon: Icon(
                            //     _isObscure
                            //         ? Icons.visibility
                            //         : Icons.visibility_off,
                            //   ),
                            //   onPressed: () {
                            //     setState(() {
                            //       _isObscure = !_isObscure;
                            //     });
                            //   },
                            // ),
                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            )),
                      ),
                      // buildTextField("Username", "Demon", false),
                      // buildTextField("Bio", "Today is beautiful", false),
                      // buildTextField("Password", "*********", true),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    letterSpacing: 2),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final credential = EmailAuthProvider.credential(
                                    email: _currentUser.email!,
                                    password: _userData['password']);
                                final updateData = db
                                    .collection('users')
                                    .doc(_currentUser.uid);
                                updateData.update({
                                  'username': _usernameTextController.text,
                                  'bio': _bioTextController.text,
                                  'password': _passwordTextController.text
                                });

                                _currentUser
                                    .reauthenticateWithCredential(credential);
                                _currentUser.updatePassword(
                                    _passwordTextController.text);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(_currentUser),
                                  ),
                                  ModalRoute.withName('/'),
                                );
                              },
                              child: const Text(
                                'SAVE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    letterSpacing: 2),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return const Text('loading');
        });
  }

  // Widget buildTextField(
  //     String labelText, String placeholder, bool isPasswordTextField) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 30),

  //     // child: TextField(
  //     //   obscureText: isPasswordTextField ? isObscurePassword : false,
  //     //   decoration: InputDecoration(
  //     //       suffixIcon: isPasswordTextField
  //     //           ? IconButton(
  //     //               onPressed: () {},
  //     //               icon: const Icon(Icons.remove_red_eye, color: Colors.grey))
  //     //           : null,
  //     //       labelText: labelText,
  //     //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //     //       hintStyle: const TextStyle(
  //     //           fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
  //     // ),
  //   );
  // }
}
