import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/entities/insumo.dart';
import '../../core/entities/producto.dart';
import '../../core/entities/configuracion.dart';
import '../../core/repositories/admin_repository.dart';
import '../../core/result.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Change this if your functions are in a different region
  static const String _region = 'us-central1';
  static const String _projectId = 'sistema-pizzas';

  Future<dynamic> _callFunction(
    String name, [
    Map<String, dynamic>? parameters,
  ]) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Manual REST call for Windows as cloud_functions plugin is not yet registered for Windows
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final token = await user.getIdToken();
      final url = Uri.parse(
        'https://$_region-$_projectId.cloudfunctions.net/$name',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'data': parameters ?? {}}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['result'];
      } else {
        throw Exception('Error al llamar a la función $name: ${response.body}');
      }
    } else {
      // Standard plugin call for other platforms
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(parameters);
      return result.data;
    }
  }

  @override
  Future<Result<String>> crearInsumo(Insumo insumo) async {
    try {
      final data = await _callFunction('crearInsumo', {
        'nombre': insumo.nombre,
        'unidad': insumo.unidad,
        'stockActual': insumo.stockActual,
        'stockMinimo': insumo.stockMinimo,
        'costoUnitario': insumo.costoUnitario,
      });
      return Result.success(data['id']);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> actualizarInsumo(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _callFunction('actualizarInsumo', {'id': id, ...data});
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Insumo>>> listarInsumos() async {
    try {
      final data = await _callFunction('listarInsumos');
      final List<dynamic> list = data['insumos'];
      final insumos = list
          .map((e) => Insumo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Result.success(insumos);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<String>> crearProducto(Producto producto) async {
    try {
      final data = await _callFunction('crearProducto', {
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'receta': producto.receta.map((e) => e.toJson()).toList(),
      });
      return Result.success(data['id']);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Producto>>> listarProductos() async {
    try {
      final data = await _callFunction('listarProductos');
      final List<dynamic> list = data['productos'];
      final productos = list
          .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Result.success(productos);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> guardarConfiguracion(Configuracion config) async {
    try {
      await _callFunction('guardarConfiguracion', config.toJson());
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Configuracion>> obtenerConfiguracion() async {
    try {
      final data = await _callFunction('obtenerConfiguracion');
      final config = Configuracion.fromJson(
        Map<String, dynamic>.from(data['config']),
      );
      return Result.success(config);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
