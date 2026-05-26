import 'package:http/http.dart'
    as http;
import 'package:csv/csv.dart';

import '../constants/app_constants.dart';

import '../models/program.dart';

class TVEPGService {

  static Future<List<Program>>
      fetchPrograms() async {

    try {

      // =========================
      // FETCH CSV
      // =========================

      final response =
          await http.get(
        Uri.parse(
          AppConstants.tvEPGUrl,
        ),
      );

      if (response.statusCode !=
          200) {
        throw Exception(
          'Failed to load CSV',
        );
      }

      // =========================
      // CONVERT CSV
      // =========================

      final csvData =
      const CsvDecoder().convert(
        response.body,
      );

      if (csvData.isEmpty) {
        return [];
      }

      // =========================
      // HEADERS
      // =========================

      final headers = csvData
          .first
          .map(
            (e) => e
                .toString()
                .trim(),
          )
          .toList();

      // =========================
      // ROWS
      // =========================

      final List<Program>
          programs = [];

      for (
        int i = 1;
        i < csvData.length;
        i++
      ) {

        final row = csvData[i];

        final Map<String, dynamic>
            data = {};

        for (
          int j = 0;
          j < headers.length;
          j++
        ) {

          data[headers[j]] =
              row.length > j
                  ? row[j]
                      .toString()
                  : '';
        }

        programs.add(
          Program.fromCSV(data),
        );
      }

      return programs;

    } catch (e) {

      throw Exception(
        'Failed to parse TV EPG',
      );
    }
  }
}