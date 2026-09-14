import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/program.dart';

class TVEPGService {
  static Future<List<Program>> fetchPrograms() async {
    final rows = await Supabase.instance.client
        .from('tv_epg')
        .select()
        .order('display_order');
    return (rows as List)
        .map((r) => Program.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }
}
