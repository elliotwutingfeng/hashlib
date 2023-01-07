// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib/src/core/hash_digest.dart';
import 'package:hashlib/src/core/hash_sink.dart';

const int _mask32 = 0xFFFFFFFF;

class SHA224Sink extends _SHA2of32bit {
  SHA224Sink([Sink<HashDigest>? sink])
      : super(
          sink: sink,
          hashLengthInBits: 224,
          seed: [
            0xC1059ED8, // a
            0x367CD507, // b
            0x3070DD17, // c
            0xF70E5939, // d
            0xFFC00B31, // e
            0x68581511, // f
            0x64F98FA7, // g
            0xBEFA4FA4, // h
          ],
        );
}

class SHA256Sink extends _SHA2of32bit {
  SHA256Sink([Sink<HashDigest>? sink])
      : super(
          sink: sink,
          hashLengthInBits: 256,
          seed: [
            0x6A09E667, // a
            0xBB67AE85, // b
            0x3C6EF372, // c
            0xA54FF53A, // d
            0x510E527F, // e
            0x9B05688C, // f
            0x1F83D9AB, // g
            0x5BE0CD19, // h
          ],
        );
}

// Initialize array of round constants
const List<int> _k = [
  0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, //
  0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
  0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
  0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
  0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC,
  0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
  0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7,
  0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
  0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
  0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
  0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
  0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
  0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5,
  0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
  0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
  0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
];

/// The implementation is derived from the US Secure Hash Algorithms document
/// of [SHA and SHA-based HMAC and HKDF][rfc6234].
///
/// [rfc6234]: https://datatracker.ietf.org/doc/html/rfc6234
abstract class _SHA2of32bit extends HashSink {
  /// For internal use only.
  _SHA2of32bit({
    Sink<HashDigest>? sink,
    required List<int> seed,
    required int hashLengthInBits,
  }) : super(
          sink: sink,
          seed: seed,
          blockLengthInBits: 512,
          extendedChunkLength: 64,
          hashLengthInBits: hashLengthInBits,
        );

  /// Rotates x right by n bits.
  int _rotr(int x, int n) =>
      ((x & _mask32) >>> n) | ((x << (32 - n)) & _mask32);

  int _bsig0(int x) => (_rotr(x, 2) ^ _rotr(x, 13) ^ _rotr(x, 22));

  int _bsig1(int x) => (_rotr(x, 6) ^ _rotr(x, 11) ^ _rotr(x, 25));

  int _ssig0(int x) => (_rotr(x, 7) ^ _rotr(x, 18) ^ (x >>> 3));

  int _ssig1(int x) => (_rotr(x, 17) ^ _rotr(x, 19) ^ (x >>> 10));

  @override
  void update(Uint32List block) {
    var w = block;
    var a = state[0];
    var b = state[1];
    var c = state[2];
    var d = state[3];
    var e = state[4];
    var f = state[5];
    var g = state[6];
    var h = state[7];

    // Extend the first 16 words into the remaining 48 words
    for (int i = 16; i < 64; i++) {
      w[i] = _ssig1(w[i - 2]) + w[i - 7] + _ssig0(w[i - 15]) + w[i - 16];
    }

    for (int i = 0; i < 64; ++i) {
      var ch = (e & f) ^ ((~e) & g);
      var t1 = h + _bsig1(e) + ch + _k[i] + w[i];
      var t2 = _bsig0(a) + ((a & b) ^ (a & c) ^ (b & c));

      h = g;
      g = f;
      f = e;
      e = (d + t1) & _mask32;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & _mask32;
    }

    state[0] += a;
    state[1] += b;
    state[2] += c;
    state[3] += d;
    state[4] += e;
    state[5] += f;
    state[6] += g;
    state[7] += h;
  }
}
