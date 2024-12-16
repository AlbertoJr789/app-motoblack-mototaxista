import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/main.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Address.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/models/Passenger.dart';
import 'package:app_motoblack_mototaxista/screens/login.dart';
import 'package:app_motoblack_mototaxista/util/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController extends ChangeNotifier {

  final ApiClient apiClient = ApiClient.instance;
  Activity? currentActivity;
  Position? currentLocation;

  Future<String> getOnline() async {
    var response = null;
    try {
      response = await apiClient.dio.get(
        '/api/getOnline',
        options: Options(
            contentType: Headers.jsonContentType,
            headers: {'accept': 'application/json'}),
      );
      Agent.setUuid(response.data['message']);
      return response.data['message'];
    } on DioException catch (e) {
      return '';
    }
  }

  
  Future<bool> getOffline() async {
    var response = null;
    try {
      response = await apiClient.dio.get(
        '/api/getOffline',
        options: Options(
            contentType: Headers.jsonContentType,
            headers: {'accept': 'application/json'}),
      );
      Agent.setUuid('');
      return false;
    } on DioException catch (e) {
      return true;
    }
  }
  
  Future<bool> acceptTrip(Activity activity) async {
    var response = null;
    try {
      response = await apiClient.dio.patch(
        '/api/acceptTrip/${activity.id}',
        options: Options(
            contentType: Headers.jsonContentType,
            headers: {'accept': 'application/json'}),
      );
      currentActivity = activity;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      return false;
    }
  }

  Future<bool> refuseTrip(id) async {
    var response = null;
    try {
      
      return true;
    } on DioException catch (e) {
      return false;
    }
  }

   Future<bool> cancelActivity({Activity? trip,String? reason,bool alreadyCancelled=false}) async {
    try {

      if(alreadyCancelled){ //if it was cancelled from somewhere else
        currentActivity = null;
        notifyListeners();
        return true;
      }

      Response response = await apiClient.dio.post(
        '/api/cancel/${trip!.id}',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
        data: {'reason': reason}
      );
      currentActivity = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

}
