import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class VehicleController extends ChangeNotifier {

  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Vehicle> vehicles = [];
  Vehicle? currentVehicle;


  getVehicles() async {
    try {
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



}
