import 'package:flutter/material.dart';
import '../../services/exercise_services.dart';
import '../../services/question-set_services.dart';
import '../../utils/logger_utils.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final TextEditingController idController = TextEditingController();
  final ExerciseServices _exerciseServices = ExerciseServices();
  final QuestionSetServices _questionSetServices = QuestionSetServices();

  List<Map<String, dynamic>> questionSets = [];
  Map<String, dynamic>? selectedQuestionSet;

  @override
  void initState() {
    super.initState();
    fetchQuestionSets();
  }

  Future<void> fetchQuestionSets() async {
    try {
      final response = await _questionSetServices.getQuestionSetData();
      setState(() {
        questionSets = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      LoggerUtils.errorLog('Error fetching question sets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    'Create New Exercise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'Exercise ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    child: DropdownMenu<Map<String, dynamic>>(
                      initialSelection: selectedQuestionSet,
                      label: const Text("Select Question Set"),
                      textStyle: const TextStyle(fontSize: 14),
                      menuHeight: 250,
                      dropdownMenuEntries: questionSets.map((qSet) {
                        return DropdownMenuEntry<Map<String, dynamic>>(
                          value: qSet,
                          label: qSet['question'] ?? 'No Title',
                        );
                      }).toList(),
                      onSelected: (value) {
                        setState(() {
                          selectedQuestionSet = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  Divider(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        final data = {
                          "exerciseID": idController.text,
                          "exerciseSession": null,
                          "questionSet": [int.parse(selectedQuestionSet?['questionID'])],
                        };

                        bool isExerciseCreated = await _exerciseServices.createExerciseData(data: data);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isExerciseCreated ? 'Exercise created Successfully' : 'Exercise creation failed',
                            ),
                            backgroundColor: isExerciseCreated ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}