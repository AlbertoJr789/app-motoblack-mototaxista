import 'dart:async';

import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  late ActivityController _controller;
  final List<Marker> _markers = [];

  @override
  initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _listenTrip();
  }

  _listenTrip() {
    FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId('passenger'),
          position: LatLng(
              data['passenger']['latitude'],
              data['passenger']['longitude']),
        ));
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(_controller.currentActivity!.origin.latitude!,
                  _controller.currentActivity!.origin.longitude!),
              zoom: 16),
          markers: Set<Marker>.of(_markers),
        ),
        Positioned(
            bottom: 10,
            right: MediaQuery.of(context).size.width * 0.33,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _endRideDialog,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                label: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red), // Set the background color of the icon
                ),
              ),
            )),
      ],
    );
  }

  void _endRideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza que deseja cancelar a corrida ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }
}
