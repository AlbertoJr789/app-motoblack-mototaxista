import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/screens/activityDetails.dart';
import 'package:app_motoblack_mototaxista/widgets/textBadge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final Function(int?) onChanged;
  VehicleCard({super.key, required this.vehicle, required this.onChanged});

  @override

  Widget build(BuildContext context) {
   
    return Card(
      shadowColor: const Color.fromARGB(255, 197, 179, 88),
      color: vehicle.inactiveReason == null ? const Color.fromARGB(243, 221, 221, 219) : const Color.fromARGB(125, 255, 252, 252),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
          RadioListTile<int>(
              title: TextBadge(msg: Text('${vehicle.typeName} ${vehicle.brand} - ${vehicle.model}',style: Theme.of(context).textTheme.bodyLarge,),color: vehicle.inactiveReason == null ? null : const Color.fromARGB(96, 197, 179, 88),),
              subtitle: vehicle.inactiveReason != null ? Text('${vehicle.plate} - ${vehicle.inactiveReason!}',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.errorContainer),)
                  : Row(
                children: [
                    Text(vehicle.plate,style: Theme.of(context).textTheme.bodyMedium,),
                    Text(' - Ativo',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.green),),
                ],
              ), 
              value: vehicle.id,
              groupValue: vehicle.currentActiveVehicle ? vehicle.id : null,
              onChanged: onChanged,
            ),
      ),
    );

  }
}
