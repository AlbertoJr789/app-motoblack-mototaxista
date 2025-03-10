import 'package:app_motoblack_mototaxista/controllers/geoCoderController.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/models/Address.dart';
import 'package:app_motoblack_mototaxista/models/Agent.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/photoWithRate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivitySuggestion extends StatelessWidget {
  final Activity activity;
  final Position currentLocation;
  const ActivitySuggestion({super.key, required this.activity, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Há um passageiro precisando de corrida!',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Divider(color: Color.fromRGBO(0, 0, 0, 0.205)),
        Center(
          child: Column(
            children: [
              PhotoWithRate(avatar: activity.passenger!.avatar, rate: activity.passenger!.rate),
              Text(
                activity.passenger!.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Origem: ',textAlign: TextAlign.left,style: Theme.of(context).textTheme.bodyLarge,),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.flag, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                activity.origin.formattedAddress,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Destino: ',textAlign: TextAlign.left,style: Theme.of(context).textTheme.bodyLarge,),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.flag_circle, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                activity.destiny.formattedAddress,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Text('Distância aproximada: ${activity.distance}',textAlign: TextAlign.left,style: Theme.of(context).textTheme.bodyMedium,),

        const Divider(color: Color.fromRGBO(0, 0, 0, 0.205)),

        Row(
          children: [
            Expanded(
              child: Text(
                "Você se encontra a ${Agent.distanceBetween(currentLocation, activity.origin)} do passageiro",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            GestureDetector(
              onTap: () async {
                  Address currentLocationAddress = await GeoCoderController().inverseGeocode(currentLocation.latitude, currentLocation.longitude);
                  launchUrl(Uri.parse('https://www.google.com/maps/dir/${currentLocationAddress.formattedAddress}/${activity.origin.formattedAddress}'));
              },
              child: Text(
                "Ver no mapa",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),


      ],
    );
  }
}
