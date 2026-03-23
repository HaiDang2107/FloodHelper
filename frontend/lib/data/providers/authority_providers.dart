import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/authority_repository.dart';
import '../repositories/mock/mock_authority_repository.dart';

part 'authority_providers.g.dart';

@riverpod
AuthorityRepository authorityRepository(Ref ref) {
  return MockAuthorityRepository();
}
