// Copyright (c) 2021, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

Random random = Random();

abstract class Benchmark extends BenchmarkBase {
  final int size;
  final int iter;
  final List<int> input;

  Benchmark(String name, this.size, this.iter)
      : input = List<int>.generate(size, (i) => random.nextInt(256)),
        super(name);

  @override
  void exercise() {
    for (int i = 0; i < iter; ++i) {
      run();
    }
  }

  void showDiff(List<BenchmarkBase> others) {
    var data = measureDiff({...others, this});
    var mine = data[name]!;
    var best = data.values.fold(mine, min);
    for (var entry in data.entries) {
      var message = "${entry.key} Runtime: ${entry.value} ms";
      if (entry.value == best) {
        message += " [best]";
      }
      if (entry.key != name) {
        message += " ~ ${(entry.value - mine)} ms";
      }
      print(message);
    }
  }
}

Map<String, int> measureDiff(Iterable<BenchmarkBase> benchmarks) {
  Map<String, int> data = {};
  for (BenchmarkBase benchmark in benchmarks) {
    data[benchmark.name] = benchmark.measure().round();
  }
  return data;
}
