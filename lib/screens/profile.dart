// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'dart:io';

import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:flutter/material.dart';
import 'package:agapp/controllers/authentication.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthenticationController _authenticationController = Get.put(
    AuthenticationController(),
  );
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController createdAtController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController coverImageController = TextEditingController();
  File? _profileImageFile;
  File? _coverImageFile;
  final bool _obscurePassword = true;

  void getUserInfo() async {
    await _authenticationController.getUserDetails();
    nameController.text =
        _authenticationController.user.value.name ?? 'AgalıkName';
    userNameController.text =
        _authenticationController.user.value.username ?? 'AgalıkUserName';
    emailController.text =
        _authenticationController.user.value.email ?? 'AgalıkEmail';
    createdAtController.text =
        _authenticationController.user.value.createdAt ?? '29.10.1923';
  }

  Future<String?> getTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void updateOnPressed() async {
    String? token = await getTokenFromStorage();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to update profile.')),
      );
      return;
    }

    await _authenticationController.updateUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      username: userNameController.text.trim(),
      password: passwordController.text.trim(),
      token: token,
      context: context,
    );
  }

  final List<Map<String, String>> posts = [
    {
      'profileImage': '',
      'name': 'John Doe 2',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 7, bottom: 7),
              child: SizedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // Pop if there’s a previous route
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      ); // Replace with Home if no previous route
                    }
                  },
                  backgroundColor: Colors.black.withOpacity(0.2),
                  elevation: 0,
                  highlightElevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                child: OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.black,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (
                            BuildContext context,
                            StateSetter setModalState,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    title: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(
                                          context,
                                        ); // Close the modal
                                      }
                                    },
                                  ),
                                  Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                _coverImageFile != null
                                                    ? Image.file(
                                                      _coverImageFile!,
                                                      fit: BoxFit.fill,
                                                    )
                                                    : Image.asset(
                                                      'assets/default-cover.png',
                                                      fit: BoxFit.fill,
                                                    ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                final picker = ImagePicker();
                                                final pickedFile = await picker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                if (pickedFile != null) {
                                                  setState(() {
                                                    _coverImageFile = File(
                                                      pickedFile.path,
                                                    );
                                                  });
                                                  setModalState(() {});
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                              _profileImageFile != null
                                                  ? FileImage(
                                                    _profileImageFile!,
                                                  )
                                                  : null,
                                          child:
                                              _profileImageFile == null
                                                  ? const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.white,
                                                  )
                                                  : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final picker = ImagePicker();
                                              final pickedFile = await picker
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                  );
                                              if (pickedFile != null) {
                                                setState(() {
                                                  _profileImageFile = File(
                                                    pickedFile.path,
                                                  );
                                                });
                                                setModalState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    maxLength: 20,
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      prefixStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      helperText:
                                          _authenticationController
                                              .errors['name'] ??
                                          '',
                                      helperStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['name'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      counterStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['name'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color:
                                            _authenticationController
                                                        .errors['name'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['name'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['name'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    maxLength: 20,
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    controller: userNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      prefixStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      helperText:
                                          _authenticationController
                                              .errors['username'] ??
                                          '',
                                      helperStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['username'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      counterStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['username'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color:
                                            _authenticationController
                                                        .errors['username'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['username'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['username'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    maxLength: 50,
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      helperText:
                                          _authenticationController
                                              .errors['email'] ??
                                          '',
                                      helperStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['email'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      counterStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['email'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color:
                                            _authenticationController
                                                        .errors['email'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['email'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['email'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    maxLength: 20,
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    obscureText: _obscurePassword,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: Colors.white,
                                      ),
                                      helperText:
                                          _authenticationController
                                              .errors['password'] ??
                                          '',
                                      helperStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['password'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      counterStyle: TextStyle(
                                        color:
                                            _authenticationController
                                                        .errors['password'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color:
                                            _authenticationController
                                                        .errors['password'] !=
                                                    null
                                                ? Colors.red
                                                : Colors.white,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['password'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              _authenticationController
                                                          .errors['password'] !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () async {
                                          String? token =
                                              await getTokenFromStorage();

                                          if (token == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'You must be logged in to update profile.',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          bool success =
                                              await _authenticationController
                                                  .updateUser(
                                                    name:
                                                        nameController.text
                                                            .trim(),
                                                    email:
                                                        emailController.text
                                                            .trim(),
                                                    username:
                                                        userNameController.text
                                                            .trim(),
                                                    password:
                                                        passwordController.text
                                                            .trim(),
                                                    token: token,
                                                    context: context,
                                                  );

                                          if (!success) {
                                            setModalState(
                                              () {},
                                            ); // ✅ Refresh the UI so errorText updates
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          side: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(
                                              context,
                                            ); // Close the modal
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1),
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 5.0,
                    ),
                  ),
                  child: const Text(
                    'Change Profile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/default-cover.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Text(
                            'Failed to load default image',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 20,
                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          _authenticationController.user.value.name ??
                              'Default Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(
                      '@${_authenticationController.user.value.username ?? 'Default UserName'}',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final createdAtString =
                        _authenticationController.user.value.createdAt;
                    String formattedDate = 'Unknown date';
                    if (createdAtString != null && createdAtString.isNotEmpty) {
                      try {
                        final dateTime = DateTime.parse(createdAtString);
                        formattedDate = DateFormat.yMMMMd(
                          'en_US',
                        ).format(dateTime);
                      } catch (e) {
                        formattedDate = 'Invalid date';
                      }
                    }
                    return Text(
                      'Joined $formattedDate',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    );
                  }),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Text(
                        '77 Follows',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 20),
                      Text(
                        '9 Takipçi',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              return Post(
                profileImage: post['profileImage']!,
                name: post['name']!,
                username: post['username']!,
                timeAgo: post['timeAgo']!,
                content: post['content']!,
                postImage: post['postImage']!,
              );
            }, childCount: posts.length),
          ),
        ],
      ),
    );
  }
}
