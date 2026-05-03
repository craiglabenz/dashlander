// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sandbox_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SandboxConfig {

 double get gravity; double get thrustPower; bool get infiniteFuel;
/// Create a copy of SandboxConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SandboxConfigCopyWith<SandboxConfig> get copyWith => _$SandboxConfigCopyWithImpl<SandboxConfig>(this as SandboxConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SandboxConfig&&(identical(other.gravity, gravity) || other.gravity == gravity)&&(identical(other.thrustPower, thrustPower) || other.thrustPower == thrustPower)&&(identical(other.infiniteFuel, infiniteFuel) || other.infiniteFuel == infiniteFuel));
}


@override
int get hashCode => Object.hash(runtimeType,gravity,thrustPower,infiniteFuel);

@override
String toString() {
  return 'SandboxConfig(gravity: $gravity, thrustPower: $thrustPower, infiniteFuel: $infiniteFuel)';
}


}

/// @nodoc
abstract mixin class $SandboxConfigCopyWith<$Res>  {
  factory $SandboxConfigCopyWith(SandboxConfig value, $Res Function(SandboxConfig) _then) = _$SandboxConfigCopyWithImpl;
@useResult
$Res call({
 double gravity, double thrustPower, bool infiniteFuel
});




}
/// @nodoc
class _$SandboxConfigCopyWithImpl<$Res>
    implements $SandboxConfigCopyWith<$Res> {
  _$SandboxConfigCopyWithImpl(this._self, this._then);

  final SandboxConfig _self;
  final $Res Function(SandboxConfig) _then;

/// Create a copy of SandboxConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gravity = null,Object? thrustPower = null,Object? infiniteFuel = null,}) {
  return _then(_self.copyWith(
gravity: null == gravity ? _self.gravity : gravity // ignore: cast_nullable_to_non_nullable
as double,thrustPower: null == thrustPower ? _self.thrustPower : thrustPower // ignore: cast_nullable_to_non_nullable
as double,infiniteFuel: null == infiniteFuel ? _self.infiniteFuel : infiniteFuel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SandboxConfig].
extension SandboxConfigPatterns on SandboxConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SandboxConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SandboxConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SandboxConfig value)  $default,){
final _that = this;
switch (_that) {
case _SandboxConfig():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SandboxConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SandboxConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double gravity,  double thrustPower,  bool infiniteFuel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SandboxConfig() when $default != null:
return $default(_that.gravity,_that.thrustPower,_that.infiniteFuel);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double gravity,  double thrustPower,  bool infiniteFuel)  $default,) {final _that = this;
switch (_that) {
case _SandboxConfig():
return $default(_that.gravity,_that.thrustPower,_that.infiniteFuel);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double gravity,  double thrustPower,  bool infiniteFuel)?  $default,) {final _that = this;
switch (_that) {
case _SandboxConfig() when $default != null:
return $default(_that.gravity,_that.thrustPower,_that.infiniteFuel);case _:
  return null;

}
}

}

/// @nodoc


class _SandboxConfig implements SandboxConfig {
   _SandboxConfig({required this.gravity, required this.thrustPower, required this.infiniteFuel});
  

@override final  double gravity;
@override final  double thrustPower;
@override final  bool infiniteFuel;

/// Create a copy of SandboxConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SandboxConfigCopyWith<_SandboxConfig> get copyWith => __$SandboxConfigCopyWithImpl<_SandboxConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SandboxConfig&&(identical(other.gravity, gravity) || other.gravity == gravity)&&(identical(other.thrustPower, thrustPower) || other.thrustPower == thrustPower)&&(identical(other.infiniteFuel, infiniteFuel) || other.infiniteFuel == infiniteFuel));
}


@override
int get hashCode => Object.hash(runtimeType,gravity,thrustPower,infiniteFuel);

@override
String toString() {
  return 'SandboxConfig(gravity: $gravity, thrustPower: $thrustPower, infiniteFuel: $infiniteFuel)';
}


}

/// @nodoc
abstract mixin class _$SandboxConfigCopyWith<$Res> implements $SandboxConfigCopyWith<$Res> {
  factory _$SandboxConfigCopyWith(_SandboxConfig value, $Res Function(_SandboxConfig) _then) = __$SandboxConfigCopyWithImpl;
@override @useResult
$Res call({
 double gravity, double thrustPower, bool infiniteFuel
});




}
/// @nodoc
class __$SandboxConfigCopyWithImpl<$Res>
    implements _$SandboxConfigCopyWith<$Res> {
  __$SandboxConfigCopyWithImpl(this._self, this._then);

  final _SandboxConfig _self;
  final $Res Function(_SandboxConfig) _then;

/// Create a copy of SandboxConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gravity = null,Object? thrustPower = null,Object? infiniteFuel = null,}) {
  return _then(_SandboxConfig(
gravity: null == gravity ? _self.gravity : gravity // ignore: cast_nullable_to_non_nullable
as double,thrustPower: null == thrustPower ? _self.thrustPower : thrustPower // ignore: cast_nullable_to_non_nullable
as double,infiniteFuel: null == infiniteFuel ? _self.infiniteFuel : infiniteFuel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
