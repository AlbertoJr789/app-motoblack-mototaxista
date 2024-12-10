import 'package:app_motoblack_mototaxista/models/Activity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivitySuggestion extends StatelessWidget {

  final Activity activity;
  const ActivitySuggestion({super.key,required this.activity});

  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Profile Picture
               ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person_off_outlined,color: Colors.black,),
                    imageUrl: activity.passenger!.avatar!),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.passenger!.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.flag_circle, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                activity.origin.formattedAddress,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_sharp, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                activity.destiny.formattedAddress,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      );
  }
}