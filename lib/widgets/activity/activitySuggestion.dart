import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/photoWithRate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivitySuggestion extends StatelessWidget {
  final Activity activity;
  const ActivitySuggestion({super.key, required this.activity});

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
      ],
    );
  }
}
