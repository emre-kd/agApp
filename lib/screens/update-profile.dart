// ignore_for_file: avoid_print, sort_child_properties_last, use_build_context_synchronously

import 'dart:io';
import 'package:agapp/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  String errorMessage = '';
  bool _obscurePassword = true;
  File? _profileImage;
  File? _coverImage;
  final _formKey = GlobalKey<FormState>();
  Map<String, String> errors = {};
  bool isUpdating = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'Hiçbir kimlik doğrulama belirteci bulunamadı';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(userDetailsURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          // Handle case where response is a list
          if (decodedResponse is List<dynamic> && decodedResponse.isNotEmpty) {
            userData = decodedResponse[0] as Map<String, dynamic>;
          } else if (decodedResponse is Map<String, dynamic>) {
            userData = decodedResponse;
          } else {
            userData = {};
            errorMessage = 'Unexpected response format';
          }
          _nameController.text = userData['name']?.toString() ?? '';
          _userNameController.text = userData['username']?.toString() ?? '';
          _emailController.text = userData['email']?.toString() ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user data: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _updateProfile() async {
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
          content: Text('Kimlik doğrulama hatası. Lütfen tekrar giriş yapın.'),
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(updateUserURL));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['_method'] = 'PUT';
      request.fields['name'] = _nameController.text;
      request.fields['username'] = _userNameController.text;
      request.fields['email'] = _emailController.text;
      if (_passwordController.text.isNotEmpty) {
        request.fields['password'] = _passwordController.text;
      }

      // Add profile image if selected
      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _profileImage!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Add cover image if selected
      if (_coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'coverImage',
            _coverImage!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      print(responseData); // In fetchUserData

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profil başarıyla güncellendi!"),
            backgroundColor: Color.fromARGB(255, 0, 145, 230),
          ),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Yetkisiz. Lütfen tekrar giriş yapın."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 422) {
        setState(() {
          Map<String, dynamic> errorMessages =
              jsonDecode(responseData)['errors'];
          errorMessages.forEach((key, value) {
            errors[key] = value[0]; // or keep the whole list if needed
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sunucu hatası. Lütfen daha sonra tekrar deneyin."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Makes all icons white
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          },
        ),
        title: const Text('Kullanıcı Profili'),
        titleTextStyle: GoogleFonts.tektur(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateProfile()),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(5.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        clipBehavior: Clip.none, // Allows overflow
                        children: [
                          // Cover Image
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _pickImage(false),
                              borderRadius: BorderRadius.circular(10),
                              child: Ink(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[300],
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        _coverImage != null
                                            ? FileImage(_coverImage!)
                                            : userData['coverImage'] != null &&
                                                userData['coverImage'] is String
                                            ? NetworkImage(
                                              '$baseNormalURL/${userData['coverImage']}',
                                            )
                                            : const AssetImage(
                                                  'assets/default-cover.png',
                                                )
                                                as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // PROFILE IMAGE (clickable anywhere)
                          Positioned(
                            bottom: -75,
                            left: 20,
                            child: Material(
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => _pickImage(true),
                                customBorder: const CircleBorder(),
                                child: Ink(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    image:
                                        _profileImage != null
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(_profileImage!),
                                            )
                                            : userData['image'] != null &&
                                                userData['image'] is String
                                            ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                '$baseNormalURL/${userData['image']}',
                                              ),
                                            )
                                            : null, // No DecorationImage for default icon
                                  ),
                                  child:
                                      _profileImage == null &&
                                              (userData['image'] == null ||
                                                  userData['image'] is! String)
                                          ? const Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 100,
                      ), // spacing below profile image
                      // Name Field
                      TextFormField(
                        maxLength: 20,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          prefixStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorText: errors['name'],
                          helperStyle: TextStyle(
                            color:
                                errors['name'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          counterStyle: TextStyle(
                            color:
                                errors['name'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color:
                                errors['name'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['name'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['name'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Username Field
                      TextFormField(
                        maxLength: 20,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        controller: _userNameController,
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          prefixStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorText: errors['username'],
                          helperStyle: TextStyle(
                            color:
                                errors['username'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          counterStyle: TextStyle(
                            color:
                                errors['username'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color:
                                errors['username'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['username'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['username'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Email Field
                     /* TextFormField(
                        maxLength: 50,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorText: errors['email'],
                          helperStyle: TextStyle(
                            color:
                                errors['email'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          counterStyle: TextStyle(
                            color:
                                errors['email'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color:
                                errors['email'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['email'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['email'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10), */
                      // Password Field
                      TextFormField(
                        maxLength: 20,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Şifre (Güncel tutmak için boş bırakın)',
                          prefixStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorText: errors['password'],
                          helperStyle: TextStyle(
                            color:
                                errors['password'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          counterStyle: TextStyle(
                            color:
                                errors['password'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color:
                                errors['password'] != null
                                    ? Colors.red
                                    : Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['password'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  errors['password'] != null
                                      ? Colors.red
                                      : Colors.white,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Update Button
                      ElevatedButton(
                        onPressed: isUpdating ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.white, width: 1.5),

                          ),
                          disabledBackgroundColor: Colors.grey[800],
                          disabledForegroundColor: Colors.white70,
                        ),
                        child:
                            isUpdating
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Profili Güncelle',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
