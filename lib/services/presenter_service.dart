import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/presenter.dart';

class PresenterService {
  static Future<List<Presenter>> fetchPresenters() async {
    final rows = await Supabase.instance.client
        .from('presenters')
        .select()
        .order('display_order', ascending: true);
    return (rows as List)
        .map((row) => Presenter.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
