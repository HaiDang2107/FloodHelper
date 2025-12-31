// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SignupDto _$SignupDtoFromJson(Map<String, dynamic> json) {
  return _SignupDto.fromJson(json);
}

/// @nodoc
mixin _$SignupDto {
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  DateTime? get dob => throw _privateConstructorUsedError;
  String? get village => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get jobPosition => throw _privateConstructorUsedError;

  /// Serializes this SignupDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignupDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignupDtoCopyWith<SignupDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignupDtoCopyWith<$Res> {
  factory $SignupDtoCopyWith(SignupDto value, $Res Function(SignupDto) then) =
      _$SignupDtoCopyWithImpl<$Res, SignupDto>;
  @useResult
  $Res call({
    String username,
    String password,
    String name,
    String phoneNumber,
    String? displayName,
    DateTime? dob,
    String? village,
    String? district,
    String? country,
    String? jobPosition,
  });
}

/// @nodoc
class _$SignupDtoCopyWithImpl<$Res, $Val extends SignupDto>
    implements $SignupDtoCopyWith<$Res> {
  _$SignupDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignupDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? displayName = freezed,
    Object? dob = freezed,
    Object? village = freezed,
    Object? district = freezed,
    Object? country = freezed,
    Object? jobPosition = freezed,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            village: freezed == village
                ? _value.village
                : village // ignore: cast_nullable_to_non_nullable
                      as String?,
            district: freezed == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            jobPosition: freezed == jobPosition
                ? _value.jobPosition
                : jobPosition // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignupDtoImplCopyWith<$Res>
    implements $SignupDtoCopyWith<$Res> {
  factory _$$SignupDtoImplCopyWith(
    _$SignupDtoImpl value,
    $Res Function(_$SignupDtoImpl) then,
  ) = __$$SignupDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    String password,
    String name,
    String phoneNumber,
    String? displayName,
    DateTime? dob,
    String? village,
    String? district,
    String? country,
    String? jobPosition,
  });
}

/// @nodoc
class __$$SignupDtoImplCopyWithImpl<$Res>
    extends _$SignupDtoCopyWithImpl<$Res, _$SignupDtoImpl>
    implements _$$SignupDtoImplCopyWith<$Res> {
  __$$SignupDtoImplCopyWithImpl(
    _$SignupDtoImpl _value,
    $Res Function(_$SignupDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignupDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? name = null,
    Object? phoneNumber = null,
    Object? displayName = freezed,
    Object? dob = freezed,
    Object? village = freezed,
    Object? district = freezed,
    Object? country = freezed,
    Object? jobPosition = freezed,
  }) {
    return _then(
      _$SignupDtoImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        village: freezed == village
            ? _value.village
            : village // ignore: cast_nullable_to_non_nullable
                  as String?,
        district: freezed == district
            ? _value.district
            : district // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        jobPosition: freezed == jobPosition
            ? _value.jobPosition
            : jobPosition // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SignupDtoImpl implements _SignupDto {
  _$SignupDtoImpl({
    required this.username,
    required this.password,
    required this.name,
    required this.phoneNumber,
    this.displayName,
    this.dob,
    this.village,
    this.district,
    this.country,
    this.jobPosition,
  });

  factory _$SignupDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignupDtoImplFromJson(json);

  @override
  final String username;
  @override
  final String password;
  @override
  final String name;
  @override
  final String phoneNumber;
  @override
  final String? displayName;
  @override
  final DateTime? dob;
  @override
  final String? village;
  @override
  final String? district;
  @override
  final String? country;
  @override
  final String? jobPosition;

  @override
  String toString() {
    return 'SignupDto(username: $username, password: $password, name: $name, phoneNumber: $phoneNumber, displayName: $displayName, dob: $dob, village: $village, district: $district, country: $country, jobPosition: $jobPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignupDtoImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.village, village) || other.village == village) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.jobPosition, jobPosition) ||
                other.jobPosition == jobPosition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    password,
    name,
    phoneNumber,
    displayName,
    dob,
    village,
    district,
    country,
    jobPosition,
  );

  /// Create a copy of SignupDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignupDtoImplCopyWith<_$SignupDtoImpl> get copyWith =>
      __$$SignupDtoImplCopyWithImpl<_$SignupDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignupDtoImplToJson(this);
  }
}

abstract class _SignupDto implements SignupDto {
  factory _SignupDto({
    required final String username,
    required final String password,
    required final String name,
    required final String phoneNumber,
    final String? displayName,
    final DateTime? dob,
    final String? village,
    final String? district,
    final String? country,
    final String? jobPosition,
  }) = _$SignupDtoImpl;

  factory _SignupDto.fromJson(Map<String, dynamic> json) =
      _$SignupDtoImpl.fromJson;

  @override
  String get username;
  @override
  String get password;
  @override
  String get name;
  @override
  String get phoneNumber;
  @override
  String? get displayName;
  @override
  DateTime? get dob;
  @override
  String? get village;
  @override
  String? get district;
  @override
  String? get country;
  @override
  String? get jobPosition;

  /// Create a copy of SignupDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignupDtoImplCopyWith<_$SignupDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SigninDto _$SigninDtoFromJson(Map<String, dynamic> json) {
  return _SigninDto.fromJson(json);
}

/// @nodoc
mixin _$SigninDto {
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;

  /// Serializes this SigninDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SigninDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SigninDtoCopyWith<SigninDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SigninDtoCopyWith<$Res> {
  factory $SigninDtoCopyWith(SigninDto value, $Res Function(SigninDto) then) =
      _$SigninDtoCopyWithImpl<$Res, SigninDto>;
  @useResult
  $Res call({String username, String password, String? deviceId});
}

/// @nodoc
class _$SigninDtoCopyWithImpl<$Res, $Val extends SigninDto>
    implements $SigninDtoCopyWith<$Res> {
  _$SigninDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SigninDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? deviceId = freezed,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            deviceId: freezed == deviceId
                ? _value.deviceId
                : deviceId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SigninDtoImplCopyWith<$Res>
    implements $SigninDtoCopyWith<$Res> {
  factory _$$SigninDtoImplCopyWith(
    _$SigninDtoImpl value,
    $Res Function(_$SigninDtoImpl) then,
  ) = __$$SigninDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String password, String? deviceId});
}

