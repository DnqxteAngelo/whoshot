// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, curly_braces_in_flow_control_structures, unused_import

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:camera_web/camera_web.dart'; // Import camera_web for web

class CameraPage extends StatefulWidget {
  final Function(Uint8List) onImageSelected; // Callback to pass the image data

  const CameraPage({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile picture = await _controller.takePicture();
      final Uint8List imageData = await picture.readAsBytes();
      widget.onImageSelected(imageData);
      Navigator.pop(context); // Close the camera page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? photo =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (photo != null) {
        final Uint8List imageData = await photo.readAsBytes();
        widget
            .onImageSelected(imageData); // Pass the image data to the callback
        Navigator.pop(context); // Close the camera page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2)
      return; // No cameras to switch between

    final newIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    final newCamera = _cameras![newIndex];

    setState(() {
      _selectedCameraIndex = newIndex;
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.05,
                    top: constraints.maxHeight * 0.02,
                    right: constraints.maxWidth * 0.05,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: constraints.maxWidth * 0.06,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _cameras == null
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : FutureBuilder<void>(
                              future: _initializeControllerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Container(
                                    width: double.infinity,
                                    height: constraints.maxHeight * 0.7,
                                    child: CameraPreview(_controller),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: constraints.maxWidth * 0.04,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  );
                                }
                              },
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: constraints.maxHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo_library),
                        onPressed: _pickImageFromGallery,
                        color: Colors.white,
                        iconSize: constraints.maxWidth * 0.08,
                      ),
                      SizedBox(width: constraints.maxWidth * 0.05),
                      IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: _takePicture,
                        iconSize: constraints.maxWidth * 0.12,
                        color: Colors.white,
                      ),
                      SizedBox(width: constraints.maxWidth * 0.05),
                      IconButton(
                        icon: Icon(Icons.switch_camera),
                        onPressed: _switchCamera,
                        color: Colors.white,
                        iconSize: constraints.maxWidth * 0.08,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
              ],
            );
          },
        ),
      ),
    );
  }
}
