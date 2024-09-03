// ignore_for_file: prefer_const_constructors, avoid_print, sort_child_properties_last

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whoshot/models/votes.dart';
import 'package:whoshot/session/session_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RankingPage extends StatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final SessionService _sessionService = SessionService();
  List<Votes> votes = [];

  Timer? _timer;
  DateTime? _votingEndTime;

  @override
  void initState() {
    super.initState();
    _loadVotingTimes();
    _getVotingRemainingTime();
    _startTimer();
    fetchVotes();
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
        getAndAddWinners(); // Call the function when voting ends
      }
    });
  }

  Future<void> fetchVotes() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/vote.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getRankings'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final now = DateTime.now();
          final oneHourAgo = now.subtract(Duration(hours: 1));
          setState(() {
            votes = (data['data'] as List)
                .map((json) => Votes.fromJson(json))
                .where((vote) =>
                    vote.time != null && vote.time!.isAfter(oneHourAgo))
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

  Future<void> getAndAddWinners() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/results.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getAndAddWinners'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Extract the male and female winner information correctly
          final maleWinner = data['male']['nomination_name'];
          final maleVotes = data['male']['total_votes'];
          final femaleWinner = data['female']['nomination_name'];
          final femaleVotes = data['male']['total_votes'];

          // Show a dialog with the winners
          _showWinnersDialog(maleWinner, femaleWinner, maleVotes, femaleVotes);
        } else {
          print('Error adding winners to results: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showWinnersDialog(
      String maleWinner, String femaleWinner, int maleVotes, int femaleVotes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Winners Announced!'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hottest Male: $maleWinner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Votes: $maleVotes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                'Hottest Female: $femaleWinner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Votes: $femaleVotes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Votes> _filterVotesByGender(String gender) {
    return votes
        .where((vote) => vote.gender?.toLowerCase() == gender.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.green.shade400,
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _rankingListView("Current Hottest Male Rankings", "male"),
                  _rankingListView("Current Hottest Female Rankings", "female"),
                ],
              ),
            ),
            FadeInUp(
              duration: Duration(milliseconds: 1000),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: const TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  dividerColor: null,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.person,
                      ),
                      text: "Male",
                    ),
                    Tab(
                      icon: Icon(
                        Icons.person_3,
                      ),
                      text: "Female",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _rankingListView(String title, String gender) {
    final filteredVotes = _filterVotesByGender(gender);
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 20.0,
              right: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeInRight(
                  duration: Duration(milliseconds: 1000),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
                FadeInRight(
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    'Time Remaining: ${_getVotingRemainingTime()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FadeInLeft(
            duration: Duration(milliseconds: 1000),
            child: Text(
              "CITE Spotlight",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          FadeInLeft(
            duration: Duration(milliseconds: 1100),
            child: Text(
              "Who got the best face?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          SizedBox(height: 25),
          FadeInLeft(
            duration: Duration(milliseconds: 1200),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVotes.length,
              itemBuilder: (context, index) {
                final vote = filteredVotes[index];
                final place = index + 1; // 1-based index for ranking

                Widget? rankingIcon;
                if (place == 1) {
                  rankingIcon = Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.crown, // Gold crown icon
                        color: Colors.amber,
                        size: 40,
                      ),
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Text(
                          '$place',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (place == 2) {
                  rankingIcon = Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.crown, // Silver crown icon
                        color: Colors.grey,
                        size: 40,
                      ),
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Text(
                          '$place',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (place == 3) {
                  rankingIcon = Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.crown, // Bronze crown icon
                        color: Colors.brown,
                        size: 40,
                      ),
                      Positioned(
                        top: 18,
                        left: 18,
                        child: Text(
                          '$place',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  rankingIcon = null; // No icon for places greater than 3
                }
                return FadeInUp(
                  duration: Duration(
                      milliseconds:
                          500 + (index * 100)), // Delay each item slightly
                  child: Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
                    // elevation: 8.0, // Add shadow for better appearance
                    child: Container(
                      height: 120, // Adjust height of the Card
                      padding:
                          EdgeInsets.all(8.0), // Add padding inside the Card
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: vote.imageUrl != null
                                ? NetworkImage(vote.imageUrl!)
                                : null, // Use network image if available
                            radius: 40, // Size of the avatar
                          ),
                          SizedBox(width: 30), // Space between avatar and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  vote.name ?? '',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Votes: ${vote.totalVotes}'),
                              ],
                            ),
                          ),
                          if (rankingIcon != null) rankingIcon,
                          SizedBox(width: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