/// @nodoc
class __$$SigninDtoImplCopyWithImpl<$Res>
    extends _$SigninDtoCopyWithImpl<$Res, _$SigninDtoImpl>
    implements _$$SigninDtoImplCopyWith<$Res> {
  __$$SigninDtoImplCopyWithImpl(
    _$SigninDtoImpl _value,
    $Res Function(_$SigninDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SigninDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
    Object? deviceId = freezed,
  }) {
    return _then(
      _$SigninDtoImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        deviceId: freezed == deviceId
            ? _value.deviceId
            : deviceId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SigninDtoImpl implements _SigninDto {
  _$SigninDtoImpl({
    required this.username,
    required this.password,
    this.deviceId,
  });

  factory _$SigninDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SigninDtoImplFromJson(json);

  @override
  final String username;
  @override
  final String password;
  @override
  final String? deviceId;

  @override
  String toString() {
    return 'SigninDto(username: $username, password: $password, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SigninDtoImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, password, deviceId);

  /// Create a copy of SigninDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SigninDtoImplCopyWith<_$SigninDtoImpl> get copyWith =>
      __$$SigninDtoImplCopyWithImpl<_$SigninDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SigninDtoImplToJson(this);
  }
}

abstract class _SigninDto implements SigninDto {
  factory _SigninDto({
    required final String username,
    required final String password,
    final String? deviceId,
  }) = _$SigninDtoImpl;

  factory _SigninDto.fromJson(Map<String, dynamic> json) =
      _$SigninDtoImpl.fromJson;

  @override
  String get username;
  @override
  String get password;
  @override
  String? get deviceId;

  /// Create a copy of SigninDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SigninDtoImplCopyWith<_$SigninDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerifyCodeDto _$VerifyCodeDtoFromJson(Map<String, dynamic> json) {
  return _VerifyCodeDto.fromJson(json);
}

/// @nodoc
mixin _$VerifyCodeDto {
  String get username => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  /// Serializes this VerifyCodeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyCodeDtoCopyWith<VerifyCodeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyCodeDtoCopyWith<$Res> {
  factory $VerifyCodeDtoCopyWith(
    VerifyCodeDto value,
    $Res Function(VerifyCodeDto) then,
  ) = _$VerifyCodeDtoCopyWithImpl<$Res, VerifyCodeDto>;
  @useResult
  $Res call({String username, String code});
}

/// @nodoc
class _$VerifyCodeDtoCopyWithImpl<$Res, $Val extends VerifyCodeDto>
    implements $VerifyCodeDtoCopyWith<$Res> {
  _$VerifyCodeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? code = null}) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerifyCodeDtoImplCopyWith<$Res>
    implements $VerifyCodeDtoCopyWith<$Res> {
  factory _$$VerifyCodeDtoImplCopyWith(
    _$VerifyCodeDtoImpl value,
    $Res Function(_$VerifyCodeDtoImpl) then,
  ) = __$$VerifyCodeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String code});
}

