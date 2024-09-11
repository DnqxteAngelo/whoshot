// ignore_for_file: prefer_const_constructors, avoid_print, library_private_types_in_public_api, sized_box_for_whitespace, unused_field

import 'dart:async';
// import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:whoshot/session/session_service.dart';
import 'package:flutter/material.dart';
import 'package:whoshot/models/Nominees.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final SessionService _sessionService = SessionService();
  List<Nominees> nominees = [];

  // bool _isWithinTimeLimit = false;
  Timer? _timer;
  DateTime? _votingEndTime;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

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
        // If the widget is not mounted, stop the timer.
        _timer?.cancel();
        return;
      }

      setState(() {});
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
          final oneHourAgo = now.subtract(Duration(days: 60));
          setState(() {
            nominees = (data['data'] as List)
                .map((json) => Nominees.fromJson(json))
                .where((nominee) =>
                    nominee.time != null && nominee.time!.isAfter(oneHourAgo))
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

  Future<void> _voteForNominee(Nominees nominee) async {
    // Replace with your server URL
    // final url = Uri.parse('http://localhost/whoshot/lib/api/vote.php');
    try {
      // Get the user's IP address (for now, using placeholder '127.0.0.1')
      String userIp = await _getUserIp();

      Map<String, dynamic> data = {
        'nominationId': nominee.id,
        'time': DateTime.now().toIso8601String(),
        'voterIp': userIp,
      };

      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/vote.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'addVote',
          'json': jsonEncode(data),
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          _showSnackBar('Vote successfully added.');
        } else {
          _showSnackBar(responseData['message']);
        }
      } else {
        print('Server error: ${response.statusCode}');
        _showSnackBar('Server error: Unable to vote.');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error: Unable to vote.');
    }
  }

  Future<String> _getUserIp() async {
    final url = Uri.parse('https://api.ipify.org?format=json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'];
      } else {
        print('Failed to get IP address: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching IP address: $e');
    }
    return '127.0.0.2';
    // try {
    //   for (var interface in await NetworkInterface.list()) {
    //     for (var addr in interface.addresses) {
    //       if (addr.type == InternetAddressType.IPv4) {
    //         return addr.address; // Returns the first IPv4 address found
    //       }
    //     }
    //   }
    // } catch (e) {
    //   print('Error getting user IP: $e');
    // }
    // return '127.0.0.1'; // Default fallback
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                  _buildTabContent("Vote for the most handsome man!", "male"),
                  _buildTabContent("Vote for the prettiest woman!", "female"),
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

  Widget _buildTabContent(String title, String gender) {
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
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
                    fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          FadeInLeft(
            duration: Duration(milliseconds: 1000),
            child: Text(
              "CITE Spotlight",
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 30,
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
                fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
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
                fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Builder(
                builder: (context) {
                  // Filter nominees by gender
                  final filteredNominees = nominees
                      .where(
                          (nominee) => nominee.gender?.toLowerCase() == gender)
                      .toList();

                  return filteredNominees.isEmpty
                      ? Center(
                          child: Text(
                            'No $gender nominees added in this hour.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 600
                                  ? 18
                                  : 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : CarouselSlider(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.55,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: filteredNominees.map(
                            (nominee) {
                              final index = filteredNominees.indexOf(nominee);
                              final isActive = index == _currentIndex;
                              return Builder(
                                builder: (context) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade800
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.4,
                                              margin: EdgeInsets.only(top: 10),
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Image.network(
                                                nominee.imageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            AnimatedOpacity(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              opacity: isActive ? 1.0 : 0.0,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    nominee.name!,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width >
                                                                  600
                                                              ? 20
                                                              : 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  ElevatedButton(
                                                    onPressed: isActive
                                                        ? () {
                                                            _voteForNominee(
                                                                nominee);
                                                          }
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green.shade600,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: Text("Vote"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Add some padding at the bottom to ensure content is visible
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ).toList(),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
