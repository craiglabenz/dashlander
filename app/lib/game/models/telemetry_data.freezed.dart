// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TelemetryData {

 double get fuel; double get maxFuel; double get vY;// Vertical velocity
 double get vX;// Horizontal velocity
 double get tilt;// Replaces gForce
 double get x; double get y; int get terrainIndexBelow; bool get debugModeEnabled; double get height;
/// Create a copy of TelemetryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryDataCopyWith<TelemetryData> get copyWith => _$TelemetryDataCopyWithImpl<TelemetryData>(this as TelemetryData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryData&&(identical(other.fuel, fuel) || other.fuel == fuel)&&(identical(other.maxFuel, maxFuel) || other.maxFuel == maxFuel)&&(identical(other.vY, vY) || other.vY == vY)&&(identical(other.vX, vX) || other.vX == vX)&&(identical(other.tilt, tilt) || other.tilt == tilt)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.terrainIndexBelow, terrainIndexBelow) || other.terrainIndexBelow == terrainIndexBelow)&&(identical(other.debugModeEnabled, debugModeEnabled) || other.debugModeEnabled == debugModeEnabled)&&(identical(other.height, height) || other.height == height));
}


@override
int get hashCode => Object.hash(runtimeType,fuel,maxFuel,vY,vX,tilt,x,y,terrainIndexBelow,debugModeEnabled,height);

@override
String toString() {
  return 'TelemetryData(fuel: $fuel, maxFuel: $maxFuel, vY: $vY, vX: $vX, tilt: $tilt, x: $x, y: $y, terrainIndexBelow: $terrainIndexBelow, debugModeEnabled: $debugModeEnabled, height: $height)';
}


}

/// @nodoc
abstract mixin class $TelemetryDataCopyWith<$Res>  {
  factory $TelemetryDataCopyWith(TelemetryData value, $Res Function(TelemetryData) _then) = _$TelemetryDataCopyWithImpl;
@useResult
$Res call({
 double fuel, double maxFuel, double vY, double vX, double tilt, double x, double y, int terrainIndexBelow, bool debugModeEnabled, double height
});




}
/// @nodoc
class _$TelemetryDataCopyWithImpl<$Res>
    implements $TelemetryDataCopyWith<$Res> {
  _$TelemetryDataCopyWithImpl(this._self, this._then);

  final TelemetryData _self;
  final $Res Function(TelemetryData) _then;

/// Create a copy of TelemetryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fuel = null,Object? maxFuel = null,Object? vY = null,Object? vX = null,Object? tilt = null,Object? x = null,Object? y = null,Object? terrainIndexBelow = null,Object? debugModeEnabled = null,Object? height = null,}) {
  return _then(_self.copyWith(
fuel: null == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as double,maxFuel: null == maxFuel ? _self.maxFuel : maxFuel // ignore: cast_nullable_to_non_nullable
as double,vY: null == vY ? _self.vY : vY // ignore: cast_nullable_to_non_nullable
as double,vX: null == vX ? _self.vX : vX // ignore: cast_nullable_to_non_nullable
as double,tilt: null == tilt ? _self.tilt : tilt // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,terrainIndexBelow: null == terrainIndexBelow ? _self.terrainIndexBelow : terrainIndexBelow // ignore: cast_nullable_to_non_nullable
as int,debugModeEnabled: null == debugModeEnabled ? _self.debugModeEnabled : debugModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TelemetryData].
extension TelemetryDataPatterns on TelemetryData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TelemetryData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TelemetryData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TelemetryData value)  $default,){
final _that = this;
switch (_that) {
case _TelemetryData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TelemetryData value)?  $default,){
final _that = this;
switch (_that) {
case _TelemetryData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fuel,  double maxFuel,  double vY,  double vX,  double tilt,  double x,  double y,  int terrainIndexBelow,  bool debugModeEnabled,  double height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TelemetryData() when $default != null:
return $default(_that.fuel,_that.maxFuel,_that.vY,_that.vX,_that.tilt,_that.x,_that.y,_that.terrainIndexBelow,_that.debugModeEnabled,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fuel,  double maxFuel,  double vY,  double vX,  double tilt,  double x,  double y,  int terrainIndexBelow,  bool debugModeEnabled,  double height)  $default,) {final _that = this;
switch (_that) {
case _TelemetryData():
return $default(_that.fuel,_that.maxFuel,_that.vY,_that.vX,_that.tilt,_that.x,_that.y,_that.terrainIndexBelow,_that.debugModeEnabled,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fuel,  double maxFuel,  double vY,  double vX,  double tilt,  double x,  double y,  int terrainIndexBelow,  bool debugModeEnabled,  double height)?  $default,) {final _that = this;
switch (_that) {
case _TelemetryData() when $default != null:
return $default(_that.fuel,_that.maxFuel,_that.vY,_that.vX,_that.tilt,_that.x,_that.y,_that.terrainIndexBelow,_that.debugModeEnabled,_that.height);case _:
  return null;

}
}

}

/// @nodoc


class _TelemetryData extends TelemetryData {
   _TelemetryData({required this.fuel, required this.maxFuel, required this.vY, required this.vX, required this.tilt, required this.x, required this.y, required this.terrainIndexBelow, required this.debugModeEnabled, required this.height}): super._();
  

@override final  double fuel;
@override final  double maxFuel;
@override final  double vY;
// Vertical velocity
@override final  double vX;
// Horizontal velocity
@override final  double tilt;
// Replaces gForce
@override final  double x;
@override final  double y;
@override final  int terrainIndexBelow;
@override final  bool debugModeEnabled;
@override final  double height;

/// Create a copy of TelemetryData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TelemetryDataCopyWith<_TelemetryData> get copyWith => __$TelemetryDataCopyWithImpl<_TelemetryData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TelemetryData&&(identical(other.fuel, fuel) || other.fuel == fuel)&&(identical(other.maxFuel, maxFuel) || other.maxFuel == maxFuel)&&(identical(other.vY, vY) || other.vY == vY)&&(identical(other.vX, vX) || other.vX == vX)&&(identical(other.tilt, tilt) || other.tilt == tilt)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.terrainIndexBelow, terrainIndexBelow) || other.terrainIndexBelow == terrainIndexBelow)&&(identical(other.debugModeEnabled, debugModeEnabled) || other.debugModeEnabled == debugModeEnabled)&&(identical(other.height, height) || other.height == height));
}


@override
int get hashCode => Object.hash(runtimeType,fuel,maxFuel,vY,vX,tilt,x,y,terrainIndexBelow,debugModeEnabled,height);

@override
String toString() {
  return 'TelemetryData(fuel: $fuel, maxFuel: $maxFuel, vY: $vY, vX: $vX, tilt: $tilt, x: $x, y: $y, terrainIndexBelow: $terrainIndexBelow, debugModeEnabled: $debugModeEnabled, height: $height)';
}


}

