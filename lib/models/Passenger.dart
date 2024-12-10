import 'package:app_motoblack_mototaxista/models/Address.dart';

class Passenger {
  int? id;
  String name;
  Address? currentLocation;
  String? avatar;

  Passenger({this.id,required this.name,this.currentLocation, this.avatar});

  factory Passenger.fromJson(Map<String, dynamic> map) {
    return Passenger(
        id: map['id'],
        name: map['name'],
        avatar: map['avatar'], 
        );
  }


}
