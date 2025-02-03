import 'dart:io';

import 'package:app_motoblack_mototaxista/controllers/vehicleController.dart';
import 'package:app_motoblack_mototaxista/models/Vehicle.dart';
import 'package:app_motoblack_mototaxista/widgets/assets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  bool _isSaving = false;

  final TextEditingController _brand = TextEditingController();
  final TextEditingController _model = TextEditingController();
  final TextEditingController _plate = TextEditingController();
  final TextEditingController _documentText = TextEditingController();
  Color _color = Colors.black;
  late VehicleType _type;
  late File _document;

  final _controller = VehicleController();

  final _formKey = GlobalKey<FormState>();

  _saveVehicle(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      Map<String, dynamic> ret = await _controller.addVehicle(_brand.text, _model.text, _plate.text, _color, _type, _document);

      if (ret['error'] == false) {
        FToast().init(context).showToast(
            child: MyToast(
              msg: const Text(
                'Veículo adicionado com sucesso.',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              color: Colors.greenAccent,
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 4));
      } else {
        FToast().init(context).showToast(
            child: MyToast(
              msg: Text(
                ret['status'] == 422
                    ? ret['error']
                    : 'Erro ao adicionar veículo, tente novamente mais tarde.',
                style: const TextStyle(
                  color: Colors.white,
                ),

              ),
              icon: const Icon(
                Icons.error,
                color: Colors.white,
              ),
              color: Colors.redAccent,
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 5));
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text('Selecione a Cor do Veículo'),
          content: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: ColorPicker(
              enableAlpha: false,
              hexInputBar: false,
              pickerColor: _color,
              onColorChanged: (color) {
                _color = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Pronto', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        color: Theme.of(context).colorScheme.inversePrimary,
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
                        'Novo Veículo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Seu veículo passará por um processo de aprovação para que seja utilizável.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tipo: ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            canvasColor: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                          ),
                                          child: DropdownButtonFormField(
                                            icon: const Icon(
                                              Icons.arrow_drop_down_outlined,
                                              color: Colors.black,
                                            ),
                                            isExpanded: true,
                                            items: const [
                                              DropdownMenuItem(
                                                  value: VehicleType.motorcycle,
                                                  child: Text('Moto')),
                                              DropdownMenuItem(
                                                  value: VehicleType.car,
                                                  child: Text('Carro'))
                                            ],
                                            onChanged: (value) {
                                              _type = value!;
                                            },
                                            validator: (value) {
                                              if (value == null) {
                                                return 'Informe o tipo';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Marca: ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                          textAlign: TextAlign.start,
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          controller: _brand,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Informe a marca';
                                            }
                                            return null;

                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'Modelo: ',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  TextFormField(
                                    controller: _model,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe o modelo';
                                      }
                                      return null;
                                    },

                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            'Placa: ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          controller: _plate,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Informe a placa';
                                            }
                                            return null;

                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            'Cor: ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        InkWell(
                                            onTap: _selectColor,
                                            child: Container(
                                              color: _color,
                                              width: 50,
                                              height: 50,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                                    label: !_isSaving
                                        ? const Text(
                                            'Salvar',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
