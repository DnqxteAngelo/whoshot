// ignore_for_file: unused_field

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SessionService {
  static const String _nominationStartKey = 'nomination_start_time';
  static const String _nominationEndKey = 'nomination_end_time';
  static const String _votingStartKey = 'voting_start_time';
  static const String _votingEndKey = 'voting_end_time';

  DateTime? _nominationStartTime;
  DateTime? _nominationEndTime;
  DateTime? _votingStartTime;
  DateTime? _votingEndTime;

  // Future<void> saveNominationTimes(
  //     DateTime? startTime, DateTime? endTime) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (startTime == null || endTime == null) {
  //     await prefs.remove(_nominationStartKey);
  //     await prefs.remove(_nominationEndKey);
  //   } else {
  //     await prefs.setString(_nominationStartKey, startTime.toIso8601String());
  //     await prefs.setString(_nominationEndKey, endTime.toIso8601String());
  //   }
  //   _nominationStartTime = startTime;
  //   _nominationEndTime = endTime;
  // }

  // Future<void> saveVotingTimes(DateTime? startTime, DateTime? endTime) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (startTime == null || endTime == null) {
  //     await prefs.remove(_votingStartKey);
  //     await prefs.remove(_votingEndKey);
  //   } else {
  //     await prefs.setString(_votingStartKey, startTime.toIso8601String());
  //     await prefs.setString(_votingEndKey, endTime.toIso8601String());
  //   }
  //   _votingStartTime = startTime;
  //   _votingEndTime = endTime;
  // }

  Future<Map<String, DateTime?>> loadNominationTimes() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/session.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getNominationSession'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> sessionsData = data['data'];
          if (sessionsData.isNotEmpty) {
            final Map<String, dynamic> sessionData = sessionsData[0];
            return {
              'start': DateTime.parse(sessionData['nomination_start']),
              'end': DateTime.parse(sessionData['nomination_end']),
            };
          }
        }
      }
      return {'start': null, 'end': null};
    } catch (e) {
      print('Error: $e');
      return {'start': null, 'end': null};
    }
  }

  Future<Map<String, DateTime?>> loadVotingTimes() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/session.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getVotingSession'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> sessionsData = data['data'];
          if (sessionsData.isNotEmpty) {
            final Map<String, dynamic> sessionData = sessionsData[0];
            return {
              'start': DateTime.parse(sessionData['voting_start']),
              'end': DateTime.parse(sessionData['voting_end']),
            };
          }
        }
      }
      return {'start': null, 'end': null};
    } catch (e) {
      print('Error: $e');
      return {'start': null, 'end': null};
    }
  }

  Future<bool> isWithinNominationSession() async {
    final times = await loadNominationTimes();
    final now = DateTime.now();
    final start = times['start'];
    final end = times['end'];
    return start != null &&
        end != null &&
        now.isAfter(start) &&
        now.isBefore(end);
  }

  Future<bool> isWithinVotingSession() async {
    final times = await loadVotingTimes();
    final now = DateTime.now();
    final start = times['start'];
    final end = times['end'];
    return start != null &&
        end != null &&
        now.isAfter(start) &&
        now.isBefore(end);
  }
}
