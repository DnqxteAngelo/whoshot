// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:async';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:whoshot/main.dart';
import 'package:whoshot/pages/camera_page.dart';
import 'package:whoshot/session/session_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final SessionService _sessionService = SessionService();
  bool _isLoading = false;
  String _gender = 'Male';
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  bool _isWithinTimeLimit = false;
  Timer? _timer;
  DateTime? _nominationEndTime;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
    _loadNominationEndTime();
    _startSessionCheckTimer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadNominationEndTime() async {
    final times = await _sessionService.loadNominationTimes();
    setState(() {
      _nominationEndTime = times['end'];
    });
  }

  String _getNominationRemainingTime() {
    if (_nominationEndTime == null) return "No Session";

    final now = DateTime.now();
    final difference = _nominationEndTime!.difference(now);

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

  void _startSessionCheckTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      bool isNominationActive =
          await _sessionService.isWithinNominationSession();

      if (!isNominationActive) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
  }

  Future<void> _checkSessionStatus() async {
    final isWithin = await _sessionService.isWithinNominationSession();
    setState(() {
      _isWithinTimeLimit = isWithin;
    });
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: Colors.green[600]!, width: 2), // Green border with width
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          title: Text(
            'Choose Image Source',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  selectImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Use Camera'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraPage(
                        onImageSelected: (imageData) {
                          setState(() {
                            _imageBytes = imageData;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      // Permission is granted, proceed with camera access
    } else if (status.isDenied) {
      // Permission is denied, show a dialog or message to the user
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, you may open the app settings
      openAppSettings();
    }
  }

  Future<void> selectImageFromCamera() async {
    await _requestCameraPermission();

    try {
      if (!kIsWeb) {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.camera);

        if (photo != null) {
          final Uint8List imageData = await photo.readAsBytes();
          setState(() {
            _imageBytes = imageData;
          });
        } else {
          print("No image captured");
        }
      } else {
        print("Camera feature is not supported on web.");
        // You may want to handle the case for web differently or use a different method
        // such as a file picker with media types.
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> selectImageFromGallery() async {
    try {
      if (kIsWeb) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final Uint8List imageData = await image.readAsBytes();
          setState(() {
            _imageBytes = imageData;
          });
        } else {
          print("No image selected");
        }
      } else {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(allowMultiple: false);
        if (result != null) {
          final PlatformFile file = result.files.first;
          final Uint8List? imageData = file.bytes;
          setState(() {
            _imageBytes = imageData;
          });
        } else {
          print("No file selected");
        }
      }
    } catch (e) {
      print("Error selecting image: $e");
    }
  }

  // Future<void> selectImage() async {
  //   try {
  //     FilePickerResult? result =
  //         await FilePicker.platform.pickFiles(allowMultiple: false);

  //     if (result != null) {
  //       final PlatformFile file = result.files.first;
  //       final Uint8List? imageData = file.bytes;
  //       setState(() {
  //         _imageBytes = imageData;
  //       });
  //     } else {
  //       // User canceled the picker
  //       print("No file selected");
  //     }
  //   } catch (e) {
  //     print("Error selecting image: $e");
  //   }
  // }

  Future<void> _addNominee() async {
    if (!_isWithinTimeLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominations are closed.')),
      );
      return;
    }

    String _name = _nameController.text;

    if (_name.trim().isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid name and an image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageData = base64Encode(_imageBytes!);
      Map<String, dynamic> data = {
        'name': _name.trim(),
        'file': imageData,
        'gender': _gender,
        'time': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('http://localhost/whoshot/lib/api/nominee.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'addNominees',
          'json': jsonEncode(data),
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nominee added successfully!')),
          );
          setState(() {
            _nameController.clear();
            _imageBytes = null;
            _gender = 'Male';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add nominee. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to communicate with the server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;

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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05, // 5% from both sides
                vertical: screenSize.height * 0.02, // 2% from top
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
                        size: screenSize.width * 0.07, // 7% of screen width
                      ),
                    ),
                  ),
                  FadeInRight(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      'Time Remaining: ${_getNominationRemainingTime()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            screenSize.width * 0.04, // Responsive font size
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
                  fontSize: screenSize.width * 0.08, // Responsive font size
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
                  fontSize: screenSize.width * 0.05, // Responsive font size
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.03), // Responsive height
            FadeInLeft(
              duration: Duration(milliseconds: 1200),
              child: Text(
                "Nominate someone pretty/handsome!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.05, // Responsive font size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05, // 5% from both sides
                  vertical: screenSize.height * 0.04, // 4% from top and bottom
                ),
                child: FadeInUp(
                  duration: Duration(milliseconds: 1300),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                          Radius.circular(20)), // Adjusted border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0), // Adjusted padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Container(
                              height:
                                  screenSize.height * 0.07, // Responsive height
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    8), // Adjusted border radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade200,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: "Name",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: screenSize.height *
                                  0.02), // Responsive height
                          GestureDetector(
                            onTap: () {
                              print("GestureDetector tapped");
                              _showImageSourceDialog();
                            }, // Handle image upload
                            child: FadeInUp(
                              duration: Duration(milliseconds: 1500),
                              child: Container(
                                width: double.infinity,
                                height: screenSize.height *
                                    0.25, // Responsive height
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      8), // Adjusted border radius
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade200,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _imageBytes == null
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: screenSize.width *
                                                  0.1, // Responsive icon size
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                                height: screenSize.height *
                                                    0.01), // Responsive height
                                            Text(
                                              "Click to upload image",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: screenSize.width *
                                                    0.04, // Responsive font size
                                              ),
                                            ),
                                          ],
                                        )
                                      : Image.memory(
                                          _imageBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: screenSize.height *
                                  0.02), // Responsive height
                          FadeInUp(
                            duration: Duration(milliseconds: 1600),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        hoverColor: Colors.green.shade400,
                                        activeColor: Colors.green.shade600,
                                        value: 'Male',
                                        groupValue: _gender,
                                        onChanged: (value) {
                                          setState(() {
                                            _gender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Male',
                                        style: TextStyle(
                                          fontSize: screenSize.width *
                                              0.04, // Responsive font size
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        hoverColor: Colors.green.shade400,
                                        activeColor: Colors.green.shade600,
                                        value: 'Female',
                                        groupValue: _gender,
                                        onChanged: (value) {
                                          setState(() {
                                            _gender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Female',
                                        style: TextStyle(
                                          fontSize: screenSize.width *
                                              0.04, // Responsive font size
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: screenSize.height *
                                  0.05), // Responsive height
                          FadeInUp(
                            duration: Duration(milliseconds: 1700),
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : MaterialButton(
                                    onPressed: _addNominee,
                                    height: screenSize.height *
                                        0.07, // Responsive height
                                    color: Colors.green.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenSize.width *
                                              0.04, // Responsive font size
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
}
