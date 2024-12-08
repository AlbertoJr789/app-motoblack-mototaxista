import 'dart:async';

import 'package:app_motoblack_mototaxista/widgets/toggleOnline.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Home> {
  @override
  bool get wantKeepAlive => true;

  bool _activityMode = false;
  bool _foundPassenger = false;

  late Timer _timer;
  late String _time;
  final Stopwatch _stopwatch = Stopwatch();

  // @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (_stopwatch.elapsed.inHours > 0) {
    //     setState(() {
    //       _time =
    //           '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    //     });
    //   } else {
    //     setState(() {
    //       _time =
    //           '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    //     });
    //   }
    // });
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
              setState(() {
                _stopwatch.reset();
                _stopwatch.stop();
                _foundPassenger = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _activityMode
              ? Stack(
                  children: [
                    const GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: LatLng(-11, -12), zoom: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 24.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.width * 0.20,
                          child: _foundPassenger
                              ? Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 197, 179, 88),
                                        Color.fromARGB(255, 238, 205, 39),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Corrida em Andamento  $_time",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: _endRideDialog,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Cancelar",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty
                                                .all<Color>(Colors
                                                    .red), // Set the background color of the icon
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    _foundPassenger = false;
                                    _activityMode = false;
                                  },
                                  icon: const Icon(
                                    size: 30,
                                    Icons.motorcycle,
                                  ),
                                  label: const Text(
                                    "Encerrar as Atividades",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                )
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