/// @nodoc
class __$$VerifyCodeDtoImplCopyWithImpl<$Res>
    extends _$VerifyCodeDtoCopyWithImpl<$Res, _$VerifyCodeDtoImpl>
    implements _$$VerifyCodeDtoImplCopyWith<$Res> {
  __$$VerifyCodeDtoImplCopyWithImpl(
    _$VerifyCodeDtoImpl _value,
    $Res Function(_$VerifyCodeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerifyCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? code = null}) {
    return _then(
      _$VerifyCodeDtoImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyCodeDtoImpl implements _VerifyCodeDto {
  _$VerifyCodeDtoImpl({required this.username, required this.code});

  factory _$VerifyCodeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyCodeDtoImplFromJson(json);

  @override
  final String username;
  @override
  final String code;

  @override
  String toString() {
    return 'VerifyCodeDto(username: $username, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyCodeDtoImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, code);

  /// Create a copy of VerifyCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyCodeDtoImplCopyWith<_$VerifyCodeDtoImpl> get copyWith =>
      __$$VerifyCodeDtoImplCopyWithImpl<_$VerifyCodeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyCodeDtoImplToJson(this);
  }
}

abstract class _VerifyCodeDto implements VerifyCodeDto {
  factory _VerifyCodeDto({
    required final String username,
    required final String code,
  }) = _$VerifyCodeDtoImpl;

  factory _VerifyCodeDto.fromJson(Map<String, dynamic> json) =
      _$VerifyCodeDtoImpl.fromJson;

  @override
  String get username;
  @override
  String get code;

  /// Create a copy of VerifyCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyCodeDtoImplCopyWith<_$VerifyCodeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResendVerificationCodeDto _$ResendVerificationCodeDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ResendVerificationCodeDto.fromJson(json);
}

/// @nodoc
mixin _$ResendVerificationCodeDto {
  String get username => throw _privateConstructorUsedError;

  /// Serializes this ResendVerificationCodeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResendVerificationCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResendVerificationCodeDtoCopyWith<ResendVerificationCodeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResendVerificationCodeDtoCopyWith<$Res> {
  factory $ResendVerificationCodeDtoCopyWith(
    ResendVerificationCodeDto value,
    $Res Function(ResendVerificationCodeDto) then,
  ) = _$ResendVerificationCodeDtoCopyWithImpl<$Res, ResendVerificationCodeDto>;
  @useResult
  $Res call({String username});
}

/// @nodoc
class _$ResendVerificationCodeDtoCopyWithImpl<
  $Res,
  $Val extends ResendVerificationCodeDto
>
    implements $ResendVerificationCodeDtoCopyWith<$Res> {
  _$ResendVerificationCodeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResendVerificationCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null}) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResendVerificationCodeDtoImplCopyWith<$Res>
    implements $ResendVerificationCodeDtoCopyWith<$Res> {
  factory _$$ResendVerificationCodeDtoImplCopyWith(
    _$ResendVerificationCodeDtoImpl value,
    $Res Function(_$ResendVerificationCodeDtoImpl) then,
  ) = __$$ResendVerificationCodeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username});
}

