import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/authority_repository.dart';
import '../repositories/real/real_authority_repository.dart';
import 'service_providers.dart';

part 'authority_providers.g.dart';

@riverpod
AuthorityRepository authorityRepository(Ref ref) {
  return RealAuthorityRepository(
    authorityService: ref.read(authorityServiceProvider),
  );
}
