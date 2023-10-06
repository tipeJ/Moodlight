import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:moodlight/UI/screens/screens.dart';
import 'package:provider/provider.dart';

class BLEConnectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select a device to connect to:',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: Consumer<ConnectionProvider>(
              builder: (_, prov, __) => ListView.builder(
                shrinkWrap: true,
                itemCount: prov.devicesList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(prov.devicesList[index].platformName),
                    selected: prov.devicesList[index].platformName
                        .toLowerCase()
                        .contains("sonatable"),
                    subtitle: Text(prov.devicesList[index].remoteId.toString()),
                    trailing: ElevatedButton(
                      onPressed: () {
                        prov.connectToDevice(prov.devicesList[index]);
                        Navigator.of(context).pop();
                      },
                      child: Text('Connect'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
