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

class ActivitySuggestion extends StatefulWidget {
  final Activity activity;
  final Position currentLocation;

  const ActivitySuggestion({super.key, required this.activity, required this.currentLocation});

  @override
  State<ActivitySuggestion> createState() => _ActivitySuggestionState();
}

class _ActivitySuggestionState extends State<ActivitySuggestion> {
  bool _loadingPassengerLocation = false;

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
              PhotoWithRate(avatar: widget.activity.passenger!.avatar, rate: widget.activity.passenger!.rate),
              Text(
                widget.activity.passenger!.name,
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
                widget.activity.origin.formattedAddress,
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
                widget.activity.destiny.formattedAddress,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Text('Distância aproximada: ${widget.activity.distance}',textAlign: TextAlign.left,style: Theme.of(context).textTheme.bodyMedium,)),
            const SizedBox(width: 3),
            IconButton(
              onPressed: () async {
                final url = 'https://www.google.com/maps/dir/${widget.activity.origin.googleMapsFormattedAddress}/${widget.activity.destiny.googleMapsFormattedAddress}';
                launchUrl(Uri.parse(url));
              },
              tooltip: 'Ver rota no mapa',
              icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4)
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
            ),
          ],
        ),

        const Divider(color: Color.fromRGBO(0, 0, 0, 0.205)),

        Row(
          children: [
            Expanded(
              child: Text(
                "Você se encontra a ${Agent.distanceBetween(widget.currentLocation, widget.activity.origin)} do passageiro",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              onPressed: () async {
                setState(() {
                  _loadingPassengerLocation = true;
                });
                Address currentLocationAddress = await GeoCoderController().inverseGeocode(widget.currentLocation.latitude, widget.currentLocation.longitude);
                launchUrl(Uri.parse('https://www.google.com/maps/dir/${currentLocationAddress.googleMapsFormattedAddress}/${widget.activity.origin.googleMapsFormattedAddress}'));
                setState(() {
                  _loadingPassengerLocation = false;
                });
              },
              tooltip: 'Ver passageiro no mapa',
              icon: _loadingPassengerLocation 
                ? const CircularProgressIndicator() 
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4)
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
            ),
          ],
        ),


      ],
    );
  }
}
