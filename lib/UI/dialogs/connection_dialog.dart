import 'package:flutter/material.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';

class BLEConnectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar with back button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text('Connect to a device'),
      ),
      body: Column(
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
