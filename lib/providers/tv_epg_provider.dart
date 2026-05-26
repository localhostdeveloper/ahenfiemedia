import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/program.dart';
import '../services/tv_epg_service.dart';

final tvEPGProvider =
    FutureProvider<List<Program>>(
  (ref) async {
    return TVEPGService.fetchPrograms();
  },
);