// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_replay.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThrusterAction {

 ThrusterType get thruster; bool get isFiring; int get timestampMs;
/// Create a copy of ThrusterAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThrusterActionCopyWith<ThrusterAction> get copyWith => _$ThrusterActionCopyWithImpl<ThrusterAction>(this as ThrusterAction, _$identity);

  /// Serializes this ThrusterAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThrusterAction&&(identical(other.thruster, thruster) || other.thruster == thruster)&&(identical(other.isFiring, isFiring) || other.isFiring == isFiring)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thruster,isFiring,timestampMs);

@override
String toString() {
  return 'ThrusterAction(thruster: $thruster, isFiring: $isFiring, timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class $ThrusterActionCopyWith<$Res>  {
  factory $ThrusterActionCopyWith(ThrusterAction value, $Res Function(ThrusterAction) _then) = _$ThrusterActionCopyWithImpl;
@useResult
$Res call({
 ThrusterType thruster, bool isFiring, int timestampMs
});




}
/// @nodoc
class _$ThrusterActionCopyWithImpl<$Res>
    implements $ThrusterActionCopyWith<$Res> {
  _$ThrusterActionCopyWithImpl(this._self, this._then);

  final ThrusterAction _self;
  final $Res Function(ThrusterAction) _then;

/// Create a copy of ThrusterAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? thruster = null,Object? isFiring = null,Object? timestampMs = null,}) {
  return _then(_self.copyWith(
thruster: null == thruster ? _self.thruster : thruster // ignore: cast_nullable_to_non_nullable
as ThrusterType,isFiring: null == isFiring ? _self.isFiring : isFiring // ignore: cast_nullable_to_non_nullable
as bool,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThrusterAction].
extension ThrusterActionPatterns on ThrusterAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThrusterAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThrusterAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThrusterAction value)  $default,){
final _that = this;
switch (_that) {
case _ThrusterAction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThrusterAction value)?  $default,){
final _that = this;
switch (_that) {
case _ThrusterAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThrusterType thruster,  bool isFiring,  int timestampMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThrusterAction() when $default != null:
return $default(_that.thruster,_that.isFiring,_that.timestampMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThrusterType thruster,  bool isFiring,  int timestampMs)  $default,) {final _that = this;
switch (_that) {
case _ThrusterAction():
return $default(_that.thruster,_that.isFiring,_that.timestampMs);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThrusterType thruster,  bool isFiring,  int timestampMs)?  $default,) {final _that = this;
switch (_that) {
case _ThrusterAction() when $default != null:
return $default(_that.thruster,_that.isFiring,_that.timestampMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThrusterAction implements ThrusterAction {
  const _ThrusterAction({required this.thruster, required this.isFiring, required this.timestampMs});
  factory _ThrusterAction.fromJson(Map<String, dynamic> json) => _$ThrusterActionFromJson(json);

@override final  ThrusterType thruster;
@override final  bool isFiring;
@override final  int timestampMs;

/// Create a copy of ThrusterAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThrusterActionCopyWith<_ThrusterAction> get copyWith => __$ThrusterActionCopyWithImpl<_ThrusterAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThrusterActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThrusterAction&&(identical(other.thruster, thruster) || other.thruster == thruster)&&(identical(other.isFiring, isFiring) || other.isFiring == isFiring)&&(identical(other.timestampMs, timestampMs) || other.timestampMs == timestampMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thruster,isFiring,timestampMs);

@override
String toString() {
  return 'ThrusterAction(thruster: $thruster, isFiring: $isFiring, timestampMs: $timestampMs)';
}


}

/// @nodoc
abstract mixin class _$ThrusterActionCopyWith<$Res> implements $ThrusterActionCopyWith<$Res> {
  factory _$ThrusterActionCopyWith(_ThrusterAction value, $Res Function(_ThrusterAction) _then) = __$ThrusterActionCopyWithImpl;
@override @useResult
$Res call({
 ThrusterType thruster, bool isFiring, int timestampMs
});




}
/// @nodoc
class __$ThrusterActionCopyWithImpl<$Res>
    implements _$ThrusterActionCopyWith<$Res> {
  __$ThrusterActionCopyWithImpl(this._self, this._then);

  final _ThrusterAction _self;
  final $Res Function(_ThrusterAction) _then;

/// Create a copy of ThrusterAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? thruster = null,Object? isFiring = null,Object? timestampMs = null,}) {
  return _then(_ThrusterAction(
thruster: null == thruster ? _self.thruster : thruster // ignore: cast_nullable_to_non_nullable
as ThrusterType,isFiring: null == isFiring ? _self.isFiring : isFiring // ignore: cast_nullable_to_non_nullable
as bool,timestampMs: null == timestampMs ? _self.timestampMs : timestampMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GameReplay {

 String get userId; int get score; int get levelSeed; List<ThrusterAction> get actions; int get durationMs;
/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameReplayCopyWith<GameReplay> get copyWith => _$GameReplayCopyWithImpl<GameReplay>(this as GameReplay, _$identity);

  /// Serializes this GameReplay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameReplay&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score)&&(identical(other.levelSeed, levelSeed) || other.levelSeed == levelSeed)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,score,levelSeed,const DeepCollectionEquality().hash(actions),durationMs);

@override
String toString() {
  return 'GameReplay(userId: $userId, score: $score, levelSeed: $levelSeed, actions: $actions, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class $GameReplayCopyWith<$Res>  {
  factory $GameReplayCopyWith(GameReplay value, $Res Function(GameReplay) _then) = _$GameReplayCopyWithImpl;
@useResult
$Res call({
 String userId, int score, int levelSeed, List<ThrusterAction> actions, int durationMs
});




}
/// @nodoc
class _$GameReplayCopyWithImpl<$Res>
    implements $GameReplayCopyWith<$Res> {
  _$GameReplayCopyWithImpl(this._self, this._then);

  final GameReplay _self;
  final $Res Function(GameReplay) _then;

/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? score = null,Object? levelSeed = null,Object? actions = null,Object? durationMs = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,levelSeed: null == levelSeed ? _self.levelSeed : levelSeed // ignore: cast_nullable_to_non_nullable
as int,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<ThrusterAction>,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameReplay].
extension GameReplayPatterns on GameReplay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameReplay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameReplay value)  $default,){
final _that = this;
switch (_that) {
case _GameReplay():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameReplay value)?  $default,){
final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int score,  int levelSeed,  List<ThrusterAction> actions,  int durationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
return $default(_that.userId,_that.score,_that.levelSeed,_that.actions,_that.durationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int score,  int levelSeed,  List<ThrusterAction> actions,  int durationMs)  $default,) {final _that = this;
switch (_that) {
case _GameReplay():
return $default(_that.userId,_that.score,_that.levelSeed,_that.actions,_that.durationMs);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int score,  int levelSeed,  List<ThrusterAction> actions,  int durationMs)?  $default,) {final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
return $default(_that.userId,_that.score,_that.levelSeed,_that.actions,_that.durationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameReplay implements GameReplay {
  const _GameReplay({required this.userId, required this.score, required this.levelSeed, required final  List<ThrusterAction> actions, required this.durationMs}): _actions = actions;
  factory _GameReplay.fromJson(Map<String, dynamic> json) => _$GameReplayFromJson(json);

@override final  String userId;
@override final  int score;
@override final  int levelSeed;
 final  List<ThrusterAction> _actions;
@override List<ThrusterAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  int durationMs;

/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameReplayCopyWith<_GameReplay> get copyWith => __$GameReplayCopyWithImpl<_GameReplay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameReplayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameReplay&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.score, score) || other.score == score)&&(identical(other.levelSeed, levelSeed) || other.levelSeed == levelSeed)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,score,levelSeed,const DeepCollectionEquality().hash(_actions),durationMs);

@override
String toString() {
  return 'GameReplay(userId: $userId, score: $score, levelSeed: $levelSeed, actions: $actions, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class _$GameReplayCopyWith<$Res> implements $GameReplayCopyWith<$Res> {
  factory _$GameReplayCopyWith(_GameReplay value, $Res Function(_GameReplay) _then) = __$GameReplayCopyWithImpl;
@override @useResult
$Res call({
 String userId, int score, int levelSeed, List<ThrusterAction> actions, int durationMs
});




}
/// @nodoc
class __$GameReplayCopyWithImpl<$Res>
    implements _$GameReplayCopyWith<$Res> {
  __$GameReplayCopyWithImpl(this._self, this._then);

  final _GameReplay _self;
  final $Res Function(_GameReplay) _then;

/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? score = null,Object? levelSeed = null,Object? actions = null,Object? durationMs = null,}) {
  return _then(_GameReplay(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,levelSeed: null == levelSeed ? _self.levelSeed : levelSeed // ignore: cast_nullable_to_non_nullable
as int,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<ThrusterAction>,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
