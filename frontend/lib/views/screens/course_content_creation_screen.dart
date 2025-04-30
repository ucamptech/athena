import 'package:flutter/material.dart';
import './add_choices_screen.dart';
import './add_question-set_screen.dart';
import './add_exercises_screen.dart';

class CourseContentCreationScreen extends StatelessWidget {
  const CourseContentCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          title: const Text(
            'Course Content Creation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFE0D7F5),
            tabs: [
              Tab(text: 'Choices'),
              Tab(text: 'Questions'),
              Tab(text: 'Exercises'),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: TabBarView(
                children: [
                  CreateChoicesScreen(),
                  CreateQuestionSetScreen(),
                  CreateExerciseScreen(),
                ],
              ),
            ),
        ),
      ),
    );
  }
}