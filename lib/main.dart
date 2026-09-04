import 'package:flutter/widgets.dart';
import 'package:sultan_app/app/app.dart';
import 'package:sultan_app/app/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies();
  runApp(SultanApp(dependencies: dependencies));
}
