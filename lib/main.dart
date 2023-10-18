import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moodlight/UI/dialogs/connection_dialog.dart';
import 'package:moodlight/UI/providers/providers.dart';
import 'package:moodlight/resources/resources.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'UI/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Database().init();
  runApp(const MoodlightApplication());
}

class MoodlightApplication extends StatelessWidget {
  const MoodlightApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LightingProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider())
      ],
      child: const MyApp(),
    );
  }
}

final GlobalKey<NavigatorState> mainNavigator = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, preferencesProvider, child) {
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
              useMaterial3: true,
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            themeMode: preferencesProvider.isDarkMode()
                ? ThemeMode.dark
                : ThemeMode.light,
            home: WillPopScope(
              onWillPop: () {
                mainNavigator.currentState!.maybePop();
                return Future.value(false);
              },
              child: Navigator(
                key: mainNavigator,
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
      },
    );
  }
}
