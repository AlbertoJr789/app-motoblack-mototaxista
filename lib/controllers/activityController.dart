import 'dart:convert';

import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController extends ChangeNotifier {

  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];
  Activity? currentActivity;

  Position? currentLocation;
  static final ApiClient apiClient = ApiClient.instance;

    getActivities(reset) async {
    try {
      if(reset){
        _page = 1;
        _hasMore = true;
        activities = [];
      }
      Response response = await Activity.getActivities(page: _page);
      if (response.data['success']) {
        final data = response.data['data']['result'];
        _hasMore = response.data['data']['hasMore'];
        _page++;
        for (var i = 0; i < data.length; i++) {
          activities.add(Activity.fromJson(data[i]));
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

   Future<bool> finishActivity({Activity? trip,double? evaluation,String? evaluationComment}) async {
    try {
      Response response = await apiClient.dio.patch(
        '/api/activity/${trip!.id}',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
        data: {'nota_passageiro': evaluation,'obs_agente': evaluationComment}
      );
      removeCurrentActivity();
      return true;
    } catch (e) {
      return false;
    }
  }

  checkCurrentActivity() async {    
    if(currentActivity == null){
      //get pendent activity from API
      final response = await Activity.getActivities(unrated: true);
      if (response.data['success']) {
          final data = response.data['data']['result'];
          try{
            currentActivity = Activity.fromJson(data[0]);
          }catch(e){
            currentActivity = null;
          }
      } else {
        throw response.data['message'];
      }
    }
  }

  removeCurrentActivity() async {
    currentActivity = null;
    notifyListeners();
  }


}
