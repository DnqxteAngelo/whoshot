// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class WinnersPage extends StatefulWidget {
  const WinnersPage({Key? key}) : super(key: key);

  @override
  _WinnersPageState createState() => _WinnersPageState();
}

class _WinnersPageState extends State<WinnersPage> {
  List<Map<String, dynamic>> _winners = [];

  @override
  void initState() {
    super.initState();
    _fetchResultsDetails();
  }

  Future<void> _fetchResultsDetails() async {
    final url = Uri.parse('http://localhost/whoshot/lib/api/results.php');
    try {
      final response = await http.post(
        url,
        body: {'operation': 'getResultDetails'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final DateFormat formatter = DateFormat('h:mm a');

        setState(() {
          _winners = data.map((item) {
            final String resultTime =
                formatter.format(DateTime.parse(item['result_time']));
            return {
              'time': resultTime,
              'female': {
                'name': item['female_nomination_name'],
                'imageUrl':
                    'http://localhost/whoshot/lib/api/images/${item['female_nomination_imageUrl']}',
              },
              'male': {
                'name': item['male_nomination_name'],
                'imageUrl':
                    'http://localhost/whoshot/lib/api/images/${item['male_nomination_imageUrl']}',
              },
            };
          }).toList();
        });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: FadeInDown(
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
            ),
            FadeInDown(
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
            FadeInDown(
              duration: Duration(milliseconds: 1200),
              child: Text(
                "Hall of Fame",
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
                itemCount: _winners.length,
                itemBuilder: (context, index) {
                  final winnerPair = _winners[
                      _winners.length - 1 - index]; // Reverse the order
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Winners at ${winnerPair['time']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          winnerPair['female']['imageUrl']),
                                      radius: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      winnerPair['female']['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 20), // Spacing between the two winners
                              Expanded(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          winnerPair['male']['imageUrl']),
                                      radius: 50,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      winnerPair['male']['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
