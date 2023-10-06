import 'package:flutter/material.dart';
import 'package:moodlight/UI/dialogs/connection_dialog.dart';
import 'package:provider/provider.dart';
import 'UI/screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LightingProvider()),
            ChangeNotifierProvider(create: (_) => ConnectionProvider()),
          ],
          child: Navigator(
            initialRoute: 'main',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case 'connector':
                  return MaterialPageRoute(
                      builder: (context) => BLEConnectionDialog());
                default:
                  return MaterialPageRoute(
                      builder: (context) => const MainScreen());
              }
            },
          ),
        ));
  }
}
