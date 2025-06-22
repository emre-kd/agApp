// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:agapp/constant.dart';
import 'package:agapp/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart'; // Import video_player

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  File? _selectedMedia;
  String? _mediaExtension;
  bool isLoading = true;
  String errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  Map<String, String?> errors = {};
  bool isUpdating = false;
  VideoPlayerController? _videoPlayerController; // Controller for video preview
  bool _isVideoInitialized = false; // Track video initialization

  static const int _maxChars = 250;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _textController.addListener(() {
      setState(() {}); // Update char counter
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _videoPlayerController?.dispose(); // Dispose video controller
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'gif', 'mp4'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        // Clear previous video controller if any
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
        _isVideoInitialized = false;

        _selectedMedia = File(result.files.single.path!);
        _mediaExtension = result.files.single.extension;

        // Initialize video controller if the selected media is a video
        if (_isVideo(_mediaExtension)) {
          _videoPlayerController = VideoPlayerController.file(_selectedMedia!)
            ..initialize().then((_) {
              setState(() {
                _isVideoInitialized = true;
              });
            }).catchError((error) {
              setState(() {
                _isVideoInitialized = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading video: $error')),
              );
            });
        }
      });
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = null;
      _mediaExtension = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      _isVideoInitialized = false;
    });
  }

  bool _isVideo(String? extension) {
    return extension == 'mp4';
  }

  Future<void> _storePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUpdating = true;
      errors = {};
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        isUpdating = false;
        errorMessage = 'No authentication token found';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please log in again.'),
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(storePostURL));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['text'] = _textController.text;

      // Add media file if selected
      if (_selectedMedia != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            _selectedMedia!.path,
            filename: 'media.${_mediaExtension}',
          ),
        );
      }

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post başarıyla oluşturuldu!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unauthorized. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 422) {
        setState(() {
          Map<String, dynamic> errorMessages =
              jsonDecode(responseData)['errors'];
          errorMessages.forEach((key, value) {
            errors[key] = value[0];
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors.values.join('\n'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server error. Please try again later."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentCharCount = _textController.text.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30),
          ),
          child: Text(
            '$currentCharCount/$_maxChars',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  cursorColor: Colors.white,
                  focusNode: _focusNode,
                  maxLength: _maxChars,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Agalar ne diyor ?",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: false,
                    errorText: errors['text'],
                    helperStyle: TextStyle(
                      color: errors['text'] != null ? Colors.red : Colors.white,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 161, 161, 161),
                        width: 2,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                  ),
                ),
                if (_selectedMedia != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _isVideo(_mediaExtension)
                            ? (_isVideoInitialized && _videoPlayerController != null
                                ? SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: VideoPlayer(_videoPlayerController!),
                                  )
                                : Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                            : Image.file(
                                _selectedMedia!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: _removeMedia,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickMedia,
            backgroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.perm_media, color: Colors.black),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: isUpdating ? null : _storePost,
            backgroundColor: Colors.white,
            child: isUpdating
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
    );
  }
}