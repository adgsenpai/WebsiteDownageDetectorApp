import 'package:flutter/material.dart';

// screens
import 'package:material_kit_flutter/screens/home.dart';
import 'package:material_kit_flutter/screens/settings.dart';

void main() => runApp(ADGSDK());

class ADGSDK extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Website Downage Detector",
        debugShowCheckedModeBanner: false,
        initialRoute: "/home",
        routes: <String, WidgetBuilder>{
          "/home": (BuildContext context) => new Home(),
          "/settings": (BuildContext context) => new Settings(),
        });
  }
}
