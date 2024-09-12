// ignore_for_file: avoid_print, prefer_const_constructors, unused_field, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:whoshot/models/session.dart';
import 'package:whoshot/pages/display_page.dart';
import 'package:whoshot/session/session_service.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  final int userId;

  AdminPage({
    required this.userId,
  });

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final SessionService _sessionService = SessionService();
  List<Session> sessions = [];
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _startNominationSession() async {
    final now = DateTime.now();
    final endTime = now.add(Duration(minutes: 1));
    Map<String, dynamic> data = {
      'nomination_start': now.toIso8601String(),
      'nomination_end': endTime.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/session.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'nominationSession',
          'json': jsonEncode(data),
        },
      );
      print('Server response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // await _sessionService.saveNominationTimes(now, endTime);
          setState(() {
            _nominationStartTime = now;
            _nominationEndTime = endTime;
          });
          _startTimer();
        } else {
          _showErrorSnackBar(
              responseData['message'] ?? 'Failed to start session.');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print(e);
    }
  }

  Future<void> _startVotingSession() async {
    final now = DateTime.now();
    final endTime = now.add(Duration(minutes: 5));
    Map<String, dynamic> data = {
      'voting_start': now.toIso8601String(),
      'voting_end': endTime.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/session.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'votingSession',
          'json': jsonEncode(data),
        },
      );
      print('Server response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // await _sessionService.saveVotingTimes(now, endTime);
          setState(() {
            _votingStartTime = now;
            _votingEndTime = endTime;
          });
          _startTimer();
        } else {
          _showErrorSnackBar(
              responseData['message'] ?? 'Failed to start session.');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print(e);
    }
  }

  Future<void> _endNominationSession() async {
    Map<String, dynamic> data = {
      'nomination_start': null,
      'nomination_end': null,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/session.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'nominationSession',
          'json': jsonEncode(data),
        },
      );
      print('Server response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // await _sessionService.saveNominationTimes(null, null);
          setState(() {
            _nominationStartTime = null;
            _nominationEndTime = null;
          });
          _startTimer();
        } else {
          _showErrorSnackBar(
              responseData['message'] ?? 'Failed to start session.');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print(e);
    }
  }

  Future<void> _endVotingSession() async {
    Map<String, dynamic> data = {
      'voting_start': null,
      'voting_end': null,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/session.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'votingSession',
          'json': jsonEncode(data),
        },
      );
      print('Server response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // await _sessionService.saveVotingTimes(null, null);
          setState(() {
            _votingStartTime = null;
            _votingEndTime = null;
          });
          _startTimer();
        } else {
          _showErrorSnackBar(
              responseData['message'] ?? 'Failed to start session.');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
      print(e);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }

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

    if (difference.isNegative) {
      _endNominationSession();
      return "Session Ended";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getVotingRemainingTime() {
    if (_votingEndTime == null) return "No Session";

    final now = DateTime.now();
    final difference = _votingEndTime!.difference(now);

    if (difference.isNegative) {
      _endVotingSession();
      return "Session Ended";
    }

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
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Admin Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade600,
              Colors.green.shade400,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nomination Time Remaining: ${_getNominationRemainingTime()}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _startNominationSession,
                child: Text('Start Nomination Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _endNominationSession,
                child: Text('End Nomination Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Voting Time Remaining: ${_getVotingRemainingTime()}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _startVotingSession,
                child: Text('Start Voting Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _endVotingSession,
                child: Text('End Voting Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisplayPage()),
                  );
                },
                child: Text('Nominees Display'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
