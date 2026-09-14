import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/program.dart';

class RadioScheduleService {
  static Stream<List<Program>> stream() => Supabase.instance.client
      .from('radio_schedule')
      .stream(primaryKey: ['id'])
      .order('display_order')
      .map((rows) => rows.map((r) => Program.fromSupabase(r)).toList());
}
