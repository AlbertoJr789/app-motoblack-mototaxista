import 'dart:io';

import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditVehicle extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicle({super.key, required this.onUpdated, required this.vehicle});
  final Function() onUpdated;

  @override
  State<EditVehicle> createState() => _EditVehicleState();

}

class _EditVehicleState extends State<EditVehicle> {
  bool _isSaving = false;


  final TextEditingController _documentText = TextEditingController();
  late File _document;

  final _controller = VehicleController();

  final _formKey = GlobalKey<FormState>();

  _saveVehicle(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      Map<String, dynamic> ret = await _controller.updateVehicle(widget.vehicle.id,_document);

      if (ret['error'] == false) {
        toastSuccess(context, 'Veículo atualizado com sucesso.');
        widget.onUpdated();
      } else {
        toastError(context, ret['status'] == 422
                    ? ret['error']
                    : 'Erro ao atualizar veículo, tente novamente mais tarde.');
      }

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        'Atualizar Veículo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Reenvie os documentos do veículo caso necessário. Caso o veículo esteja em análise, aguarde a aprovação.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'Documento: ',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  TextFormField(
                                    readOnly: true,
                                    controller: _documentText,
                                    onTap: () async {
                                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
                                      if (result != null) {
                                        _document = File(result.files.single.path!);
                                        _documentText.text = result.files.single.name;
                                      } 
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Insira um documento';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                // width: double.infinity,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton.icon(
                                    onPressed: !_isSaving
                                        ? () {
                                            _saveVehicle(context);
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.save,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    label: !_isSaving
                                        ? Text(
                                            'Atualizar',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context).colorScheme.secondary),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),
        );
  }
}
