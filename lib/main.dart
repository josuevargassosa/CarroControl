import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();

  runApp(
    GetMaterialApp(
      title: 'CarroControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('CarroControl'),
        ),
      ),
    ),
  );
}
