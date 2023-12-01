import 'package:flutter/material.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Container(
          child: SafeArea(
            child:
                Consumer<PreferencesProvider>(builder: (context, prov, child) {
              return ListView(
                children: [
                  // Dark mode switch
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    value: prov.isDarkMode(),
                    onChanged: (value) {
                      if (value) {
                        prov.setDarkMode(true);
                      } else {
                        prov.setDarkMode(false);
                      }
                    },
                  ),
                  // Automatic connection to first found Sonatable
                  SwitchListTile(
                    title:
                        const Text('Automatically connect to first Sonatable'),
                    value: prov.automaticallyConnectToFirstSonatable(),
                    onChanged: (value) {
                      if (value) {
                        prov.setAutomaticallyConnectToFirstSonatable(true);
                      } else {
                        prov.setAutomaticallyConnectToFirstSonatable(false);
                      }
                    },
                  ),
                  // Default connection MAC address
                  ListTile(
                    // Only enabled if above option (automatic connection to Sonatable) is disabled
                    enabled: !prov.automaticallyConnectToFirstSonatable(),
                    title: const Text('Default connection MAC address'),
                    subtitle: Text(prov.defaultConnectionMACAddress().isEmpty
                        ? 'Not set'
                        : prov.defaultConnectionMACAddress()),
                    onTap: () async {
                      // Open dialog to change or remove the default connection MAC address
                      final String? result = await showDialog(
                          context: context,
                          builder: (context) => _ChangeDefaultConnectionDialog(
                              initialAddress:
                                  prov.defaultConnectionMACAddress()));
                      if (result != null) {
                        prov.setDefaultConnectionMACAddress(result);
                      }
                    },
                  ),
                ],
              );
            }),
          ),
        ));
  }
}

class _ChangeDefaultConnectionDialog extends StatefulWidget {
  final String initialAddress;
  const _ChangeDefaultConnectionDialog({required this.initialAddress, Key? key})
      : super(key: key);

  @override
  State<_ChangeDefaultConnectionDialog> createState() =>
      _ChangeDefaultConnectionDialogState();
}

class _ChangeDefaultConnectionDialogState
    extends State<_ChangeDefaultConnectionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = widget.initialAddress;
    return AlertDialog(
      title: const Text('Change default connection MAC address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Horizontal separator
          const Divider(),
          // Explainer text
          const Text(
              'The default connection MAC address is used when connecting to the Sonatable via the front page "connect" button. '
              'If this is not set, the app will ask whether or not the connection should be saved the next time a connection is '
              'successfully established. You may also manually remove/insert the MAC address in the field below'),
          // Horizontal separator
          const Divider(),
          TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: '00:00:00:00:00:00')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop('');
            },
            child: const Text('Remove')),
        TextButton(
            onPressed: () {
              // No change, return null
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
            child: const Text('Save'))
      ],
    );
  }
}
