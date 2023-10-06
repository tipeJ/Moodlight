class SolidLightConfiguration {
  final int red;
  final int green;
  final int blue;
  final int white;

  SolidLightConfiguration(
      {required this.red,
      required this.green,
      required this.blue,
      required this.white});

  Map<String, dynamic> toJson() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'white': white,
    };
  }
}
