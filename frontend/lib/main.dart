import 'package:flutter/material.dart';
import 'username.dart';
import './views/screens/course_content_creation_screen.dart';
import './home.dart';
import './views/screens/register_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'Athena',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
        home: RegisterScreen(),
        routes: {
          '/home': (context) => HomeScreen(userID: "test"),
          '/register': (context) => RegisterScreen(),
          '/contentCreation': (context) => CourseContentCreationScreen(),
          '/inputUser' : (context) => UsernameScreen(),
        },
      );
  }
}
