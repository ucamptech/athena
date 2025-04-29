import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/choices_services.dart';
import '../../services/upload_service.dart';
import '../../utils/logger_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CreateChoicesScreen extends StatefulWidget {
  const CreateChoicesScreen({super.key});

  @override
  State<CreateChoicesScreen> createState() => _CreateChoicesScreenState();
}

class _CreateChoicesScreenState extends State<CreateChoicesScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final ChoicesServices _choicesServices = ChoicesServices();
  final UploadService _uploadService = UploadService();

  File? questionImage;
  File? questionAudio;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        questionImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (pickedFile != null) {
      setState(() {
        questionAudio = File(pickedFile.files.single.path!);
      });
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
                    'Create New Choices',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: 'Choice ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
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
                        "choiceID": idController.text,
                        "image": null,
                        "name": nameController.text,
                        "audio": null,
                      };

                      bool isChoiceCreated = await _choicesServices.createChoiceData(data: data);
                      if (isChoiceCreated) {
                        final Map<String, dynamic> updateData = {};

                        if (questionImage != null) {
                          final imagePath = await _uploadService.uploadImage(questionImage!);
                          if (imagePath != null) {
                            updateData['image'] = imagePath;
                          }
                        }

                        if (questionAudio != null) {
                          final audioPath = await _uploadService.uploadAudio(questionAudio!);
                          if (audioPath != null) {
                            updateData['audio'] = audioPath;
                          }
                        }

                        if (updateData.isNotEmpty) {
                          await _choicesServices.updateChoiceData(
                            updateData,
                            int.parse(idController.text),
                          );
                        }
                      } else {
                        LoggerUtils.log("Skipping file upload.");
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isChoiceCreated
                                ? 'Exercise created successfully'
                                : 'Exercise creation failed',
                          ),
                          backgroundColor: isChoiceCreated ? Colors.green : Colors.red,
                        ),
                      );
                    },
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