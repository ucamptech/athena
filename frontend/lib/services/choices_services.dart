import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:duolingo/utils/logger_utils.dart';

class ChoicesServices {

  static const String _baseUrl = "http://10.0.2.2:3000/api/choices";
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  Future <bool> createChoiceData({ required Map<String, dynamic> data }) async {
  final body = jsonEncode(data);
  try {
    final response = await http.post(Uri.parse(_baseUrl), headers: _headers, body: body);
    var json = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {

      LoggerUtils.log('Message: ${json['message']}');
      LoggerUtils.log('Data: ${json['data']}');
      return true;
    } 
    else {
      LoggerUtils.errorLog('Server error: ${json['message']}');
      return false;
    }
  } 
  catch (error) {
    LoggerUtils.errorLog('Error: $error');
    return false;
  }
}

Future <List<Map<String, dynamic>>> getChoiceData() async {

  try {
    final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
    final List<dynamic> jsonList = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      LoggerUtils.log('data: ${const JsonEncoder.withIndent('  ').convert(jsonList)}');
      
      return List<Map<String, dynamic>>.from(jsonList);
    } 
    else {
      LoggerUtils.errorLog('Server error: ${response.statusCode}');;
      throw Exception("Failed to load choices");
    }
  } 
  catch (error) {
    LoggerUtils.errorLog('Error: $error');
    throw Exception("Error loading choices");
  }
}

Future <void> updateChoiceData(Map<String, dynamic> data, int id) async {
  final body = jsonEncode(data);

  try {
    final response = await http.patch(Uri.parse('${_baseUrl}/${id}'), headers: _headers, body: body);
    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      LoggerUtils.log('Message: ${jsonResponse['message']}');
      LoggerUtils.log('Data: ${jsonResponse['data']}');
    } 
    else {
      LoggerUtils.errorLog('Server error: ${jsonResponse['message']}');
    }
  } 
  catch (error) {
    LoggerUtils.errorLog('Error: $error');
  }
}
}