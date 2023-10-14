import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:provider/provider.dart';
import 'screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// The view for the main screen, using ConnectionProvider
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

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
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Moodlight'),
                ),
                ListTile(
                  title: const Text('Manual Connection'),
                  onTap: () {
                    final ConnectionProvider connectionProvider =
                        Provider.of<ConnectionProvider>(context, listen: false);
                    connectionProvider.scan();
                    Navigator.of(context).pushNamed('connector');
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
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                disabledForegroundColor: Colors.grey,
                                side: BorderSide(
                                    color: connectionProvider.isConnected()
                                        ? Colors.redAccent
                                        : Colors.white,
                                    width: 1.5),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                if (connectionProvider.isConnected()) {
                                  connectionProvider.disconnect();
                                  return;
                                } else {
                                  connectionProvider.quickConnect();
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
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color:
                                              connectionProvider.isConnected()
                                                  ? Colors.redAccent
                                                  : Colors.white)),
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
              selectedItemColor: Colors.amber[800],
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
              initialRoute: 'soundboard',
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
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero);
              }))),
    );
  }
}
