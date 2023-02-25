import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'product/views/main_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF212121),
            centerTitle: true,
          ),
          scaffoldBackgroundColor: const Color(0xFF303030),
          cardColor: const Color(0xFF424242),
          listTileTheme: const ListTileThemeData(
              textColor: Colors.white, ),),
      home: FutureBuilder(
        future: initializePermissions(),
        builder: (context, snap) {
          if (ConnectionState.done == snap.connectionState) {
            // return const ChartView();
            return const MainView();
          }
          return const Scaffold(
              backgroundColor: Color(0xFF303030),
              body: Center(child: Text('Initializing')));
        },
      ),
    );
  }
}

Future<void> initializePermissions() async {
  try {
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetooth.request();
  } catch (e) {
    rethrow;
  }
}
