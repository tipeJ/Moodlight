import 'package:flutter/material.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:Moodlight/resources/resources.dart';

class BLEConnectionDialog extends StatelessWidget {
  static const String routeName = 'connection_dialog';
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
                      onPressed: () async {
                        await prov.connectToDevice(
                          prov.devicesList[index],
                          onSuccess: (newAddress) async {
                            if (Database().defaultConnectionMACAddress() !=
                                newAddress) {
                              // Open dialog to ask if the user wants to set this as the default connection MAC address
                              final result = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                      'Set as default connection MAC address?'),
                                  content: Text(
                                      'Do you want to set ${prov.devicesList[index].platformName} as the default connection MAC address?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (result == true) {
                                Database()
                                    .setDefaultConnectionMACAddress(newAddress);
                              }
                            }
                          },
                        );
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
