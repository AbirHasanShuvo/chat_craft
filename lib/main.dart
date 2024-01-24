import 'package:chat_craft/screens/auth.dart';
import 'package:chat_craft/screens/chat.dart';
import 'package:chat_craft/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatCraft',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      //ha ha, we will use steambuilder, the automatically generated user system

      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          //this returning splashscreen will generate that screen until the below hasdata
          //found or we can say that bolowed if statement worked

          if(snapshot.hasData){
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      )
    );
  }
}
