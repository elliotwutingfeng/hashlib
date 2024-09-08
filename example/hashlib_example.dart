import 'package:hashlib/hashlib.dart';
import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var text = "Happy Hashing!";
  var key = "password";
  var pw = key.codeUnits;
  var iv = "some salt".codeUnits;
  print("text => $text");
  print("key => $key");
  print("salt => ${toHex(iv)}");
  print('');

  // Example of hash code generations
  print('XXH32 => ${xxh32code(text)}');
  print('CRC32 => ${crc32code(text)}');
  print('Alder32 => ${alder32code(text)}');
  print('CRC16 => ${crc16code(text)}');
  print('');

  // Examples of Hash generation
  print('CRC64 => ${crc64sum(text)}');
  print('XXH64 => ${xxh64sum(text)}');
  print('XXH3 => ${xxh3sum(text)}');
  print('XXH128 => ${xxh128sum(text)}');
  print('MD4 => ${md4.string(text)}');
  print('MD5 => ${md5.string(text)}');
  print('SHA-1 => ${sha1.string(text)}');
  print('SHA-224 => ${sha224.string(text)}');
  print('SHA-256 => ${sha256.string(text)}');
  print('SHA-384 => ${sha384.string(text)}');
  print('SHA-512 => ${sha512.string(text)}');
  print('SHA-512/224 => ${sha512t224.string(text)}');
  print('SHA-512/256 => ${sha512t256.string(text)}');
  print('SHA3-224 => ${sha3_224.string(text)}');
  print('SHA3-256 => ${sha3_256.string(text)}');
  print('SHA3-384 => ${sha3_384.string(text)}');
  print('SHA3-512 => ${sha3_512.string(text)}');
  print('Keccak-224 => ${keccak224.string(text)}');
  print('Keccak-256 => ${keccak256.string(text)}');
  print('Keccak-384 => ${keccak384.string(text)}');
  print('Keccak-512 => ${keccak512.string(text)}');
  print('SHAKE-128 => ${shake128.of(20).string(text)}');
  print('SHAKE-256 => ${shake256.of(20).string(text)}');
  print('BLAKE-2s/256 => ${blake2s256.string(text)}');
  print('BLAKE-2b/512 => ${blake2b512.string(text)}');
  print('SM3] => ${sm3.string(text)}');
  print('');

  // Examples of MAC generations
  print('HMAC/MD5 => ${md5.hmac.by(pw).string(text)}');
  print('HMAC/SHA1 => ${sha1.hmac.byString(text)}');
  print('HMAC/SHA256 => ${sha256.hmac.byString(key).string(text)}');
  print('HMAC/SHA3-256 => ${HMAC(sha3_256).by(pw).string(text)}');
  print("HMAC/BLAKE-2b/256 => ${blake2b512.hmac.by(pw).string(text)}");
  print("BLAKE-2b-MAC/256 => ${blake2b256.mac.by(pw).string(text)}");
  print("BLAKE-2b-MAC/224 => ${Blake2b(28).mac.by(pw).string(text)}");
  print('');

  // Examples of PBKDF2 key derivation
  print("SHA256/HMAC/PBKDF2 => ${pbkdf2(pw, iv, 100).hex()}");
  print("SHA1/HMAC/PBKDF2 => ${sha1.pbkdf2(iv, 100).hex(pw)}");
  print("BLAKE-2b/256/HMAC/PBKDF2 => ${blake2b256.pbkdf2(iv, 100).hex(pw)}");
  print("BLAKE-2b/256/MAC/PBKDF2 => ${blake2b256.mac.pbkdf2(iv, 100).hex(pw)}");
  print('');

  // Examples of OTP generation
  int nw = DateTime.now().millisecondsSinceEpoch ~/ 30000;
  var counter = fromHex(nw.toRadixString(16).padLeft(16, '0'));
  print('TOTP[time=$nw] => ${TOTP(iv).value()}');
  print('HOTP[counter=$nw] => ${HOTP(iv, counter: counter).value()}');
  print('');

  // Examples of Argon2 key derivation
  var argon2Test = Argon2Security.test;
  print("[Argon2i] => ${argon2i(pw, iv, security: argon2Test)}");
  print("[Argon2d] => ${argon2d(pw, iv, security: argon2Test)}");
  print("[Argon2id] => ${argon2id(pw, iv, security: argon2Test)}");

  // Examples of scrypt key derivation
  var scryptLittle = ScryptSecurity.little;
  print("[scrypt] => ${scrypt(pw, iv, security: scryptLittle, dklen: 24)}");
  print('');

  // Examples of bcrypt key derivation
  var bcryptLittle = BcryptSecurity.little;
  print("[bcrypt] => ${bcrypt(pw, bcryptSalt(security: bcryptLittle))}");
  print('');
}
