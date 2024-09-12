// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:whoshot/pages/ranking_page.dart';
import 'package:whoshot/pages/upload_page.dart';
import 'package:whoshot/pages/vote_page.dart';
import 'package:whoshot/pages/winners_page.dart';
import 'package:whoshot/session/session_service.dart';

class LandingPage extends StatefulWidget {
  final int userId;

  LandingPage({
    required this.userId,
  });

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final SessionService _sessionService = SessionService();
  // final AdminPage _adminPage = AdminPage();
  bool _isNominationSessionActive = false;
  bool _isVotingSessionActive = false;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
  }

  Future<void> _checkSessionStatus() async {
    final isNominationActive =
        await _sessionService.isWithinNominationSession();
    final isVotingActive = await _sessionService.isWithinVotingSession();
    setState(() {
      _isNominationSessionActive = isNominationActive;
      _isVotingSessionActive = isVotingActive;
    });
    print('Nomination is ${isNominationActive ? 'active' : 'inactive'}');
    print('Voting is ${isVotingActive ? 'active' : 'inactive'}');
  }

  Future<void> _handleNominateButtonPressed() async {
    await _checkSessionStatus();

    if (_isNominationSessionActive) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "The nomination hasn't started or the nomination has ended."),
        ),
      );
    }
  }

  Future<void> _handleVoteButtonPressed() async {
    await _checkSessionStatus();

    if (_isVotingSessionActive) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VotePage(userId: widget.userId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("The voting hasn't started or the voting has ended."),
        ),
      );
    }
  }

  Future<void> _handleRankingButtonPressed() async {
    await _checkSessionStatus();

    if (_isVotingSessionActive) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RankingPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "The ranking page is only available during voting sessions."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize =
        screenSize.width * 0.4; // Adjust button size based on screen width
    final buttonPadding = screenSize.width * 0.03;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade600,
              Colors.green.shade400
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: screenSize.height * 0.1, // Adjust based on screen height
            ),
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: Column(
                children: [
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonPadding,
                      ), // Add padding if you want space between the text and the border
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 4, // Border width
                        ),
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Optional: Rounded corners
                      ),
                      child: Text(
                        "C I T E",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1100),
                    child: Text(
                      "Spotlight",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FadeInLeft(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Who got the best face?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FadeInUp(
                duration: Duration(milliseconds: 1300),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(buttonPadding),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30, // Adjust spacing based on screen height
                        ),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          shrinkWrap: true,
                          children: [
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Padding(
                                padding: EdgeInsets.all(buttonPadding),
                                child: OutlinedButton(
                                  onPressed: _handleNominateButtonPressed,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        width: 4.0,
                                        color: Colors.green.shade600),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    minimumSize: Size(buttonSize, buttonSize),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_alt,
                                          color: Colors.green.shade600,
                                          size: screenSize.width * 0.12,
                                        ),
                                        Text(
                                          "Nominate",
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Padding(
                                padding: EdgeInsets.all(buttonPadding),
                                child: ElevatedButton(
                                  onPressed: _handleVoteButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    // side: BorderSide(
                                    //     width: 4.0, color: Colors.green.shade600),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    minimumSize: Size(buttonSize, buttonSize),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color: Colors.white,
                                          size: screenSize.width * 0.12,
                                        ),
                                        Text(
                                          "Vote",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Padding(
                                padding: EdgeInsets.all(buttonPadding),
                                child: ElevatedButton(
                                  onPressed: _handleRankingButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    // side: BorderSide(
                                    //     width: 4.0, color: Colors.green.shade600),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    minimumSize: Size(buttonSize, buttonSize),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.leaderboard,
                                          color: Colors.white,
                                          size: screenSize.width * 0.12,
                                        ),
                                        Text(
                                          "Rankings",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            FadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Padding(
                                padding: EdgeInsets.all(buttonPadding),
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WinnersPage()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        width: 4.0,
                                        color: Colors.green.shade600),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    minimumSize: Size(buttonSize, buttonSize),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star_border_rounded,
                                          color: Colors.green.shade600,
                                          size: screenSize.width * 0.12,
                                        ),
                                        Text(
                                          "Hall of Fame",
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenSize.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
