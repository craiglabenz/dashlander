import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_layer/data_layer.dart';
import 'package:data_layer_firestore/data_layer_firestore.dart';
import 'package:data_layer_hive/data_layer_hive.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

final replayBindings = CreationBindings<GameReplay>(
  getId: (r) => r.id.isEmpty ? null : r.id,
  fromJson: (json) => GameReplay.fromJson(json),
  toJson: (r) => r.toJson(),
  save: (r) {
    if (r.id.isNotEmpty) return r;
    return r.copyWith(id: const Uuid().v4());
  },
);

class ReplayRepository extends Repository<GameReplay> {
  ReplayRepository({
    required FirebaseFirestore firestore,
    required Future<void> hiveInit,
  }) : super(
         SourceList(
           bindings: replayBindings,
           sources: [
             LocalSource.builders<GameReplay>(
               bindings: replayBindings,
               itemCache: (name) => HiveCache<GameReplay>('replay_items_$name', hiveInit),
               stringSetCache: (name) => HiveCache<Set<String>>('replay_set_$name', hiveInit),
               dateTimeCache: (name) => HiveCache<DateTime>('replay_time_$name', hiveInit),
             ),
             FirestoreSource<GameReplay>(
               firestore,
               bindings: replayBindings,
               collectionName: 'replays',
             ),
           ],
         ),
       );
}
