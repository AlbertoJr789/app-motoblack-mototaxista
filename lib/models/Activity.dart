import 'package:app_motoblack_mototaxista/controllers/apiClient.dart';
import 'package:app_motoblack_mototaxista/models/Address.dart';
import 'package:app_motoblack_mototaxista/models/Passenger.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

enum ActivityType { unknown, trip, carTrip, delivery }
enum WhoCancelled { unknown, passenger, agent }

ActivityType activityTypeToEnum(int type) {
  switch (type) {
    case 1:
      return ActivityType.trip;
    case 2:
      return ActivityType.carTrip;
    case 3:
      return ActivityType.delivery;
    default:
      return  ActivityType.unknown;
  }
}

WhoCancelled whoCancelledToEnum(int whoCancelled) {
  switch (whoCancelled) {
    case 1:
      return WhoCancelled.agent;
    case 2: 
      return WhoCancelled.passenger;
    default:
      return WhoCancelled.unknown;
  }
}


class Activity {
  int? id;
  String? uuid;
  ActivityType type;
  Passenger? passenger;
  Vehicle? vehicle;
  Address origin;
  Address destiny;
  double? price;
  double? evaluationAgent;
  double? evaluationPassenger;
  String? obs;
  String? route;
  bool? canceled;
  WhoCancelled? whoCancelled;
  String? cancellingReason;
  DateTime? createdAt;
  DateTime? finishedAt;

  static final ApiClient apiClient = ApiClient.instance;

  Activity(
      {this.id,
       this.uuid,
       required this.type,
       this.passenger,
       this.vehicle,
      required this.origin,
      required this.destiny,
       this.price,
       this.evaluationAgent,
       this.evaluationPassenger,
      this.obs,
       this.canceled,
       this.whoCancelled,
       this.route,
      this.cancellingReason,
       this.createdAt,
      this.finishedAt});

  factory Activity.fromJson(Map<String, dynamic> map) {
    return Activity(
        id: map['id'],
        uuid: map['uuid'],
        type: activityTypeToEnum(map['type']['tipo']),
        passenger: map['passenger'] != null ? Passenger.fromJson(map['passenger']) : null,
        vehicle: map['vehicle'] != null ? Vehicle.fromJson(map['vehicle']) : null,
        origin: Address.fromJson(map['origin']),
        destiny: Address.fromJson(map['destiny']),
        price: map['price'] != null ? double.parse(map['price'].toString()) : null,
        evaluationAgent: map['agentEvaluation'] != null ? double.parse(map['agentEvaluation'].toString()) : null,
        evaluationPassenger: map['passengerEvaluation'] != null ? double.parse(map['passengerEvaluation'].toString()) : null,
        route: map['route'],
        canceled: map['cancelled'] == 1 ? true : false,
        obs: map['agentObs'],
        cancellingReason: map['cancellingReason'],
        whoCancelled: map['whoCancelled'] != null ? whoCancelledToEnum(map['whoCancelled']) : null,
        createdAt: DateTime.parse(map['createdAt']),
        finishedAt: map['finishedAt'] != null ? DateTime.parse(map['finishedAt']) : null,
        );
  }

  String get typeName {
    switch(type){
      case ActivityType.trip: return 'Corrida';
      case ActivityType.carTrip: return 'Corrida';
      case ActivityType.delivery: return 'Entrega';
      default: return '';
    }
  }

  String get agentActivityType {
    switch(type){
      case ActivityType.trip: return 'Moto Black';
      case ActivityType.carTrip: return 'Motorista';
      case ActivityType.delivery: return 'Entregador';
      default: return '';
    }
  }

  static Future<Activity?> getApi(id) async {
    try{
      var response = await apiClient.dio.get(
          '/api/activity/$id',
          options: Options(
            contentType: Headers.jsonContentType,
            headers: {
              'accept': 'application/json',
            },
          ),
        );

        return Activity.fromJson(response.data['data']);
    }catch(e){
      return null;
    }
  }

  static Future<Response> getActivities({int page=1,bool unrated=false,bool cancelled=false}) async {
    var queryParameters = {'page': page};
    if(unrated){
      queryParameters['unrated'] = 1;
    }
    if(cancelled){
      queryParameters['cancelled'] = 1;
    }
    return await apiClient.dio.get(
        '/api/activity',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        queryParameters: queryParameters,
      );
  }

  static Future<Response> initActivity(FormData data) async {
    return await apiClient.dio.post(
        '/api/activity',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        data: data,
      );
  }

  String get distance {
    if(origin.latitude == null || origin.longitude == null || destiny.latitude == null || destiny.longitude == null){
      return '0';
    }
    double dist =  Geolocator.distanceBetween(origin.latitude!, origin.longitude!, destiny.latitude!, destiny.longitude!);
    if(dist < 1000){
      return '${dist.toStringAsFixed(2)} metros';
    }
    return '${(dist / 1000).toStringAsFixed(2)} km';
  }


}
