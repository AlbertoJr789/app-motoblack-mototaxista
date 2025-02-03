
import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum VehicleType { motorcycle, car, unknown }

VehicleType _vehicleTypeToEnum(type) {
  switch (type) {
    case 1:
      return VehicleType.motorcycle;
    case 2:
      return VehicleType.car;
    default:
      return VehicleType.unknown;
  }
}

class Vehicle {
  int id;
  VehicleType type;
  String plate;
  String model;
  String brand;
  String color;
  String? picture;
  bool currentActiveVehicle;


  Vehicle(
      {required this.id,
      required this.type,
      required this.plate,
      required this.model,
      required this.brand,
      required this.color,
      this.picture,
      this.currentActiveVehicle = false});



  static final ApiClient apiClient = ApiClient.instance;

  factory Vehicle.fromJson(Map<String, dynamic> map) {
    return Vehicle(
        id: map['id'],
        type: _vehicleTypeToEnum(map['type']),
        plate: map['plate'],
        model: map['model'],
        brand: map['brand'],
        color: map['color'],
        currentActiveVehicle: map['currentActiveVehicle']);


  }

  String get typeName {
    switch(type){
      case VehicleType.motorcycle: return 'Moto';
      case VehicleType.car: return 'Carro';
      default: return '';
    }
  }

  IconData get icon {
    switch(type){
      case VehicleType.motorcycle: return Icons.motorcycle;
      case VehicleType.car: return Icons.car_crash;
      default: return Icons.question_mark;
    }
  }


  static Future<Response> getVehicles(int page) async {
    return await apiClient.dio.get(
        '/api/vehicle',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        queryParameters: {'page': page},
      );
  }

  static Future<Response> addVehicle(FormData data) async {
    return await apiClient.dio.post(
      '/api/vehicle',
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        headers: {
          'accept': 'application/json',
        },
      ),
      data: data,
    );
  }


}
