import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecretScreen extends StatefulWidget {
  const SecretScreen({Key? key}) : super(key: key);

  @override
  _SecretScreenState createState() => _SecretScreenState();
}

class _SecretScreenState extends State<SecretScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Auth Tutorial"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Inscreva-se no canal Caio Chaves Dev!", style: TextStyle(fontSize: 18.0)),
            const SizedBox(height: 15.0),
            MaterialButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Copiar link para inscrever-se"),
                  SizedBox(width: 7.5),
                  Icon(Icons.copy),
                ],
              ),
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'https://www.youtube.com/channel/UCQj0fBYyUljEkP_bUpnqKLw'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Link copiado com sucesso!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ));
              },
            )
          ],
        ),
      ),
    );
  }
}
