import 'package:flutter/material.dart';
import 'package:moodlight/UI/screens/screens.dart';
import 'package:provider/provider.dart';

class LightingScreen extends StatelessWidget {
  const LightingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              Provider.of<ConnectionProvider>(context, listen: false)
                  .send_light_setting();
            },
            child: Text("Lights")),
      ],
    );
  }
}
