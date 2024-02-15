import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:Moodlight/UI/dialogs/connection_dialog.dart';
import 'package:Moodlight/UI/providers/providers.dart';
import 'package:Moodlight/resources/resources.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'UI/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Database().init();
  final SoundboardMoonsEditProvider soundboardMoonsEditProvider =
      SoundboardMoonsEditProvider();
  await soundboardMoonsEditProvider.loadSounds();
  runApp(MoodlightApplication(
      soundboardMoonsEditProvider: soundboardMoonsEditProvider));
}

class MoodlightApplication extends StatelessWidget {
  final SoundboardMoonsEditProvider soundboardMoonsEditProvider;
  const MoodlightApplication(
      {Key? key, required this.soundboardMoonsEditProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LightingProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => soundboardMoonsEditProvider),
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
              primarySwatch: MOODLIGHT_COLOR_1.materialColor,
              primaryColor: MOODLIGHT_COLOR_1,
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)))),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primarySwatch: MOODLIGHT_COLOR_3.materialColor,
              primaryColor: MOODLIGHT_COLOR_3,
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)))),
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
                    case BLEConnectionDialog.routeName:
                      return MaterialPageRoute(
                          builder: (context) => BLEConnectionDialog());
                    case SoundboardMoonsEditScreen.routeName:
                      return MaterialPageRoute(
                          builder: (context) =>
                              const SoundboardMoonsEditScreen());
                    case SoundboardScreenEditAddScreen.routeName:
                      return MaterialPageRoute<String>(
                          builder: (context) => SoundboardScreenEditAddScreen(
                              soundID: settings.arguments as int));
                    case SettingsScreen.routeName:
                      return MaterialPageRoute(
                          builder: (context) => const SettingsScreen());
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
