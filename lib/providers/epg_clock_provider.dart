import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final epgClockProvider =
    StreamProvider<DateTime>((ref) {

  return Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  );
});