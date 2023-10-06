import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodlight/resources/resources.dart';
import 'package:provider/provider.dart';
import 'screens.dart';
import '../dialogs/dialogs.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Handles connection with bluetooth to the device and the optional speakers
class ConnectionProvider extends ChangeNotifier {
  final List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothService? modeService;
  BluetoothCharacteristic? modeChar;
  BluetoothService? lightService;
  BluetoothCharacteristic? lightChar;

  int mode_value = -1;
  StreamSubscription<List<int>>? modeStreamSubscription;
  StreamSubscription<void>? modeReaderStreamSubscription;

  Future<void> enable_bluetooth() async {
    // check adapter availability
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isAvailable == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  void scan() async {
    await enable_bluetooth();
    devicesList.clear();
    var subscription =
        FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          devicesList.add(result.device);
          notifyListeners();
        }
      }
    }, onError: (e) => print(e));
    print("Scan started");
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15), androidUsesFineLocation: false);
    print("Scan stopped");
    // await FlutterBluePlus.stopScan();
  }

  @override
  void dispose() {
    super.dispose();
    FlutterBluePlus.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      print("Connecting to device: " + device.platformName);
      await device.connect();
      connectedDevice = device;
      int mtuFirst = await device.mtu.first;
      print("Initial MTU: " + mtuFirst.toString());
      int requestedMtu = await connectedDevice!.requestMtu(256);
      print("Requested MTU: " + requestedMtu.toString());
      // Listen to connectionstate changes, and if disconnected, set connectedDevice to null and cancel subscriptions
      device.connectionState.listen((event) {
        if (event == BluetoothConnectionState.disconnected) {
          connectedDevice = null;
          modeChar = null;
          modeService = null;
          modeStreamSubscription?.cancel();
          modeStreamSubscription = null;
          modeReaderStreamSubscription?.cancel();
          modeReaderStreamSubscription = null;
          lightChar = null;
          lightService = null;
          notifyListeners();
        }
      });

      notifyListeners();
      // Search for the services of the device
      List<BluetoothService> services =
          await connectedDevice!.discoverServices(timeout: 3);
      // Take the mode service
      modeService = services.firstWhere(
          (element) => element.uuid == Guid(MODE_SERVICE_UUID),
          orElse: () => throw Exception('Mode service not found'));
      // Take the mode characteristic
      modeChar = modeService!.characteristics.firstWhere(
          (element) => element.uuid == Guid(MODE_CHAR_UUID),
          orElse: () => throw Exception('Mode characteristic not found'));
      await modeChar!.read();
      modeReaderStreamSubscription =
          modeStream(modeChar).listen((event) {}, onDone: () => print("DONE"));
      modeStreamSubscription = modeChar!.lastValueStream.listen((event) {
        if (event.isEmpty) {
          return;
        }
        mode_value = event[0];
      }, onDone: () => print("DONE"));

      // Take the light service
      lightService = services.firstWhere(
          (element) => element.uuid == Guid(LIGHT_SERVICE_UUID),
          orElse: () => throw Exception('Light service not found'));
      // Take the light characteristic
      lightChar = lightService!.characteristics.firstWhere(
          (element) => element.uuid == Guid(LIGHT_SERVICE_SETTING_CHAR_UUID),
          orElse: () => throw Exception('Light characteristic not found'));
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // Stream that calls the modeChar.read() method every second
  static Stream<void> modeStream(BluetoothCharacteristic? modeChar) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      // If the mode characteristic is not null, read the value
      if (modeChar != null) {
        try {
          await modeChar.read();
        } catch (e) {
          print(e);
        }
      }
    }
  }

  void toggle_mode_value() async {
    if (mode_value == MODE_UNKNOWN || mode_value == MODE_LIGHTS) {
      mode_value = MODE_SOUNDBOARD;
    } else {
      mode_value = MODE_LIGHTS;
    }
    if (modeChar != null) {
      print("WRITING MODE VALUE: " + mode_value.toString());
      try {
        await modeChar!.write([mode_value]);
      } catch (e) {
        print(e);
      }
    }
  }

  int changer = 0;

  void send_light_setting() async {
    // Sends sample JSON setting to the device
    if (lightChar != null) {
      try {
        await lightChar!.write(utf8.encode(
            '{"mode": "solid", "color": [$changer, 0, 0, 0], "brightness": 100}'));
        changer = (changer + 1) % 255;
      } catch (e) {
        print(e);
      }
    }
  }
}

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
    return Scaffold(
        appBar: AppBar(
            title: Consumer<ConnectionProvider>(
                builder: (context, connectionProvider, child) {
              return Text(
                  connectionProvider.connectedDevice?.platformName ?? '');
            }),
            actions: [
              Builder(
                  builder: ((con) => IconButton(
                        icon: const Icon(Icons.bluetooth_connected),
                        onPressed: () {
                          final provider = Provider.of<ConnectionProvider>(con,
                              listen: false);
                          provider.scan();
                          Navigator.of(context).pushNamed('connector');
                        },
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
            })));
  }
}
