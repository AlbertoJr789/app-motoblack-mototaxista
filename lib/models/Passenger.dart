import 'package:app_motoblack_mototaxista/models/Address.dart';

class Passenger {
  int? id;
  String name;
  int? userId;
  Address? currentLocation;
  double? rate;
  String? avatar;

  Passenger({this.id,required this.name,this.userId,this.currentLocation, this.avatar, this.rate});

  factory Passenger.fromJson(Map<String, dynamic> map) {
    return Passenger(
        id: map['id'],
        userId: map['user_id'],
        name: map['name'],
        avatar: map['avatar'], 
        rate: map['rate'],
        );
  }


}
