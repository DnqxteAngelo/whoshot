// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, sized_box_for_whitespace
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:whoshot/pages/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.green.shade900,
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          actionTextColor: Colors.yellow,
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables to hold the random numbers
  int firstNumber = 0;
  int secondNumber = 0;
  Color borderColor = Colors.grey; // Default border color
  TextEditingController answerController = TextEditingController();

  // Function to generate random numbers
  void generateRandomNumbers() {
    setState(() {
      Random random = Random();
      firstNumber =
          random.nextInt(20) + 1; // Generates a number between 0 and 9
      secondNumber =
          random.nextInt(20) + 1; // Generates a number between 0 and 9
      borderColor = Colors.grey; // Reset border color when numbers change
      answerController.clear(); // Clear the user input field
    });
  }

  // Function to validate user input
  void validateAnswer() {
    int correctSum = firstNumber + secondNumber;
    int userAnswer = int.tryParse(answerController.text) ??
        -1; // Safely parse the user input

    setState(() {
      if (userAnswer == correctSum) {
        borderColor = Colors.green.shade600; // Correct answer
      } else {
        borderColor = Colors.red.shade600; // Incorrect answer
      }
    });
  }

  @override
  void initState() {
    super.initState();
    generateRandomNumbers(); // Initial generation of random numbers
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonPadding = screenSize.width * 0.03;
    final isLargeScreen = screenSize.width > 600;

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
          children: [
            SizedBox(height: screenSize.height * 0.1),
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: Column(
                children: [
                  FadeInLeft(
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: buttonPadding),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "C I T E",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              isLargeScreen ? 60 : screenSize.width * 0.15,
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
                        fontSize: isLargeScreen ? 40 : screenSize.width * 0.1,
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
                        fontSize: isLargeScreen ? 20 : screenSize.width * 0.05,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenSize.height * 0.03),
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 60.0 : 30.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          FadeInLeft(
                            duration: Duration(milliseconds: 1100),
                            child: Text(
                              "Login to your account",
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: isLargeScreen
                                    ? 32
                                    : screenSize.width * 0.08,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.03),
                          FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Container(
                              width: isLargeScreen
                                  ? screenSize.width * 0.5
                                  : double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade200,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Student ID #",
                                        labelStyle: TextStyle(
                                            color: Colors.green.shade600),
                                        hintText: "e.g. 00-0000-000000",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.08),
                          FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildUnclickableTextField(
                                      firstNumber.toString()),
                                  Text(
                                    "+",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 22,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  _buildUnclickableTextField(
                                      secondNumber.toString()),
                                  Text("=",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 22,
                                      ),
                                      textAlign: TextAlign.center),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: answerController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: borderColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: borderColor, width: 2.0),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        validateAnswer();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    color: Colors.green.shade600,
                                    onPressed: generateRandomNumbers,
                                    icon: Icon(
                                      Icons.replay,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.04),
                          FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Container(
                              width: isLargeScreen
                                  ? screenSize.width * 0.3
                                  : double.infinity,
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LandingPage()),
                                  );
                                },
                                height: 50,
                                color: Colors.green.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // Helper method to build a read-only text field
  Widget _buildUnclickableTextField(String label) {
    return GestureDetector(
      onTap: null,
      child: AbsorbPointer(
        child: SizedBox(
          width: 50,
          child: TextField(
            textAlign: TextAlign.center,
            readOnly: true,
            decoration: InputDecoration(
              hintText: label,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
