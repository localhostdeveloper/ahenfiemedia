import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/presenter.dart';
import '../services/presenter_service.dart';

final presentersProvider = FutureProvider<List<Presenter>>(
  (_) => PresenterService.fetchPresenters(),
);
