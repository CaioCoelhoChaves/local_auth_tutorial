import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_tutorial/secret_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late bool deviceSupported;

  @override
  void initState() {
    super.initState();
    _localAuth.isDeviceSupported().then((value) => deviceSupported = value);
  }

  AndroidAuthMessages _androidAuthMessages (){
    return const AndroidAuthMessages(
      signInTitle: "Autenticação necessária",
      biometricHint: "Verifique sua indentidade",
      cancelButton: "Cancelar"
    );
  }

  Future<List<BiometricType>> _initBiometrics() async {
    List<BiometricType> _availableBiometrics = <BiometricType>[];
    if (deviceSupported) {
      try {
        if (await _localAuth.canCheckBiometrics) {
          _availableBiometrics = await _localAuth.getAvailableBiometrics();
        }
        return _availableBiometrics;
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> _auth() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        androidAuthStrings: _androidAuthMessages(),
        localizedReason: 'Desbloqueie para acessar a tela secreta!',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if(authenticated){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretScreen()));
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _authOnlyBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        androidAuthStrings: _androidAuthMessages(),
        localizedReason: 'Desbloqueie para acessar a tela secreta!',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true,
      );
      if (authenticated) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretScreen()));
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Auth Tutorial"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: FutureBuilder<List<BiometricType>>(
          future: _initBiometrics(),
          builder: (BuildContext context, AsyncSnapshot<List<BiometricType>> snapshot) {
            if (snapshot.hasData) {
              if (!deviceSupported) {
                return const Center(child: Text("Dispositivo não suportado", style: TextStyle(fontSize: 18.0)));
              } else if (snapshot.data == null || snapshot.data == []) {
                return const Center(
                    child: Text("Não é possível verificar nenhum tipo de biometria no dispositivo!", style: TextStyle(fontSize: 18.0)));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30.0),
                  MaterialButton(
                    height: 40.0,
                    child: const Text("Acessar tela secreta (biometria + pin)", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    color: Colors.teal,
                    onPressed: _auth,
                  ),
                  const SizedBox(height: 10.0),
                  Visibility(
                    visible: snapshot.data!.isNotEmpty,
                    child: MaterialButton(
                      height: 40.0,
                      child: const Text("Acessar tela secreta (apenas biometria)", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      color: Colors.teal,
                      onPressed: _authOnlyBiometrics,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Text("Biometrias disponiveis: "),
                      Visibility(
                        visible: snapshot.data!.isEmpty,
                        child: const Text("nenhuma"),
                      ),
                      for (int i = 0; i < snapshot.data!.length; i++) ...[
                        Text(snapshot.data![i].name),
                        if (i + 1 < snapshot.data!.length) ...[
                          const Text(","),
                        ] else ...[
                          const Text("."),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 30.0),
                ],
              );
            } else {
              return const Center(
                child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
