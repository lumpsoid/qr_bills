import 'dart:math';

const String symbols =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

String generateRandomPart(int length) {
  final Random random = Random.secure();

  return List.generate(
      length, (index) => symbols[random.nextInt(symbols.length)]).join();
}

String generateRandomForm() {
  final String part1 = generateRandomPart(5);
  final String part2 = generateRandomPart(5);

  return '$part1-$part2';
}