/// @nodoc
abstract mixin class _$TelemetryDataCopyWith<$Res> implements $TelemetryDataCopyWith<$Res> {
  factory _$TelemetryDataCopyWith(_TelemetryData value, $Res Function(_TelemetryData) _then) = __$TelemetryDataCopyWithImpl;
@override @useResult
$Res call({
 double fuel, double maxFuel, double vY, double vX, double tilt, double x, double y, int terrainIndexBelow, bool debugModeEnabled, double height
});




}
/// @nodoc
class __$TelemetryDataCopyWithImpl<$Res>
    implements _$TelemetryDataCopyWith<$Res> {
  __$TelemetryDataCopyWithImpl(this._self, this._then);

  final _TelemetryData _self;
  final $Res Function(_TelemetryData) _then;

/// Create a copy of TelemetryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fuel = null,Object? maxFuel = null,Object? vY = null,Object? vX = null,Object? tilt = null,Object? x = null,Object? y = null,Object? terrainIndexBelow = null,Object? debugModeEnabled = null,Object? height = null,}) {
  return _then(_TelemetryData(
fuel: null == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as double,maxFuel: null == maxFuel ? _self.maxFuel : maxFuel // ignore: cast_nullable_to_non_nullable
as double,vY: null == vY ? _self.vY : vY // ignore: cast_nullable_to_non_nullable
as double,vX: null == vX ? _self.vX : vX // ignore: cast_nullable_to_non_nullable
as double,tilt: null == tilt ? _self.tilt : tilt // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,terrainIndexBelow: null == terrainIndexBelow ? _self.terrainIndexBelow : terrainIndexBelow // ignore: cast_nullable_to_non_nullable
as int,debugModeEnabled: null == debugModeEnabled ? _self.debugModeEnabled : debugModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
