import 'dart:convert';

import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController extends ChangeNotifier {

  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];
  
  Activity? currentActivity;
  bool _enableTrip = false;
  var checkCancelled = 0;
  
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
    } on DioException {
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
    } on DioException {
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
    } on DioException {
      return false;
    }
  }

  Future<bool> refuseTrip(Activity activity,String agent) async {
    try {
      FirebaseDatabase.instance
          .ref('availableAgents')
          .child(agent)
          .child('trips')
          .child(activity.id.toString())
          .set(true);
      FirebaseDatabase.instance
          .ref('trips')
          .child(activity.uuid!)
          .child('agent')
          .child('accepting')
          .set(false);
      return true;
    } catch (e) {
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
    } on DioException {
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
    //get pendent activity from API
    final response = await Activity.getActivities(unrated: checkCancelled == 0 ? true : false,cancelled: checkCancelled == 0 ? true : false);
    if (response.data['success']) {
        final data = response.data['data']['result'];
        try{
          if(checkCancelled != 0 && data[0]['id'] != checkCancelled){ throw Exception();}
          currentActivity = Activity.fromJson(data[0]);
        }catch(e){
          if(checkCancelled != 0){
            checkCancelled = 0;
            checkCurrentActivity();
            return;
          }else{
            currentActivity = null;
          }
        }
    } else {
      throw response.data['message'];
    }
  }

 toggleTrip({bool enabled = true,bool notify = false}){
    _enableTrip = enabled;
    if(notify){
      notifyListeners();
    }
  }

  bool get enableTrip => _enableTrip;

  removeCurrentActivity() async {
    currentActivity = null;
    toggleTrip(enabled: true,notify: true);
  }

}