/// @nodoc
class __$$ResendVerificationCodeDtoImplCopyWithImpl<$Res>
    extends
        _$ResendVerificationCodeDtoCopyWithImpl<
          $Res,
          _$ResendVerificationCodeDtoImpl
        >
    implements _$$ResendVerificationCodeDtoImplCopyWith<$Res> {
  __$$ResendVerificationCodeDtoImplCopyWithImpl(
    _$ResendVerificationCodeDtoImpl _value,
    $Res Function(_$ResendVerificationCodeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResendVerificationCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null}) {
    return _then(
      _$ResendVerificationCodeDtoImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResendVerificationCodeDtoImpl implements _ResendVerificationCodeDto {
  _$ResendVerificationCodeDtoImpl({required this.username});

  factory _$ResendVerificationCodeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResendVerificationCodeDtoImplFromJson(json);

  @override
  final String username;

  @override
  String toString() {
    return 'ResendVerificationCodeDto(username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResendVerificationCodeDtoImpl &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username);

  /// Create a copy of ResendVerificationCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResendVerificationCodeDtoImplCopyWith<_$ResendVerificationCodeDtoImpl>
  get copyWith =>
      __$$ResendVerificationCodeDtoImplCopyWithImpl<
        _$ResendVerificationCodeDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResendVerificationCodeDtoImplToJson(this);
  }
}

abstract class _ResendVerificationCodeDto implements ResendVerificationCodeDto {
  factory _ResendVerificationCodeDto({required final String username}) =
      _$ResendVerificationCodeDtoImpl;

  factory _ResendVerificationCodeDto.fromJson(Map<String, dynamic> json) =
      _$ResendVerificationCodeDtoImpl.fromJson;

  @override
  String get username;

  /// Create a copy of ResendVerificationCodeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResendVerificationCodeDtoImplCopyWith<_$ResendVerificationCodeDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ForgotPasswordDto _$ForgotPasswordDtoFromJson(Map<String, dynamic> json) {
  return _ForgotPasswordDto.fromJson(json);
}

/// @nodoc
mixin _$ForgotPasswordDto {
  String get username => throw _privateConstructorUsedError;

  /// Serializes this ForgotPasswordDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ForgotPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgotPasswordDtoCopyWith<ForgotPasswordDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgotPasswordDtoCopyWith<$Res> {
  factory $ForgotPasswordDtoCopyWith(
    ForgotPasswordDto value,
    $Res Function(ForgotPasswordDto) then,
  ) = _$ForgotPasswordDtoCopyWithImpl<$Res, ForgotPasswordDto>;
  @useResult
  $Res call({String username});
}

/// @nodoc
class _$ForgotPasswordDtoCopyWithImpl<$Res, $Val extends ForgotPasswordDto>
    implements $ForgotPasswordDtoCopyWith<$Res> {
  _$ForgotPasswordDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgotPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null}) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ForgotPasswordDtoImplCopyWith<$Res>
    implements $ForgotPasswordDtoCopyWith<$Res> {
  factory _$$ForgotPasswordDtoImplCopyWith(
    _$ForgotPasswordDtoImpl value,
    $Res Function(_$ForgotPasswordDtoImpl) then,
  ) = __$$ForgotPasswordDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username});
}

