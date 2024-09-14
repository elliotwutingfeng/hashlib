// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:hashlib/hashlib.dart';
import 'package:hashlib/src/algorithms/random/random.dart';
import 'package:test/test.dart';

const int _maxInt = 0xFFFFFFFF;

Iterable<int> testGenerator() sync* {
  while (true) {
    yield _maxInt;
  }
}

var testRandom = HashlibRandom.generator(testGenerator().iterator);

void runFunctionalText(HashlibRandom rand) {
  rand.nextInt();
  rand.nextBetween(30, 50);
  rand.nextBool();
  rand.nextByte();
  rand.nextBytes(10);
  rand.nextDouble();
  rand.nextInt();
  rand.nextNumbers(10);
  rand.nextString(10);
  rand.nextWord();
}

void main() {
  group('functional tests', () {
    test("system random", () {
      runFunctionalText(HashlibRandom(RandomGenerator.system));
    });
    group("keccak random", () {
      test('functions', () {
        runFunctionalText(HashlibRandom(RandomGenerator.keccak));
      });
      test('with seed', () {
        var rand = HashlibRandom(RandomGenerator.keccak, seed: 100);
        expect(rand.nextInt(), 3662713900);
      });
    });
    group("sha256 random", () {
      test("functions", () {
        runFunctionalText(HashlibRandom(RandomGenerator.sha256));
      });
      test('with seed', () {
        var rand = HashlibRandom(RandomGenerator.sha256, seed: 100);
        expect(rand.nextInt(), 3449288731);
      });
    });
    group("sm3 random", () {
      test("functions", () {
        runFunctionalText(HashlibRandom(RandomGenerator.sm3));
      });
      test('with seed', () {
        var rand = HashlibRandom(RandomGenerator.sm3, seed: 100);
        expect(rand.nextInt(), 894660838);
      });
    });
    group("md5 random", () {
      test("functions", () {
        runFunctionalText(HashlibRandom(RandomGenerator.md5));
      });
      test('with seed', () {
        var rand = HashlibRandom(RandomGenerator.md5, seed: 100);
        expect(rand.nextInt(), 2852136378);
      });
    });
    test("xxh64 random", () {
      runFunctionalText(HashlibRandom(RandomGenerator.xxh64));
    }, tags: ['vm-only']);
  });

  test('seed generator uniqueness with futures', () async {
    final seeds = await Future.wait(List.generate(
      1000,
      (_) => Future.microtask(() {
        return Generators.$nextSeed();
      }),
    ));
    expect(seeds.toSet().length, 1000);
  });

  test('seed generator uniqueness with isolates', () async {
    var version = Platform.version;
    var major = int.parse(version.split('.')[0]);
    var minor = int.parse(version.split('.')[1]);
    if (major > 2 || (major == 2 && minor >= 19)) {
      final seeds = await Future.wait(List.generate(
        1000,
        // ignore: sdk_version_since
        (_) => Isolate.run(() {
          return Generators.$nextSeed();
        }),
      ));
      expect(seeds.toSet().length, 1000);
    }
  }, tags: ['vm-only']);

  test('random bytes length = 0', () {
    expect(randomBytes(0), []);
  });
  test('random bytes length = 1', () {
    expect(randomBytes(1).length, 1);
  });
  test('random bytes length = 100', () {
    expect(randomBytes(100).length, 100);
  });

  test('random numbers length = 0', () {
    expect(randomNumbers(0), []);
  });
  test('random numbers length = 1', () {
    expect(randomNumbers(1).length, 1);
  });
  test('random numbers length = 100', () {
    expect(randomNumbers(100).length, 100);
  });
  test('random numbers value', () {
    final result = randomNumbers(10);
    expect(result, anyElement(greaterThan(255)));
  });

  test('fill random bytes', () {
    var data = Uint8List(10);
    fillRandom(data.buffer);
    expect(data, anyElement(isNonZero));
  });

  test('fill random numbers', () {
    var data = Uint32List(10);
    fillNumbers(data);
    expect(data, anyElement(greaterThan(255)));
  });

  test('fill test random', () {
    int i, c;
    for (c = 0; c <= 100; ++c) {
      for (i = 0; i + c <= 100; ++i) {
        var data = Uint8List(100);
        testRandom.fill(data.buffer, i, c);
        int s = data.fold<int>(0, (p, e) => p + (e > 0 ? 1 : 0));
        expect(s, c, reason: 'fill($i, $c) : $data');
      }
    }
  });

  test('next between', () {
    var rand = HashlibRandom.secure();
    expect(rand.nextBetween(0, 0), 0);
    expect(rand.nextBetween(1, 1), 1);
    expect(rand.nextBetween(5, 10), lessThanOrEqualTo(10));
    expect(rand.nextBetween(10, 5), greaterThanOrEqualTo(5));
    expect(rand.nextBetween(-5, -2), lessThan(0));
    expect(rand.nextBetween(-5, -15), lessThan(0));
    for (int i = 0; i < 100; ++i) {
      expect(rand.nextBetween(0, 1), lessThanOrEqualTo(1));
      expect(rand.nextBetween(0, 3), lessThanOrEqualTo(3));
      expect(rand.nextBetween(0, 10), lessThanOrEqualTo(10));
      expect(rand.nextBetween(0, 50), lessThanOrEqualTo(50));
      expect(rand.nextBetween(0, 500), lessThanOrEqualTo(500));
      expect(rand.nextBetween(0, 85701), lessThanOrEqualTo(85701));
      expect(rand.nextBetween(1, _maxInt), greaterThanOrEqualTo(1));
      expect(rand.nextBetween(3, _maxInt), greaterThanOrEqualTo(3));
      expect(rand.nextBetween(10, _maxInt), greaterThanOrEqualTo(10));
      expect(rand.nextBetween(50, _maxInt), greaterThanOrEqualTo(50));
      expect(rand.nextBetween(500, _maxInt), greaterThanOrEqualTo(500));
      expect(rand.nextBetween(85701, _maxInt), greaterThanOrEqualTo(85701));
    }
  });

  test('random string throws StateError on empty whitelist', () {
    expect(
        () => randomString(
              50,
              whitelist: [],
            ),
        throwsStateError);
    expect(
        () => randomString(
              50,
              whitelist: [1, 2, 3],
              blacklist: [1, 2, 3],
            ),
        throwsStateError);
    expect(
        () => randomString(
              50,
              numeric: true,
              blacklist: '0123456789'.codeUnits,
            ),
        throwsStateError);
  });

  group('HashlibRandom.nextString', () {
    late HashlibRandom random;
    final _lower = 'abcdefghijklmnopqrstuvwxyz'.codeUnits;
    final _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.codeUnits;
    final _digits = '0123456789'.codeUnits;
    final _controls = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, //
      11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
      127
    ];
    final _punctuations = [
      33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, //
      58, 59, 60, 61, 62, 63, 64, 91, 92, 93, 94, 95, 96, 123, 124, 125, 126,
    ];

    setUp(() {
      // Mock generator with predictable values
      random = HashlibRandom.generator([
        65, 66, 67, 68, 69, 70, 71, 72, 73, 74, //
        75, 76, 77, 78, 79, 80, 81, 82, 83, 84
      ].iterator);
    });

    test('should return a string of correct length', () {
      final result = random.nextString(10);
      expect(result.length, equals(10));
    });

    test('should contain only ASCII characters by default', () {
      final result = random.nextString(10);
      for (int i = 0; i < result.length; i++) {
        expect(result.codeUnitAt(i), inInclusiveRange(0, 127));
      }
    });

    test('should include only lowercase characters when lower is true', () {
      final result = random.nextString(
        25,
        lower: true,
        upper: false,
        numeric: false,
        controls: false,
        punctuations: false,
      );
      expect(result.codeUnits, everyElement(isIn(_lower)));
    });

    test('should include uppercase characters when upper is true', () {
      final result = random.nextString(
        25,
        lower: false,
        upper: true,
        numeric: false,
        controls: false,
        punctuations: false,
      );
      expect(result.codeUnits, everyElement(isIn(_upper)));
    });

    test('should include numeric characters when numeric is true', () {
      final result = random.nextString(
        25,
        lower: false,
        upper: false,
        numeric: true,
        controls: false,
        punctuations: false,
      );
      expect(result.codeUnits, everyElement(isIn(_digits)));
    });

    test('should include control characters when controls is true', () {
      final result = random.nextString(
        25,
        lower: false,
        upper: false,
        numeric: false,
        controls: true,
        punctuations: false,
      );
      expect(result.codeUnits, everyElement(isIn(_controls)));
    });

    test('should include punctuation characters when punctuations is true', () {
      final result = random.nextString(
        25,
        lower: false,
        upper: false,
        numeric: false,
        controls: false,
        punctuations: true,
      );
      expect(result.codeUnits, everyElement(isIn(_punctuations)));
    });

    test('should include multiple (lower, numeric)', () {
      final result = random.nextString(
        50,
        lower: true,
        upper: false,
        numeric: true,
        controls: false,
        punctuations: false,
      );
      final matcher = [..._lower, ..._digits];
      expect(result.codeUnits, everyElement(isIn(matcher)));
    });

    test('should include multiple (upper, numeric)', () {
      final result = random.nextString(
        50,
        lower: false,
        upper: true,
        numeric: true,
        controls: false,
        punctuations: false,
      );
      final matcher = [..._upper, ..._digits];
      expect(result.codeUnits, everyElement(isIn(matcher)));
    });

    test('should include multiple (numeric, controls)', () {
      final result = random.nextString(
        50,
        lower: false,
        upper: false,
        numeric: true,
        controls: true,
        punctuations: false,
      );
      final matcher = [..._controls, ..._digits];
      expect(result.codeUnits, everyElement(isIn(matcher)));
    });

    test('should include multiple (lower, punctuations)', () {
      final result = random.nextString(
        50,
        lower: true,
        upper: false,
        numeric: false,
        controls: false,
        punctuations: true,
      );
      final matcher = [..._lower, ..._punctuations];
      expect(result.codeUnits, everyElement(isIn(matcher)));
    });

    test('should use whitelist if provided', () {
      final whitelist = [65, 66, 67]; // A, B, C
      final result = random.nextString(10, whitelist: whitelist);
      expect(result.codeUnits, everyElement(isIn(whitelist)));
    });

    test('should remove characters in blacklist', () {
      final blacklist = [65, 66, 67]; // A, B, C
      final result = random.nextString(10, blacklist: blacklist, lower: true);
      expect(result.codeUnits, isNot(anyOf(blacklist)));
    });

    test('should throw StateError if whitelist is empty', () {
      expect(() => random.nextString(10, whitelist: []),
          throwsA(isA<StateError>()));
    });

    test('should return an empty string if length is 0', () {
      final result = random.nextString(0);
      expect(result, isEmpty);
    });

    test('should return deterministic output with the same seed', () {
      final generator1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].iterator;
      final generator2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].iterator;
      final random1 = HashlibRandom.generator(generator1);
      final random2 = HashlibRandom.generator(generator2);

      final result1 = random1.nextString(10);
      final result2 = random2.nextString(10);

      expect(result1, equals(result2));
    });
  });

  group('Test \$seedList', () {
    test('Test with a normal length list', () {
      int seed = 123456789;
      var data = Uint8List(64);
      Generators.$seedList(data, seed);
      expect(data, isNot(equals(Uint8List(64))));
    });

    test('Test with small list', () {
      int seed = 123456789;
      for (int i = 1; i < 8; ++i) {
        var data = Uint8List(i);
        Generators.$seedList(data, seed);
        expect(data, isNot(equals(Uint8List(i))));
      }
    });

    test('Test with uneven list', () {
      int seed = 123456789;
      for (int i = 1; i < 4; ++i) {
        var data = Uint8List(64 + i);
        Generators.$seedList(data, seed);
        expect(data.skip(64), isNot(equals(Uint8List(i))));
      }
    });

    test('Test with same seed', () {
      int seed = 123456789;
      var data1 = Uint8List(255);
      var data2 = Uint8List(255);
      Generators.$seedList(data1, seed);
      Generators.$seedList(data2, seed);
      expect(data1, equals(data2));
    });

    test('Test with different seed', () {
      int seed1 = 123456789;
      int seed2 = 987654321;
      var data1 = Uint8List(255);
      var data2 = Uint8List(255);
      Generators.$seedList(data1, seed1);
      Generators.$seedList(data2, seed2);
      expect(data1, isNot(equals(data2)));
    });
  });
}
