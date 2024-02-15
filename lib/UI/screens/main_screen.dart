import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Moodlight/UI/dialogs/dialogs.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:Moodlight/resources/resources.dart';
import 'screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// The view for the main screen, using ConnectionProvider
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        navigatorKey.currentState!.maybePop();
        return Future.value(false);
      },
      child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Moodlight'),
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(10.0),
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(SettingsScreen.routeName);
                        },
                      )
                    ],
                  ),
                ),
                // Tile for dark mode
                ListTile(
                  title: const Text('Dark Mode'),
                  trailing: Consumer<PreferencesProvider>(
                      builder: (context, preferencesProvider, child) {
                    return Switch(
                        value: preferencesProvider.isDarkMode(),
                        onChanged: (value) {
                          preferencesProvider.setDarkMode(value);
                        });
                  }),
                ),
                ListTile(
                  title: const Text('Manual Connection'),
                  onTap: () {
                    final ConnectionProvider connectionProvider =
                        Provider.of<ConnectionProvider>(context, listen: false);
                    connectionProvider.scan();
                    Navigator.of(context)
                        .pushNamed(BLEConnectionDialog.routeName);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
              title: Consumer<ConnectionProvider>(
                  builder: (context, connectionProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        connectionProvider.connectedDevice?.platformName ?? ''),
                    Text(connectionProvider.connectedDevice?.remoteId.str ?? '',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                );
              }),
              actions: [
                Builder(
                    builder: ((con) => Consumer<ConnectionProvider>(
                          builder: (con, connectionProvider, child) =>
                              Container(
                            margin: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    connectionProvider.isConnected()
                                        ? Colors.redAccent
                                        : Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (connectionProvider.isConnected()) {
                                  connectionProvider.disconnect();
                                  return;
                                } else {
                                  if (!Database()
                                          .automaticallyConnectToFirstSonatable() &&
                                      Database()
                                          .defaultConnectionMACAddress()
                                          .isEmpty) {
                                    // Open manual connection dialog
                                    connectionProvider.scan();
                                    Navigator.of(context).pushNamed(
                                        BLEConnectionDialog.routeName);
                                  } else {
                                    connectionProvider.connect((msg) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.greenAccent,
                                        duration: const Duration(seconds: 1),
                                      ));
                                    }, (msg) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 1),
                                      ));
                                    });
                                  }
                                }
                              },
                              child: connectionProvider.isScanning
                                  ? const Center(
                                      child: SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ))
                                  : Text(
                                      connectionProvider.isConnected()
                                          ? 'Disconnect'
                                          : 'Connect',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                            ),
                          ),
                        )))
              ],
              flexibleSpace: const Icon(
                Icons.bluetooth_connected,
                color: Colors.white,
                size: 40.0,
              )),
          bottomNavigationBar: Consumer<ConnectionProvider>(
              builder: (context, connectionProvider, child) {
            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: 'Soundboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.control_camera_sharp),
                  label: 'Controls',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.light_mode),
                  label: 'Lighting',
                ),
              ],
              currentIndex: _index,
              selectedItemColor: Theme.of(context).primaryColor,
              onTap: (index) {
                setState(() {
                  _index = index;
                });
                if (index == 0) {
                  navigatorKey.currentState!.pushReplacementNamed('soundboard');
                } else if (index == 1) {
                  navigatorKey.currentState!.pushReplacementNamed('controls');
                } else {
                  navigatorKey.currentState!.pushReplacementNamed('lighting');
                }
              },
            );
          }),
          body: Navigator(
              initialRoute: 'controls',
              key: navigatorKey,
              onGenerateRoute: ((settings) {
                late Widget screen;
                switch (settings.name) {
                  case 'soundboard':
                    screen = const SoundBoardScreen();
                    break;
                  case 'soundboardCategory':
                    screen = SoundBoardCategoryScreen(
                        category: settings.arguments as String);
                    break;
                  case 'controls':
                    screen = const ControlsScreen();
                    break;
                  case 'lighting':
                    screen = const LightingScreen();
                    break;
                  default:
                    screen = const SoundBoardScreen();
                }
                return PageRouteBuilder(
                  pageBuilder: (context, an1, an2) => screen,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  // transitionDuration: Duration.zero,
                  // reverseTransitionDuration: Duration.zero
                );
              }))),
    );
  }
}
