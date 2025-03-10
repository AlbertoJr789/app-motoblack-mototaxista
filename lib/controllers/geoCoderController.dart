


import 'package:app_motoblack_mototaxista/controllers/hereAPIController.dart';
import 'package:app_motoblack_mototaxista/models/Address.dart';

abstract class Geocoder {

    geocode(Address address);

    Future<Address> inverseGeocode(double latitude,double longitude);

}

class GeoCoderController {

  Geocoder? geocoder;

  GeoCoderController({geocoder}): geocoder = geocoder ?? HereAPIController();

  // Future<Map<String,double>> geocode() async {
  //   return await geocoder!.geocode();
  // } 

  Future<Address> inverseGeocode(double latitude,double longitude) async {
    return await geocoder!.inverseGeocode(latitude, longitude);
  }

}