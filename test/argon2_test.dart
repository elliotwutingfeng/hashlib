import 'package:hashlib/src/algorithms/argon2.dart';
import 'package:test/test.dart';

/// Test cases generated by https://argon2.online/

void main() {
  group('Argon2 v19 test', () {
    test("argon2i m=16, t=2, p=1 @ out = 16", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2i,
        hashLength: 16,
        iterations: 2,
        parallelism: 1,
        memorySizeKB: 16,
        salt: "some salt".codeUnits,
      );
      final matcher = "bb5794ea66451b8fce3a84dd02d33949";
      final encoded =
          r"$argon2i$v=19$m=16,t=2,p=1$c29tZSBzYWx0$u1eU6mZFG4/OOoTdAtM5SQ";
      var result = argon2.convert('password'.codeUnits);
      expect(result.hex(), matcher);
      expect(result.encoded(), encoded);
    });
    test("argon2d m=16, t=2, p=1 @ out = 16", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2d,
        hashLength: 16,
        iterations: 2,
        parallelism: 1,
        memorySizeKB: 16,
        salt: "some salt".codeUnits,
      );
      final matcher = "cf916880b91ba8a1390fff6b624baa27";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });
    test("argon2id m=16, t=2, p=1 @ out = 16", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2id,
        hashLength: 16,
        iterations: 2,
        parallelism: 1,
        memorySizeKB: 16,
        salt: "some salt".codeUnits,
      );
      final matcher = "88c91661b3cea3c3853593608881f324";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });

    test("argon2i m=256, t=8, p=4 @ out = 32", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2i,
        hashLength: 32,
        iterations: 8,
        parallelism: 4,
        memorySizeKB: 256,
        salt: "some salt".codeUnits,
      );
      final matcher =
          "41e318e5092fbb0d6448a833defb795e334667a6fe8343958d7751bba2a0ea81";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });
    test("argon2d m=256, t=8, p=4 @ out = 32", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2d,
        hashLength: 32,
        iterations: 8,
        parallelism: 4,
        memorySizeKB: 256,
        salt: "some salt".codeUnits,
      );
      final matcher =
          "19ccf89f9cc83070d5a734fe5b2ae5e25ebaed4f5a30cf6a03457d3ebf35cb3d";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });
    test("argon2id m=256, t=8, p=4 @ out = 32", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2id,
        hashLength: 32,
        iterations: 8,
        parallelism: 4,
        memorySizeKB: 256,
        salt: "some salt".codeUnits,
      );
      final matcher =
          "262ff20a2bd40ad56d91199a704c03ba68cdf506edf7afebabfe2a200044b1e5";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });

    test("encoded hash instance check", () {
      final encoded =
          r"$argon2i$v=19$m=128,t=4,p=2$c29tZSBzYWx0$/UTBaG/OPVS53KFzcpJt9ujnXFMahdK/";
      final matcher = "fd44c1686fce3d54b9dca17372926df6e8e75c531a85d2bf";
      final argon2 = Argon2.fromEncoded(encoded);
      expect(argon2.type, Argon2Type.argon2i);
      expect(argon2.version, Argon2Version.v13);
      expect(argon2.memorySizeKB, 128);
      expect(argon2.lanes, 2);
      expect(argon2.passes, 4);
      expect(argon2.hashLength, 24);
      expect(argon2.salt, "some salt".codeUnits);
      var result = argon2.convert("password".codeUnits);
      expect(result.hex(), matcher);
      expect(result.encoded(), encoded);
    });

    test("multiple call with same instance", () {
      final argon2 = Argon2(
        version: Argon2Version.v13,
        type: Argon2Type.argon2i,
        hashLength: 16,
        iterations: 2,
        parallelism: 1,
        memorySizeKB: 16,
        salt: "some salt".codeUnits,
      );
      final matcher = "bb5794ea66451b8fce3a84dd02d33949";
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
      expect(argon2.convert('password'.codeUnits).hex(), matcher);
    });
  });
}
