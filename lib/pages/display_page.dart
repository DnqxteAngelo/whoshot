// ignore_for_file: prefer_const_constructors, avoid_print, library_private_types_in_public_api, unused_import, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:marqueer/marqueer.dart';
import 'package:http/http.dart' as http;
import 'package:whoshot/models/nominees.dart';
import 'package:whoshot/session/session_service.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({Key? key}) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  final MarqueerController _controller = MarqueerController();
  final SessionService _sessionService = SessionService();
  List<Nominees> nominees = [];
  List<Nominees> maleNominees = [];
  List<Nominees> femaleNominees = [];
  DateTime? _votingEndTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchNominees();
    _loadVotingTimes();
    _getVotingRemainingTime();
    _startTimer();
  }

  Future<void> _loadVotingTimes() async {
    final times = await _sessionService.loadVotingTimes();
    setState(() {
      _votingEndTime = times['end'];
    });
  }

  String _getVotingRemainingTime() {
    if (_votingEndTime == null) return "No Session";
    final now = DateTime.now();
    final difference = _votingEndTime!.difference(now);

    if (difference.isNegative) return "Ended";

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {});
      if (_getVotingRemainingTime() == "Ended") {
        _timer?.cancel();
        _showWinnersDialog();
      }
    });
  }

  Future<void> fetchNominees() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/nominee.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getNominees'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final now = DateTime.now();
          final oneHourAgo = now.subtract(Duration(hours: 1));
          setState(() {
            nominees = (data['data'] as List)
                .map((json) => Nominees.fromJson(json))
                .where((nominee) =>
                    nominee.time != null && nominee.time!.isAfter(oneHourAgo))
                .toList();
            maleNominees =
                nominees.where((nominee) => nominee.gender == 'Male').toList();
            femaleNominees = nominees
                .where((nominee) => nominee.gender == 'Female')
                .toList();
          });
        } else {
          print('Error fetching nominees: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showWinnersDialog() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/results.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getAndAddWinners'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final maleWinner = data['male']['nomination_name'];
          final maleVotes = data['male']['total_votes'];
          final maleImageUrl = data['male']['nomination_imageUrl'];
          final femaleWinner = data['female']['nomination_name'];
          final femaleVotes = data['female']['total_votes'];
          final femaleImageUrl = data['female']['nomination_imageUrl'];

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade400, Colors.green.shade800],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voting Session Ended',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'The winners are:',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildWinnerCard(
                              maleImageUrl, maleWinner, maleVotes, 'Male'),
                          _buildWinnerCard(femaleImageUrl, femaleWinner,
                              femaleVotes, 'Female'),
                        ],
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        child: Text(
                          'OK',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade800,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          print('Error getting winners: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _buildWinnerCard(
      String imageUrl, String name, int votes, String category) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green.shade100],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                  'http://localhost/whoshot/lib/api/images/$imageUrl'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            Text(
              category,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Votes: $votes',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade600,
                  Colors.green.shade400,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(constraints.maxWidth * 0.02),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        'Time Remaining: ${_getVotingRemainingTime()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: constraints.maxWidth * 0.02,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "CITE Spotlight",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.04,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Who got the best face?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.025,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Text(
                    "Male Nominees",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  Expanded(
                    child: Marqueer.builder(
                      pps: 30,
                      controller: _controller,
                      direction: MarqueerDirection.rtl,
                      autoStartAfter: const Duration(seconds: 2),
                      itemCount: maleNominees.length,
                      itemBuilder: (context, index) {
                        final nominee = maleNominees[index];
                        return _buildNomineeCard(nominee, constraints);
                      },
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Text(
                    "Female Nominees",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: constraints.maxWidth * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.01),
                  Expanded(
                    child: Marqueer.builder(
                      pps: 30,
                      controller: _controller,
                      direction: MarqueerDirection.ltr,
                      autoStartAfter: const Duration(seconds: 2),
                      itemCount: femaleNominees.length,
                      itemBuilder: (context, index) {
                        final nominee = femaleNominees[index];
                        return _buildNomineeCard(nominee, constraints);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNomineeCard(Nominees nominee, BoxConstraints constraints) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.01),
      width: constraints.maxWidth * 0.15,
      height: constraints.maxHeight * 0.25,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  nominee.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(constraints.maxWidth * 0.01),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  nominee.name!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: constraints.maxWidth * 0.012,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
