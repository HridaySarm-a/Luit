import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:luit/global.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
List <UserInfo> info;

Future<String> signInWithGoogle() async 
{
	try
	{
		print("inside sign in");
		// await Firebase.initializeApp();

		var googleResponse = await googleSignIn.signIn();

		print(googleResponse);
		print("googleResponse");

			username = googleResponse.displayName;
			googleId = googleResponse.id;
			email = googleResponse.email;
			profilePic = googleResponse.photoUrl;

			print(googleResponse);

		return null;
	}
	catch(e)
	{
		Fluttertoast.showToast(msg: e);
		print("GOOGLE EXCDEPTION FAILED");
	}

	return null;
}

Future<void> signOutGoogle() async 
{
    await googleSignIn.signOut();
    // print("User Signed Out");
}