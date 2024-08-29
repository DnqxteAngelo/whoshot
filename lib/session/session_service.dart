// ignore_for_file: unused_field

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _nominationStartKey = 'nomination_start_time';
  static const String _nominationEndKey = 'nomination_end_time';
  static const String _votingStartKey = 'voting_start_time';
  static const String _votingEndKey = 'voting_end_time';

  DateTime? _nominationStartTime;
  DateTime? _nominationEndTime;
  DateTime? _votingStartTime;
  DateTime? _votingEndTime;

  Future<void> saveNominationTimes(
      DateTime? startTime, DateTime? endTime) async {
    final prefs = await SharedPreferences.getInstance();
    if (startTime == null || endTime == null) {
      await prefs.remove(_nominationStartKey);
      await prefs.remove(_nominationEndKey);
    } else {
      await prefs.setString(_nominationStartKey, startTime.toIso8601String());
      await prefs.setString(_nominationEndKey, endTime.toIso8601String());
    }
    _nominationStartTime = startTime;
    _nominationEndTime = endTime;
  }

  Future<void> saveVotingTimes(DateTime? startTime, DateTime? endTime) async {
    final prefs = await SharedPreferences.getInstance();
    if (startTime == null || endTime == null) {
      await prefs.remove(_votingStartKey);
      await prefs.remove(_votingEndKey);
    } else {
      await prefs.setString(_votingStartKey, startTime.toIso8601String());
      await prefs.setString(_votingEndKey, endTime.toIso8601String());
    }
    _votingStartTime = startTime;
    _votingEndTime = endTime;
  }

  Future<Map<String, DateTime?>> loadNominationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString(_nominationStartKey);
    final endTimeString = prefs.getString(_nominationEndKey);

    return {
      'start': startTimeString != null ? DateTime.parse(startTimeString) : null,
      'end': endTimeString != null ? DateTime.parse(endTimeString) : null,
    };
  }

  Future<Map<String, DateTime?>> loadVotingTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString(_votingStartKey);
    final endTimeString = prefs.getString(_votingEndKey);

    return {
      'start': startTimeString != null ? DateTime.parse(startTimeString) : null,
      'end': endTimeString != null ? DateTime.parse(endTimeString) : null,
    };
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
