
import 'dart:async';

import 'package:app_motoblack_mototaxista/controllers/geoCoderController.dart';
import 'package:app_motoblack_mototaxista/models/Address.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HereAPIController implements Geocoder {

  static String _apiKey = 'qOeyhjddKf_KQt3iImd4QaVhu9QBGFFeh2YKR9Q0B5w';

  @override
  geocode(Address address) async {
    final url = Uri.parse(
          'https://geocode.search.hereapi.com/v1/geocode?q=${Uri.encodeComponent(address.formattedAddress)}&apiKey=$_apiKey&in=countryCode:BRA');
    
    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes))['items'][0];
    address.latitude = data['position']['lat']; 
    address.longitude = data['position']['lng']; 
  
  }

  @override
  Future<Address> inverseGeocode(double latitude,double longitude) async {
    final url = Uri.parse(
          'https://revgeocode.search.hereapi.com/v1/revgeocode?at=$latitude,$longitude&apiKey=$_apiKey');

      final response = await http.get(url);
      final data = json.decode(utf8.decode(response.bodyBytes))['items'][0]['address'];

      Address address = Address(latitude: latitude,longitude: longitude);

      address.zipCode = data['postalCode'];
      address.street = data['street'];
      address.number = data['houseNumber'];
      address.city = data['city'];
      address.state = data['stateCode'];
      address.country = data['countryCode'];
        
      
    return address;
  }


}