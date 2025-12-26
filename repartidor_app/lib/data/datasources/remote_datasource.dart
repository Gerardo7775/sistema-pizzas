import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class RemoteDatasource {
  Future<dynamic> callFunction(String name, [Map<String, dynamic>? data]);
}

class FirebaseFunctionsDatasource implements RemoteDatasource {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // TODO: Move this to a configuration file
  static const String _projectId = 'sistema-pizzas';
  static const String _region = 'us-central1';

  @override
  Future<dynamic> callFunction(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _callFunctionWindows(name, data);
    } else {
      return _callFunctionStandard(name, data);
    }
  }

  Future<dynamic> _callFunctionStandard(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return result.data;
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw Exception('${e.code}: ${e.message}');
      }
      throw Exception('Error calling function $name: $e');
    }
  }

  Future<dynamic> _callFunctionWindows(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final String baseUrl;
      if (kDebugMode) {
        // Emulator URL
        baseUrl = 'http://127.0.0.1:5001/$_projectId/$_region';
      } else {
        // Production URL
        baseUrl = 'https://$_region-$_projectId.cloudfunctions.net';
      }

      final url = Uri.parse('$baseUrl/$name');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'data': data ?? {}}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // The response format from callable functions wraps the result in 'result' or 'data'.
        // Standard callable protocol returns { result: ... }
        if (decoded is Map<String, dynamic> && decoded.containsKey('result')) {
          return decoded['result'];
        }
        return decoded;
      } else {
        throw Exception(
          'Error executing function $name (Status: ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error making request to $name: $e');
    }
  }
}
