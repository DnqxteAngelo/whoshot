// ignore_for_file: prefer_const_constructors, unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:whoshot/session/session_service.dart';
import 'dart:async';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final SessionService _sessionService = SessionService();
  DateTime? _nominationStartTime;
  DateTime? _nominationEndTime;
  DateTime? _votingStartTime;
  DateTime? _votingEndTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadNominationTimes();
    _loadVotingTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNominationTimes() async {
    final times = await _sessionService.loadNominationTimes();
    setState(() {
      _nominationStartTime = times['start'];
      _nominationEndTime = times['end'];
    });
  }

  Future<void> _loadVotingTimes() async {
    final times = await _sessionService.loadVotingTimes();
    setState(() {
      _votingStartTime = times['start'];
      _votingEndTime = times['end'];
    });
  }

  Future<void> _startNominationSession() async {
    final now = DateTime.now();
    final endTime = now.add(Duration(minutes: 1));
    await _sessionService.saveNominationTimes(now, endTime);
    setState(() {
      _nominationStartTime = now;
      _nominationEndTime = endTime;
    });
    _startTimer();
  }

  Future<void> _startVotingSession() async {
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: 10));
    await _sessionService.saveVotingTimes(now, endTime);
    setState(() {
      _votingStartTime = now;
      _votingEndTime = endTime;
    });
    _startTimer();
  }

  // Future<void> _endNominationSessionAndStartVoting() async {
  //   await _endNominationSession();
  //   _startVotingSession();
  // }

  Future<void> _endNominationSession() async {
    await _sessionService.saveNominationTimes(null, null);
    setState(() {
      _nominationStartTime = null;
      _nominationEndTime = null;
    });
  }

  Future<void> _endVotingSession() async {
    await _sessionService.saveVotingTimes(null, null);
    setState(() {
      _votingStartTime = null;
      _votingEndTime = null;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        // If the widget is not mounted, stop the timer.
        _timer?.cancel();
        return;
      }

      // if (_nominationEndTime != null &&
      //     DateTime.now().isAfter(_nominationEndTime!) &&
      //     _votingStartTime == null) {
      //   _endNominationSessionAndStartVoting();
      // }

      if ((_nominationEndTime == null ||
              DateTime.now().isAfter(_nominationEndTime!)) &&
          (_votingEndTime == null || DateTime.now().isAfter(_votingEndTime!))) {
        timer.cancel();
      }

      setState(() {});
    });
  }

  String _getNominationRemainingTime() {
    if (_nominationEndTime == null) return "No Session";

    final now = DateTime.now();
    final difference = _nominationEndTime!.difference(now);

    if (difference.isNegative) return "Session Ended";

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getVotingRemainingTime() {
    if (_votingEndTime == null) return "No Session";

    final now = DateTime.now();
    final difference = _votingEndTime!.difference(now);

    if (difference.isNegative) return "Session Ended";

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Nomination Time Remaining: ${_getNominationRemainingTime()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startNominationSession,
              child: Text('Start Nomination Session'),
            ),
            ElevatedButton(
              onPressed: _endNominationSession,
              child: Text('End Nomination Session'),
            ),
            SizedBox(height: 20),
            Text(
              'Voting Time Remaining: ${_getVotingRemainingTime()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startVotingSession,
              child: Text('Start Voting Session'),
            ),
            ElevatedButton(
              onPressed: _endVotingSession,
              child: Text('End Voting Session'),
            ),
          ],
        ),
      ),
    );
  }
}
