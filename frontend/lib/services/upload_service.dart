import 'dart:convert';
import 'dart:io';
import 'package:duolingo/utils/logger_utils.dart';
import 'package:http/http.dart' as http;

class UploadService{
    static const String _baseUrl = "http://10.0.2.2:3000/api/upload";

    Future<String?> uploadImage(File file) async {
      final uri = Uri.parse('$_baseUrl/image');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);
      final json = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return json['path'];
      } 
      else {
        LoggerUtils.errorLog('Upload Failed: ${json['message']}');
        return null;
      }   
    } 

    Future<String?> uploadAudio(File file) async {
      final uri = Uri.parse('$_baseUrl/audio');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);
      final json = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return json['path'];
      } 
      else {
        LoggerUtils.errorLog('Upload Failed: ${json['message']}');
        return null;
      }   
    } 

}