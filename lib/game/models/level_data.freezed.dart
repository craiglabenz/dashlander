// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LevelData {

 int get id; String get name; double get initialFuel; List<Vector2> get terrainPoints;// Pairs of indices representing landing pads e.g. [3, 4] means segment
// between terrainPoints[3] and [4] is a pad.
 List<int> get padIndices; Vector2 get startPosition;
/// Create a copy of LevelData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelDataCopyWith<LevelData> get copyWith => _$LevelDataCopyWithImpl<LevelData>(this as LevelData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.initialFuel, initialFuel) || other.initialFuel == initialFuel)&&const DeepCollectionEquality().equals(other.terrainPoints, terrainPoints)&&const DeepCollectionEquality().equals(other.padIndices, padIndices)&&(identical(other.startPosition, startPosition) || other.startPosition == startPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,initialFuel,const DeepCollectionEquality().hash(terrainPoints),const DeepCollectionEquality().hash(padIndices),startPosition);

@override
String toString() {
  return 'LevelData(id: $id, name: $name, initialFuel: $initialFuel, terrainPoints: $terrainPoints, padIndices: $padIndices, startPosition: $startPosition)';
}


}

/// @nodoc
abstract mixin class $LevelDataCopyWith<$Res>  {
  factory $LevelDataCopyWith(LevelData value, $Res Function(LevelData) _then) = _$LevelDataCopyWithImpl;
@useResult
$Res call({
 int id, String name, double initialFuel, List<Vector2> terrainPoints, List<int> padIndices, Vector2 startPosition
});




}
/// @nodoc
class _$LevelDataCopyWithImpl<$Res>
    implements $LevelDataCopyWith<$Res> {
  _$LevelDataCopyWithImpl(this._self, this._then);

  final LevelData _self;
  final $Res Function(LevelData) _then;

/// Create a copy of LevelData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? initialFuel = null,Object? terrainPoints = null,Object? padIndices = null,Object? startPosition = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initialFuel: null == initialFuel ? _self.initialFuel : initialFuel // ignore: cast_nullable_to_non_nullable
as double,terrainPoints: null == terrainPoints ? _self.terrainPoints : terrainPoints // ignore: cast_nullable_to_non_nullable
as List<Vector2>,padIndices: null == padIndices ? _self.padIndices : padIndices // ignore: cast_nullable_to_non_nullable
as List<int>,startPosition: null == startPosition ? _self.startPosition : startPosition // ignore: cast_nullable_to_non_nullable
as Vector2,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelData].
extension LevelDataPatterns on LevelData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelData value)  $default,){
final _that = this;
switch (_that) {
case _LevelData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelData value)?  $default,){
final _that = this;
switch (_that) {
case _LevelData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  double initialFuel,  List<Vector2> terrainPoints,  List<int> padIndices,  Vector2 startPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelData() when $default != null:
return $default(_that.id,_that.name,_that.initialFuel,_that.terrainPoints,_that.padIndices,_that.startPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  double initialFuel,  List<Vector2> terrainPoints,  List<int> padIndices,  Vector2 startPosition)  $default,) {final _that = this;
switch (_that) {
case _LevelData():
return $default(_that.id,_that.name,_that.initialFuel,_that.terrainPoints,_that.padIndices,_that.startPosition);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  double initialFuel,  List<Vector2> terrainPoints,  List<int> padIndices,  Vector2 startPosition)?  $default,) {final _that = this;
switch (_that) {
case _LevelData() when $default != null:
return $default(_that.id,_that.name,_that.initialFuel,_that.terrainPoints,_that.padIndices,_that.startPosition);case _:
  return null;

}
}

}

/// @nodoc


class _LevelData implements LevelData {
   _LevelData({required this.id, required this.name, required this.initialFuel, required final  List<Vector2> terrainPoints, required final  List<int> padIndices, required this.startPosition}): _terrainPoints = terrainPoints,_padIndices = padIndices;
  

@override final  int id;
@override final  String name;
@override final  double initialFuel;
 final  List<Vector2> _terrainPoints;
@override List<Vector2> get terrainPoints {
  if (_terrainPoints is EqualUnmodifiableListView) return _terrainPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_terrainPoints);
}

// Pairs of indices representing landing pads e.g. [3, 4] means segment
// between terrainPoints[3] and [4] is a pad.
 final  List<int> _padIndices;
// Pairs of indices representing landing pads e.g. [3, 4] means segment
// between terrainPoints[3] and [4] is a pad.
@override List<int> get padIndices {
  if (_padIndices is EqualUnmodifiableListView) return _padIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_padIndices);
}

@override final  Vector2 startPosition;

/// Create a copy of LevelData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelDataCopyWith<_LevelData> get copyWith => __$LevelDataCopyWithImpl<_LevelData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.initialFuel, initialFuel) || other.initialFuel == initialFuel)&&const DeepCollectionEquality().equals(other._terrainPoints, _terrainPoints)&&const DeepCollectionEquality().equals(other._padIndices, _padIndices)&&(identical(other.startPosition, startPosition) || other.startPosition == startPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,initialFuel,const DeepCollectionEquality().hash(_terrainPoints),const DeepCollectionEquality().hash(_padIndices),startPosition);

@override
String toString() {
  return 'LevelData(id: $id, name: $name, initialFuel: $initialFuel, terrainPoints: $terrainPoints, padIndices: $padIndices, startPosition: $startPosition)';
}


}

/// @nodoc
abstract mixin class _$LevelDataCopyWith<$Res> implements $LevelDataCopyWith<$Res> {
  factory _$LevelDataCopyWith(_LevelData value, $Res Function(_LevelData) _then) = __$LevelDataCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, double initialFuel, List<Vector2> terrainPoints, List<int> padIndices, Vector2 startPosition
});




}
/// @nodoc
class __$LevelDataCopyWithImpl<$Res>
    implements _$LevelDataCopyWith<$Res> {
  __$LevelDataCopyWithImpl(this._self, this._then);

  final _LevelData _self;
  final $Res Function(_LevelData) _then;

/// Create a copy of LevelData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? initialFuel = null,Object? terrainPoints = null,Object? padIndices = null,Object? startPosition = null,}) {
  return _then(_LevelData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,initialFuel: null == initialFuel ? _self.initialFuel : initialFuel // ignore: cast_nullable_to_non_nullable
as double,terrainPoints: null == terrainPoints ? _self._terrainPoints : terrainPoints // ignore: cast_nullable_to_non_nullable
as List<Vector2>,padIndices: null == padIndices ? _self._padIndices : padIndices // ignore: cast_nullable_to_non_nullable
as List<int>,startPosition: null == startPosition ? _self.startPosition : startPosition // ignore: cast_nullable_to_non_nullable
as Vector2,
  ));
}


}

// dart format on
