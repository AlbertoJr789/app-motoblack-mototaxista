import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/main.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/screens/login.dart';
import 'package:app_motoblack_mototaxista/util/util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityController {

  BuildContext context;

  ActivityController(this.context);

  final ApiClient apiClient = ApiClient.instance;

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
      String message =  e.response?.data['message'] ?? e.toString();
      showAlert(context, "Erro ao iniciar sessão", "Tente novamente mais tarde", message);
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
      String message =  e.response?.data['message'] ?? e.toString();
      showAlert(context, "Erro ao finalizar sessão", "Tente novamente mais tarde", message);
      return true;
    }
  }
  

}
