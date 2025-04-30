import 'dart:io';
import 'package:duolingo/services/question-set_services.dart';
import 'package:flutter/material.dart';
import '../../services/choices_services.dart';
import '../../services/upload_service.dart';
import '../../utils/logger_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

  List<Map<String, dynamic>> choices = [];
  List<Map<String, dynamic>> selectedOptions = [];
  Map<String, dynamic>? selectedCorrectAnswer;

  bool isChoosingCorrectAnswer = false;

  File? questionImage;
  File? questionAudio;

  void initState() {
    super.initState();
    fetchChoices();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      questionImage = File(pickedFile!.path);
    });
  }

  Future<void> _pickAudio() async {
    final pickedFile  = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (pickedFile != null) {
      setState(() {
        questionAudio = File(pickedFile.files.single.path!);
      });
    }
  }

  Future<void> fetchChoices() async {
    try {
      final response = await _choicesServices.getChoiceData();
      setState(() {
        choices = List<Map<String, dynamic>>.from(response);
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
                    'Create New Question Set',
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
                 
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          isChoosingCorrectAnswer = !isChoosingCorrectAnswer;
                        });
                      },
                      child: Text(isChoosingCorrectAnswer
                          ? 'Toggle to Choose Options'
                          : 'Toggle to Choose Correct Answer'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Text(
                        'Select Choices (double-tap to add/remove): ' +
                            (isChoosingCorrectAnswer
                                ? 'Currently Choosing Correct Answer'
                                : 'Currently Choosing Options'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: choices.map((choice) {
                              final isOption = selectedOptions.contains(choice);
                              final isCorrectAnswer = selectedCorrectAnswer == choice;
                              
                              return GestureDetector(
                                onDoubleTap: () {
                                  setState(() {
                                    if (isCorrectAnswer) {
                                      selectedCorrectAnswer = null;
                                    } 
                                    else if (isOption) {
                                      selectedOptions.remove(choice);
                                    } 
                                    else {
                                      if (isChoosingCorrectAnswer) 
                                      {
                                        if (selectedCorrectAnswer != null) {
                                          selectedCorrectAnswer = null;
                                        }
                                        selectedCorrectAnswer = choice;
                                      } 
                                      else {
                                        if (selectedOptions.length < 3) {
                                          selectedOptions.add(choice); 
                                        } 
                                        else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('You can only select up to 3 options.'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  });
                                },
                                child: Chip(
                                  backgroundColor: isCorrectAnswer
                                      ? Colors.green
                                      : (isOption ? Colors.blue : Colors.grey.shade300),
                                  label: Text(choice['name'] ?? 'N/A'),
                                  labelStyle: TextStyle(
                                    color: isCorrectAnswer
                                        ? Colors.white
                                        : (isOption ? Colors.white : Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Center(child: const Text('Selected Options:', style: TextStyle(fontWeight: FontWeight.bold))),
                                Wrap(
                                  spacing: 8,
                                  children: selectedOptions.map((c) {
                                    return Chip(label: Text(c['name'] ?? 'N/A'));
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Center(child: const Text('Selected Correct Answer:', style: TextStyle(fontWeight: FontWeight.bold))),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (selectedCorrectAnswer != null)
                                      Chip(label: Text(selectedCorrectAnswer!['name'] ?? 'N/A')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                        onPressed: _pickImage,
                        child: Text(
                          questionImage == null
                              ? 'Pick Image'
                              : questionImage!.path.split('/').last,
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                        onPressed: _pickAudio,
                        child: Text(
                            questionAudio == null 
                                ? 'Pick Audio' 
                                : questionAudio!.path.split('/').last,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 60),

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
                        if (selectedCorrectAnswer == null || selectedOptions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select choices')),
                          );
                          return;
                        }
                    
                        final data = {
                          "questionID": idController.text,
                          "question": questionController.text,
                          "questionImage": null,
                          "questionAudio": null,
                          "options": selectedOptions.map((c) => c['choiceID']).toList(),
                          "correctAnswer": [int.parse(selectedCorrectAnswer?['choiceID'])],
                        };
                    
                        bool isQuestionSetCreated =
                            await _questionSetServices.createQuestionSetData(data: data);
                        if (isQuestionSetCreated) {
                    
                          final Map<String, dynamic> updateData = {};
                    
                          if (questionImage != null) {
                            final imagePath = await _uploadService.uploadImage(questionImage!);
                            if (imagePath != null) {
                              updateData['questionImage'] = imagePath;
                            }
                          }
                    
                          if (questionAudio != null) {
                            final audioPath = await _uploadService.uploadAudio(questionAudio!);
                            if (audioPath != null) {
                              updateData['questionAudio'] = audioPath;
                            }
                          }
                    
                          if (updateData.isNotEmpty) {
                            await _questionSetServices.updateQuestionSetData(
                              updateData,
                              int.parse(idController.text),
                            );
                          }
                        } 
                        else {
                          LoggerUtils.log(" Skipping file upload.");
                        }
                    
                        LoggerUtils.log(data.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isQuestionSetCreated
                                  ? 'Exercise created Successfully'
                                  : 'Exercise creation failed',
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