import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/screens/activityDetails.dart';
import 'package:app_motoblack_mototaxista/widgets/textBadge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
   
    return Card(
      shadowColor: const Color.fromARGB(255, 197, 179, 88),
      color: const Color.fromARGB(243, 221, 221, 219),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
          RadioListTile<int>(
              title: TextBadge(msg: Text('${vehicle.typeName} ${vehicle.brand} - ${vehicle.model} ${vehicle.currentActiveVehicle ? '(Veículo Atual)' : ''}',style: Theme.of(context).textTheme.bodyMedium,)),
              subtitle: Text(vehicle.plate,style: Theme.of(context).textTheme.bodySmall,), 
              value: vehicle.id,
              groupValue: vehicle.currentActiveVehicle ? vehicle.id : null,
              onChanged: (value) {

            
                print('quero ativar o veiculo ${value}');
              },
            ),
      ),
    );
  }
}
