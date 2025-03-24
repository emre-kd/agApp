// ignore_for_file: deprecated_member_use

import 'package:agapp/screens/home.dart';
import 'package:agapp/screens/post.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<Map<String, String>> posts = [
    {
      'profileImage': '',
      'name': 'John Doe',
      'username': '@johndoe',
      'timeAgo': '2h ago',
      'content': 'Lorem ipsum dolor sit amet.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
    {
      'profileImage': '',
      'name': 'Jane Doe',
      'username': '@janedoe',
      'timeAgo': '5h ago',
      'content': 'Another post content.',
      'postImage': '',
    },
  ];

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // AppBar with back button and profile edit button
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: 200.0, // Height for the background image
            floating: false,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 7, bottom: 7),
              child: SizedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (route) => false,
                    );
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
                      isScrollControlled:
                          true, // Allows the modal to take custom height
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 1.0, // Makes the modal full-screen
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Header with back button
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
                                    Navigator.pop(context); // Close the modal
                                  },
                                ),
                                // Cover image
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
                                          child: Image.asset(
                                            'assets/default-cover.png', // Replace with your cover image
                                            fit: BoxFit.fill,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[800],
                                                child: const Center(
                                                  child: Text(
                                                    'Cover Image',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
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
                                            onPressed: () {
                                              // Add logic to change cover image
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Profile image
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
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Name input field
                                const SizedBox(height: 8),
                                TextField(
                                  maxLength: 20,
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),

                                  // controller: userNameController,
                                    controller: TextEditingController(
                                    text: 'Emre Karadereli',
                                  ), 
                                  
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    prefixStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    //  helperText: _authenticationController.errors['username'] ?? _authenticationController.errors['username'],
                                    helperStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    counterStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                TextField(
                                  maxLength: 20,
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  controller: TextEditingController(
                                    text: 'myUserName',
                                  ), // Pr
                                  // controller: userNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    prefixStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    //  helperText: _authenticationController.errors['username'] ?? _authenticationController.errors['username'],
                                    helperStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    counterStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
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

                                  // controller: userNameController,
                               
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: Colors.white),
                                    //  helperText: _authenticationController.errors['username'] ?? _authenticationController.errors['username'],
                                    helperStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    counterStyle: TextStyle(
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                      color: Colors.white,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        //color: _authenticationController.errors['username'] != null  ? Colors.red : Colors.white,
                                        color: Colors.white,
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
                                      onPressed: () {},
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
                                        Navigator.pop(
                                          context,
                                        ); // Close the modal without saving
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
                          ),
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
                  FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/profile_images/', // Replace with your image URL
                      fit:
                          BoxFit
                              .cover, // Ensure the image covers the entire space
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/default-cover.png', // Fallback to default cover image
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Text(
                                  'Failed to load default image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Profile picture overlay
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
                        backgroundColor:
                            Colors.grey, // Placeholder for profile image
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
          // Profile details section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Space for the profile picture
                  // Name and verified badge
                  Row(
                    children: const [
                      Text(
                        'EMRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /* SizedBox(width: 5),
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ), */
                    ],
                  ),
                  const Text(
                    '@bocukurtwitter',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 10),
                  // Joined date
                  const Text(
                    'Temmuz 2021 tarihinde katıldı',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  // Follower/Following counts
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
          // Posts list
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
