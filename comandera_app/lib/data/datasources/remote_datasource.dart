import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class RemoteDatasource {
  Future<dynamic> callFunction(String name, [Map<String, dynamic>? parameters]);
}

class FirebaseFunctionsDatasource implements RemoteDatasource {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configuration for manual REST calls (Windows fallback)
  // TODO: Move project ID to a configuration file or environment variable
  static const String _projectId = 'sistema-pizzas';
  static const String _region = 'us-central1';

  @override
  Future<dynamic> callFunction(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _callWindowsManual(name, parameters);
    } else {
      return _callPlugin(name, parameters);
    }
  }

  Future<dynamic> _callPlugin(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    final callable = _functions.httpsCallable(name);
    try {
      final result = await callable.call(parameters);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Error calling function $name: ${e.message} (${e.code})');
    } catch (e) {
      throw Exception('Unknown error calling function $name: $e');
    }
  }

  Future<dynamic> _callWindowsManual(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    final user = _auth.currentUser;
    // Note: Authentication is enforced by the backend, but we need a token if available.
    // If the function is open (e.g. login), user might be null.
    // However, most admin functions require auth.
    String? token;
    if (user != null) {
      token = await user.getIdToken();
    }

    // Determine URL based on Debug Mode (Emulator) vs Production
    String urlString;
    if (kDebugMode) {
      // Emulator URL
      // localhost works if the app is on the same machine as the emulator
      // For Android Emulator, localhost is 10.0.2.2, but the logic in main.dart usually handles the mapping if using the plugin.
      // However, for manual HTTP calls on Windows (which accesses localhost directy), 127.0.0.1 is correct.
      // If running on Android device, this manual call isn't used (it uses _callPlugin).
      urlString = 'http://127.0.0.1:5001/$_projectId/$_region/$name';
    } else {
      // Production URL
      urlString = 'https://$_region-$_projectId.cloudfunctions.net/$name';
    }

    final url = Uri.parse(urlString);

    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        // Callable functions expect a JSON body with a 'data' key
        body: jsonEncode({'data': parameters ?? {}}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Callable functions return a JSON with a 'result' key
        if (decoded is Map && decoded.containsKey('result')) {
          return decoded['result'];
        }
        // If it's a raw return (rare for callable), just return body
        return decoded;
      } else {
        // Try to parse error message from body
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody['error'] != null) {
            errorMsg = errBody['error']['message'] ?? errorMsg;
          }
        } catch (_) {}
        throw Exception('Error al llamar a la función $name: $errorMsg');
      }
    } catch (e) {
      throw Exception('Error de red llamar a la función $name: $e');
    }
  }
}