/// @nodoc
class __$$ForgotPasswordDtoImplCopyWithImpl<$Res>
    extends _$ForgotPasswordDtoCopyWithImpl<$Res, _$ForgotPasswordDtoImpl>
    implements _$$ForgotPasswordDtoImplCopyWith<$Res> {
  __$$ForgotPasswordDtoImplCopyWithImpl(
    _$ForgotPasswordDtoImpl _value,
    $Res Function(_$ForgotPasswordDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ForgotPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null}) {
    return _then(
      _$ForgotPasswordDtoImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ForgotPasswordDtoImpl implements _ForgotPasswordDto {
  _$ForgotPasswordDtoImpl({required this.username});

  factory _$ForgotPasswordDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForgotPasswordDtoImplFromJson(json);

  @override
  final String username;

  @override
  String toString() {
    return 'ForgotPasswordDto(username: $username)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordDtoImpl &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username);

  /// Create a copy of ForgotPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordDtoImplCopyWith<_$ForgotPasswordDtoImpl> get copyWith =>
      __$$ForgotPasswordDtoImplCopyWithImpl<_$ForgotPasswordDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ForgotPasswordDtoImplToJson(this);
  }
}

abstract class _ForgotPasswordDto implements ForgotPasswordDto {
  factory _ForgotPasswordDto({required final String username}) =
      _$ForgotPasswordDtoImpl;

  factory _ForgotPasswordDto.fromJson(Map<String, dynamic> json) =
      _$ForgotPasswordDtoImpl.fromJson;

  @override
  String get username;

  /// Create a copy of ForgotPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordDtoImplCopyWith<_$ForgotPasswordDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResetPasswordDto _$ResetPasswordDtoFromJson(Map<String, dynamic> json) {
  return _ResetPasswordDto.fromJson(json);
}

/// @nodoc
mixin _$ResetPasswordDto {
  String get newPassword => throw _privateConstructorUsedError;

  /// Serializes this ResetPasswordDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResetPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResetPasswordDtoCopyWith<ResetPasswordDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetPasswordDtoCopyWith<$Res> {
  factory $ResetPasswordDtoCopyWith(
    ResetPasswordDto value,
    $Res Function(ResetPasswordDto) then,
  ) = _$ResetPasswordDtoCopyWithImpl<$Res, ResetPasswordDto>;
  @useResult
  $Res call({String newPassword});
}

/// @nodoc
class _$ResetPasswordDtoCopyWithImpl<$Res, $Val extends ResetPasswordDto>
    implements $ResetPasswordDtoCopyWith<$Res> {
  _$ResetPasswordDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResetPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? newPassword = null}) {
    return _then(
      _value.copyWith(
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResetPasswordDtoImplCopyWith<$Res>
    implements $ResetPasswordDtoCopyWith<$Res> {
  factory _$$ResetPasswordDtoImplCopyWith(
    _$ResetPasswordDtoImpl value,
    $Res Function(_$ResetPasswordDtoImpl) then,
  ) = __$$ResetPasswordDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String newPassword});
}

/// @nodoc
class __$$ResetPasswordDtoImplCopyWithImpl<$Res>
    extends _$ResetPasswordDtoCopyWithImpl<$Res, _$ResetPasswordDtoImpl>
    implements _$$ResetPasswordDtoImplCopyWith<$Res> {
  __$$ResetPasswordDtoImplCopyWithImpl(
    _$ResetPasswordDtoImpl _value,
    $Res Function(_$ResetPasswordDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResetPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? newPassword = null}) {
    return _then(
      _$ResetPasswordDtoImpl(
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResetPasswordDtoImpl implements _ResetPasswordDto {
  _$ResetPasswordDtoImpl({required this.newPassword});

  factory _$ResetPasswordDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResetPasswordDtoImplFromJson(json);

  @override
  final String newPassword;

  @override
  String toString() {
    return 'ResetPasswordDto(newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordDtoImpl &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, newPassword);

  /// Create a copy of ResetPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordDtoImplCopyWith<_$ResetPasswordDtoImpl> get copyWith =>
      __$$ResetPasswordDtoImplCopyWithImpl<_$ResetPasswordDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResetPasswordDtoImplToJson(this);
  }
}

abstract class _ResetPasswordDto implements ResetPasswordDto {
  factory _ResetPasswordDto({required final String newPassword}) =
      _$ResetPasswordDtoImpl;

  factory _ResetPasswordDto.fromJson(Map<String, dynamic> json) =
      _$ResetPasswordDtoImpl.fromJson;

  @override
  String get newPassword;

  /// Create a copy of ResetPasswordDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordDtoImplCopyWith<_$ResetPasswordDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RefreshTokenDto _$RefreshTokenDtoFromJson(Map<String, dynamic> json) {
  return _RefreshTokenDto.fromJson(json);
}

/// @nodoc
mixin _$RefreshTokenDto {
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this RefreshTokenDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefreshTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefreshTokenDtoCopyWith<RefreshTokenDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshTokenDtoCopyWith<$Res> {
  factory $RefreshTokenDtoCopyWith(
    RefreshTokenDto value,
    $Res Function(RefreshTokenDto) then,
  ) = _$RefreshTokenDtoCopyWithImpl<$Res, RefreshTokenDto>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$RefreshTokenDtoCopyWithImpl<$Res, $Val extends RefreshTokenDto>
    implements $RefreshTokenDtoCopyWith<$Res> {
  _$RefreshTokenDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefreshTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _value.copyWith(
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RefreshTokenDtoImplCopyWith<$Res>
    implements $RefreshTokenDtoCopyWith<$Res> {
  factory _$$RefreshTokenDtoImplCopyWith(
    _$RefreshTokenDtoImpl value,
    $Res Function(_$RefreshTokenDtoImpl) then,
  ) = __$$RefreshTokenDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$RefreshTokenDtoImplCopyWithImpl<$Res>
    extends _$RefreshTokenDtoCopyWithImpl<$Res, _$RefreshTokenDtoImpl>
    implements _$$RefreshTokenDtoImplCopyWith<$Res> {
  __$$RefreshTokenDtoImplCopyWithImpl(
    _$RefreshTokenDtoImpl _value,
    $Res Function(_$RefreshTokenDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RefreshTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? refreshToken = null}) {
    return _then(
      _$RefreshTokenDtoImpl(
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RefreshTokenDtoImpl implements _RefreshTokenDto {
  _$RefreshTokenDtoImpl({required this.refreshToken});

  factory _$RefreshTokenDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefreshTokenDtoImplFromJson(json);

  @override
  final String refreshToken;

  @override
  String toString() {
    return 'RefreshTokenDto(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshTokenDtoImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of RefreshTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshTokenDtoImplCopyWith<_$RefreshTokenDtoImpl> get copyWith =>
      __$$RefreshTokenDtoImplCopyWithImpl<_$RefreshTokenDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RefreshTokenDtoImplToJson(this);
  }
}

abstract class _RefreshTokenDto implements RefreshTokenDto {
  factory _RefreshTokenDto({required final String refreshToken}) =
      _$RefreshTokenDtoImpl;

  factory _RefreshTokenDto.fromJson(Map<String, dynamic> json) =
      _$RefreshTokenDtoImpl.fromJson;

  @override
  String get refreshToken;

  /// Create a copy of RefreshTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshTokenDtoImplCopyWith<_$RefreshTokenDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
