import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/question-set_services.dart';
import '../../services/choices_services.dart';
import '../../services/upload_service.dart';
import '../../utils/logger_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreateQuestionSetScreen extends StatefulWidget {
  const CreateQuestionSetScreen({super.key});

  @override
  State<CreateQuestionSetScreen> createState() => _CreateQuestionSetScreenState();
}

class _CreateQuestionSetScreenState extends State<CreateQuestionSetScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  final ChoicesServices _choicesServices = ChoicesServices();
  final QuestionSetServices _questionSetServices = QuestionSetServices();
  final UploadService _uploadService = UploadService();


  List<Map<String, dynamic>> questionSets = [];
  Map<String, dynamic>? selectedQuestionSet;

  File? questionImage;
  File? questionAudio;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      questionImage = File(pickedFile!.path);
    });
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
                      labelText: 'Question ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: 'Question',
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(questionImage == null ? 'Pick Image' : 'Image Selected'),
                  ),
                  const SizedBox(height: 30),
                  Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        if (questionImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select both image and audio!')),
                          );
                          return;
                        }

                          final data = {
                            "questionID": idController.text,
                            "question": questionController.text,
                            "questionImage": null,
                            "questionAudio": null,
                            "options": null,
                            "correctAnswer": null,
                          };

                          bool isQuestionSetCreated = await _questionSetServices.createQuestionSetData(data: data);
                            if (isQuestionSetCreated) {
                              if (questionImage != null) {
                                final imagePath = await _uploadService.uploadImage(questionImage!);

                                if (imagePath != null) {
                                  final updateData = {
                                    "questionImage": imagePath,
                                  };

                                  await _questionSetServices.updateQuestionSetData(
                                    updateData,
                                    int.parse(idController.text),
                                  );
                                }
                              }
                            } else {
                              LoggerUtils.log("Question set creation failed. Skipping image upload.");
                            }
                          LoggerUtils.log(data.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isQuestionSetCreated ? 'Exercise created Successfully' : 'Exercise creation failed',
                              ),
                              backgroundColor: isQuestionSetCreated ? Colors.green : Colors.red,
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