import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/authority_router.dart';
import 'ui/authority/theme/authority_theme.dart';

class AuthorityApp extends ConsumerWidget {
  const AuthorityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(authorityRouterProvider);

    return MaterialApp.router(
      title: 'FloodHelper Authority',
      debugShowCheckedModeBanner: false,
      theme: AuthorityTheme.lightTheme,
      routerConfig: router,
    );
  }
}
