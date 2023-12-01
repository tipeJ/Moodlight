import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:moodlight/models/light_configs.dart';
import 'package:moodlight/resources/resources.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Handles connection with bluetooth to the device and the optional speakers
typedef void buttonCallback(int mode_value);

// Button click callback for given index
void handle_button_1_click(int mode_value) async {
  if (mode_value == MODE_SOUNDBOARD) {
    // Play the sound
    print("PLAYING SOUND 1");
    final player = AudioPlayer(playerId: "ASD");
    String soundFile = "hohhoijaa.mp3";
    await player.play(AssetSource('sounds/$soundFile'), volume: 1.0);
  }
}

// Constant empty callback
void emptyCallback(int mode_value) {
  print("button pressed");
}

class ConnectionProvider extends ChangeNotifier {
  bool isScanning = false;
  final List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothService? modeService;
  BluetoothCharacteristic? modeChar;
  BluetoothService? lightService;
  BluetoothCharacteristic? lightChar;
  BluetoothService? buttonsService;
  List<BluetoothCharacteristic> buttonsCharacteristics = [];
  List<StreamSubscription<List<int>>> buttonSubscriptions = [];
  BluetoothService? controlsService;
  BluetoothCharacteristic? powerButtonChar;
  BluetoothCharacteristic? brightnessChangeChar;

  // List of click callbacks for the buttons
  List<buttonCallback> buttonClickCallbacks = [
    handle_button_1_click,
    emptyCallback,
    emptyCallback,
    emptyCallback,
    emptyCallback,
    emptyCallback,
    emptyCallback
  ];

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

  // Default connect function. Handles other connect functions with onSuccess and onFailure function callbacks
  void connect(
      Function(String msg) onSuccess, Function(String msg) onFailure) async {
    // If automatic Sonatable discovery has been set, quickConnect to the first one
    final bool automaticallyConnectToFirstSonatable =
        Database().automaticallyConnectToFirstSonatable();

    if (automaticallyConnectToFirstSonatable) {
      quickConnect(onSuccess, onFailure);
      return;
    }
    // If default device MAC is set, connect to that
    final String defaultConnectionMACAddress =
        Database().defaultConnectionMACAddress();
    if (defaultConnectionMACAddress.isNotEmpty) {
      connectToDefaultDevice(onSuccess, onFailure);
      return;
    }
  }

