import 'package:flutter/material.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final _key = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              const Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/pics/perfil_padrao.png'),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Nome',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 216, 216, 216)),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Telefone',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 216, 216, 216)),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'E-mail',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 216, 216, 216)),
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 4,
              ),
              TextFormField(),
              const SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                child: const Text(
                  'Dados do Veículo',
                  style: TextStyle(
                      fontSize: 28, color: Color.fromARGB(255, 216, 216, 216)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                'Modelo',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 216, 216, 216)),
                textAlign: TextAlign.start,
              ),
              TextFormField(),
              const SizedBox(
                height: 4,
              ),
              const Text(
                'Placa',
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 216, 216, 216)),
                textAlign: TextAlign.start,
              ),
              TextFormField(),
              const SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  // width: double.infinity,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Enviar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        
      ),
    );
  }
}
