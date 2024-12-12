import 'dart:async';

import 'package:app_motoblack_mototaxista/controllers/activityController.dart';
import 'package:app_motoblack_mototaxista/widgets/toggleOnline.dart';
import 'package:app_motoblack_mototaxista/widgets/trip.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Home> {
  @override
  bool get wantKeepAlive => true;

  late ActivityController _tripController;

  @override
  void initState() {
    super.initState();
    _tripController = Provider.of<ActivityController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    _tripController = context.watch<ActivityController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _tripController.currentActivity != null
              ? const Trip()
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Iniciar atividades",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary)),
                    const SizedBox(
                      height: 12,
                    ),
                    const ToggleOnline()
                  ],
                )) //

          ),
    );
  }

}
