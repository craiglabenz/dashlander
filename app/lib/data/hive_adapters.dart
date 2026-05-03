import 'package:hive_ce/hive.dart';
import 'package:shared/shared.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<GameReplay>(),
  AdapterSpec<ThrusterAction>(),
  AdapterSpec<ThrusterType>(),
])
// ignore: unused_element
void _() {}
