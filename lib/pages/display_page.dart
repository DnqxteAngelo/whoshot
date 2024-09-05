// ignore_for_file: prefer_const_constructors, avoid_print, library_private_types_in_public_api, unused_import

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
          final oneHourAgo = now.subtract(Duration(days: 30));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                "CITE Spotlight",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Who got the best face?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Male Nominees",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: Marqueer.builder(
                  pps: 30,
                  controller: _controller,
                  direction: MarqueerDirection.rtl, // Bottom-to-top scrolling
                  autoStartAfter: const Duration(seconds: 2),
                  itemCount: maleNominees.length,
                  itemBuilder: (context, index) {
                    final nominee = maleNominees[index];
                    return _buildNomineeCard(nominee);
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Female Nominees",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: Marqueer.builder(
                  pps: 30,
                  controller: _controller,
                  direction: MarqueerDirection.ltr, // Bottom-to-top scrolling
                  autoStartAfter: const Duration(seconds: 2),
                  itemCount: femaleNominees.length,
                  itemBuilder: (context, index) {
                    final nominee = femaleNominees[index];
                    return _buildNomineeCard(nominee);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNomineeCard(Nominees nominee) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      width: 200.0, // Fixed width
      height: 250.0, // Fixed height
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  nominee.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay with name and shadow
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color:
                    Colors.black.withOpacity(0.5), // Black overlay with opacity
                child: Text(
                  nominee.name!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
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
