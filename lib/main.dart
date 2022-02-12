import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(
          //You don't need the google-service json file anymore
          //The Firebase options parameters noww have to come from the project settings on firebase console
            options: FirebaseOptions(
                apiKey: "AIzaSyCJI0laVxjjLa9k3KVxAAazSXXQ9bNp5aw", //General tab => Web API key
                appId: "1:487613870980:android:10b3372095e46c8d12e3d1", // GEneral tab => Your apps => App Id
                messagingSenderId: "AAAAcYgNM4Q:APA91bHPw1vpy4MyFsyqPZDfW8C5yMm9xYcB3NywroRuRMTmmuA_k5_qms5JkjmIXcA4giSyJEAWIlzq1b3yBWJ0a-nuq2YMNTNn5plBXbtSetyUVEPfvVbXpcjQFaHbN8Hn06oqQDgJ", // Cloud messaging tab => Server key
            projectId: "test-eac97" // General tab => project id
            )),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            print(snapshot.data);
            print(snapshot.error);
            return  const HomePage();
          } else {
            return const CircularProgressIndicator();
          }

        },
      ),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController email_sign_up = TextEditingController();
  TextEditingController password_sign_up = TextEditingController();
  TextEditingController password_sign_in = TextEditingController();
  TextEditingController email_sign_in = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User? gUser;

    return Scaffold(
        body: Container(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),

            Text( gUser == null ? "user not signed in" : gUser.uid),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size.width * 0.45,
                  child: Column(
                    children: [
                      const Text("Sign up"),

                      TextFormField(
                        controller: email_sign_up,
                      ),


                      TextFormField(
                        decoration: InputDecoration(hintText: "password"),
                        controller: password_sign_up,
                      ),

                      ElevatedButton(
                          onPressed: (){
                            FirebaseAuth auth = FirebaseAuth.instance;
                            setState(() async{

                              gUser = (await auth.createUserWithEmailAndPassword(email: email_sign_up.text, password: password_sign_up.text)).user;
                            });

                          },
                          child: const Text("Sign up"))

                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.45,
                  child: Column(
                    children: [
                      const Text("Sign in"),

                      TextFormField(
                        controller: email_sign_in,
                      ),


                      TextFormField(
                        controller: password_sign_in,
                      ),

                      ElevatedButton(
                          onPressed: () {

                            FirebaseAuth auth = FirebaseAuth.instance;
                            setState(() async{

                              gUser = (await  auth.signInWithEmailAndPassword(email: email_sign_up.text, password: password_sign_up.text)).user;
                            });

                          }, child: const Text("Sign in")),

                      ElevatedButton(
                        child: Text("Sign in with google"),
                        onPressed: () async{
                            FirebaseAuth firebaseAuth = FirebaseAuth.instance;

                            final GoogleSignIn googleSignIn = GoogleSignIn();

                            await googleSignIn.signOut();
                            final GoogleSignInAccount? googleUser = await (googleSignIn.signIn());
                            final GoogleSignInAuthentication googleAuth =
                            await googleUser!.authentication;

                            // Create a new credential
                            final GoogleAuthCredential googleCredential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            ) as GoogleAuthCredential;

                            // Once signed in, return the UserCredential
                            UserCredential credential =
                            await firebaseAuth.signInWithCredential(googleCredential);
                            User user = credential.user!;

                            assert(!user.isAnonymous);
                            // assert (await user.getIdToken() != null);

                            final User currentUser = firebaseAuth.currentUser!;
                            assert(currentUser.uid == user.uid);

                            gUser = user;
                        },
                      )

                    ],
                  ),
                ),
              ],
            ),
          ],
        )
        )
    );
  }
}