  void connectToDefaultDevice(
      Function(String msg) onSuccess, Function(String msg) onFailure) async {
    // If the user has set a default connection MAC address, connect to that
    final String defaultConnectionMACAddress =
        Database().defaultConnectionMACAddress();
    assert(connectedDevice == null && defaultConnectionMACAddress.isNotEmpty);
    final scanningStream = FlutterBluePlus.isScanning.listen((event) {
      isScanning = event;
      notifyListeners();
    });
    final stream = FlutterBluePlus.scanResults.asBroadcastStream();
    stream.listen((event) {
      for (ScanResult result in event) {
        if (result.device.remoteId.str == defaultConnectionMACAddress) {
          FlutterBluePlus.stopScan();
          isScanning = false;
          scanningStream.cancel();
          connectToDevice(result.device);
          return;
        }
      }
    });
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 3), androidUsesFineLocation: false);
    await stream.first.onError(
        (error, stackTrace) => onFailure("Timeout, couldn't find device"));
  }

  // Scan and connect to the first device that matches the name
  void quickConnect(
      Function(String msg) onSuccess, Function(String msg) onFailure) async {
    final scanningStream = FlutterBluePlus.isScanning.listen((event) {
      isScanning = event;
      notifyListeners();
    });
    final stream = FlutterBluePlus.scanResults.asBroadcastStream();
    stream.listen((event) {
      for (ScanResult result in event) {
        if (result.device.platformName == "Sonatable") {
          FlutterBluePlus.stopScan();
          scanningStream.cancel();
          isScanning = false;
          connectToDevice(result.device);
          return;
        }
      }
    });
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 3),
      androidUsesFineLocation: false,
    );
    await stream.first.onError((error, stackTrace) => onFailure("Timeout"));
  }

  @override
  void dispose() {
    super.dispose();
    FlutterBluePlus.stopScan();
  }

  BluetoothCharacteristic _getCharacteristic(
      BluetoothService service, String uuid) {
    return service.characteristics.firstWhere(
        (element) => element.uuid == Guid(uuid),
        orElse: () => throw Exception('Characteristic $uuid not found'));
  }

  BluetoothService _getService(List<BluetoothService> services, String uuid) {
    return services.firstWhere((element) => element.uuid == Guid(uuid),
        orElse: () => throw Exception('Service $uuid not found'));
  }

  Future<void> connectToDevice(BluetoothDevice device,
      {Function(String)? onSuccess}) async {
    try {
      print("Connecting to device: " + device.platformName);
      await device.connect();
      connectedDevice = device;
      int requestedMtu = await connectedDevice!.requestMtu(512);
      print("Requested MTU: " + requestedMtu.toString());
      // Listen to connectionstate changes, and if disconnected, set connectedDevice to null and cancel subscriptions
      device.connectionState.listen((event) {
        if (event == BluetoothConnectionState.disconnected) {
          print("Disconnected from device");
          connectedDevice = null;
          modeChar = null;
          modeService = null;
          modeStreamSubscription?.cancel();
          modeStreamSubscription = null;
          modeReaderStreamSubscription?.cancel();
          modeReaderStreamSubscription = null;
          lightChar = null;
          lightService = null;
          buttonsCharacteristics.clear();
          notifyListeners();
        }
      });

      notifyListeners();
      // Search for the services of the device
      List<BluetoothService> services =
          await connectedDevice!.discoverServices(timeout: 3);

      // ! Controls
      controlsService = _getService(services, CONTROLS_SERVICE_UUID);
      powerButtonChar =
          _getCharacteristic(controlsService!, CONTROLS_POWERBUTTON_UUID);
      brightnessChangeChar =
          _getCharacteristic(controlsService!, CONTROLS_BRIGHT_CHANGE_UUID);

      modeChar = _getCharacteristic(controlsService!, CONTROLS_MODE_CHAR_UUID);
      await modeChar!.read();
      // modeReaderStreamSubscription =
      //     modeStream(modeChar).listen((event) {}, onDone: () => print("DONE"));
      modeStreamSubscription = modeChar!.lastValueStream.listen((event) {
        if (event.isEmpty) {
          return;
        }
        mode_value = event[0];
      }, onDone: () => print("DONE"));

      // ! NeoLight
      lightService = _getService(services, LIGHT_SERVICE_UUID);
      // Take the light characteristic
      lightChar =
          _getCharacteristic(lightService!, LIGHT_SERVICE_SETTING_CHAR_UUID);

      buttonsService = _getService(services, BUTTONS_SERVICE_UUID);
      // for (final char in BUTTON_CHAR_UUIDs) {
      final buttonChar =
          _getCharacteristic(buttonsService!, BUTTON_1_CHAR_UUID);
      await buttonChar.setNotifyValue(true);
      buttonsCharacteristics.add(buttonChar);
      buttonChar.onValueReceived.listen((event) {
        print("Button pressed");
        buttonClickCallbacks[0](mode_value);
      });

      notifyListeners();

      // Send callback if set
      if (onSuccess != null) {
        onSuccess(connectedDevice!.remoteId.str);
      }
    } catch (e) {
      print("Error connecting to device: $e");
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

  bool isConnected() => connectedDevice != null;

  void disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      notifyListeners();
    }
  }

  void toggle_mode_value() async {
    if (mode_value == MODE_UNKNOWN || mode_value == MODE_LIGHTS) {
      mode_value = MODE_SOUNDBOARD;
    } else {
      mode_value = MODE_LIGHTS;
    }
    if (modeChar != null) {
      try {
        await modeChar!.write([mode_value]);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  void sendLightConfig(LightConfiguration config) async {
    // Sends sample JSON setting to the device
    print("Sending config: " + config.toJson());
    if (lightChar != null) {
      try {
        await lightChar!.write(utf8.encode(config.toJson()));
      } catch (e) {
        print(e);
      }
    }
  }

  void sendPowerButton() async {
    if (powerButtonChar != null) {
      try {
        print("Sending power button");
        await powerButtonChar!.write([1]);
      } catch (e) {
        print(e);
      }
    }
  }

  void setBrightnessValue(String change) async {
    if (brightnessChangeChar != null) {
      try {
        print("Sending brightness change: " + change);
        await brightnessChangeChar!.write(utf8.encode(change));
      } catch (e) {
        print(e);
      }
    }
  }
}
