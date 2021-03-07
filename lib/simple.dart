import 'dart:math';

class Simple {
  static const _idLetters = "0123456789abcdef";

  static String id([int len = 8]) {
    final random = Random.secure();
    final values = List<String>.generate(len, (i) {
      final inx = random.nextInt(_idLetters.length);
      return _idLetters[inx];
    });

    return values.join("");
  }
}
