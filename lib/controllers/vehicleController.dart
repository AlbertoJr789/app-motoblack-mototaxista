import 'dart:io';

import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

extension HexColor on Color {
  String _generateAlpha({required int alpha, required bool withAlpha}) {
    if (withAlpha) {
      return alpha.toRadixString(16).padLeft(2, '0');
    } else {
      return '';
    }
  }

  String toHex({bool leadingHashSign = true, bool withAlpha = false}) =>
      '${leadingHashSign ? '#' : ''}'
              '${_generateAlpha(alpha: alpha, withAlpha: withAlpha)}'                  
              '${red.toRadixString(16).padLeft(2, '0')}'              
              '${green.toRadixString(16).padLeft(2, '0')}'              
           '${blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
}
class VehicleController extends ChangeNotifier {
  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Vehicle> vehicles = [];
  Vehicle? currentVehicle;

  static final ApiClient apiClient = ApiClient.instance;

  getVehicles(bool reset) async {
    try {
      if (reset) {
        _page = 1;
        _hasMore = true;
        vehicles = [];
      }

      Response response = await Vehicle.getVehicles(_page);

      if (response.data['success']) {
        final data = response.data['data']['result'];
        _hasMore = response.data['data']['hasMore'];
        _page++;
        for (var i = 0; i < data.length; i++) {
          vehicles.add(Vehicle.fromJson(data[i]));
        }
      } else {
        _page = 1;
        _hasMore = true;
        throw response.data['message'];
      }
      error = '';
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  bool get hasMore => _hasMore;

  Future<Map<String, dynamic>> addVehicle(String brand, String model,
      String plate, Color color, VehicleType type, File document) async {
    try {
      FormData data = FormData.fromMap({
        'brand': brand,
        'model': model,
        'plate': plate,
        'color': color.toHex(),
        'type': type.index + 1,
        'document': await MultipartFile.fromFile(document.path)
      });

      Response response = await Vehicle.addVehicle(data);
      if (response.data['success']) {
        return {"error": false};
      } else {
        return {
          "error": response.data['message'],
          "status": response.statusCode
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response!.data['message'],
        "status": e.response!.statusCode
      };
    } catch (e) {
      return {"error": e.toString(), "status": 500};
    }
  }

  Future<Map<String, dynamic>> updateVehicle(int id, File document) async {
    try {
      FormData data = FormData.fromMap(
          {'_method': 'PATCH', 'document': await MultipartFile.fromFile(document.path)});
  
      Response response = await Vehicle.updateVehicle(id, data);
      if (response.data['success']) {
        return {"error": false};
      } else {
        return {
          "error": response.data['message'],
          "status": response.statusCode
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response!.data['message'],
        "status": e.response!.statusCode
      };
    } catch (e) {
      return {"error": e.toString(), "status": 500};
    }
  }

  Future<Map<String, dynamic>> deleteVehicle(int id) async {
    try {
      Response response = await Vehicle.deleteVehicle(id);
      if (response.data['success']) {
        return {"error": false};
      } else {
        return {
          "error": response.data['message'],
          "status": response.statusCode
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response!.data['message'],
        "status": e.response!.statusCode
      };
    } catch (e) {
      return {"error": e.toString(), "status": 500};
    }
  }

  Future<Map<String, dynamic>> changeActiveVehicle(int id) async {
    try {
      Response response = await Vehicle.changeActiveVehicle(id);
      if (response.data['success']) {
        return {"error": false};
      } else {
        return {
          "error": response.data['message'],
          "status": response.statusCode
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response!.data['message'],
        "status": e.response!.statusCode
      };
    } catch (e) {
      return {"error": e.toString(), "status": 500};
    }
  }
}
