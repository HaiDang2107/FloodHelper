import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'authority_app.dart';
import 'data/providers/service_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(apiClientProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AuthorityApp(),
    ),
  );
}
