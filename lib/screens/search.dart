import 'dart:convert';
import 'package:agapp/constant.dart';
import 'package:agapp/screens/searched_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// User model based on API response
class User {
  final int id;
  final int communityId;
  final String name;
  final String username;
  final String? coverImage;
  final String? image;
  final String createdAt;
  final Community community;

  User({
    required this.id,
    required this.communityId,
    required this.name,
    required this.username,
    this.coverImage,
    this.image,
    required this.createdAt,
    required this.community,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      communityId: json['community_id'],
      name: json['name'],
      username: json['username'],
      coverImage: json['coverImage'],
      image: json['image'],
      createdAt: json['created_at'],
      community: Community.fromJson(json['community']),
    );
  }
}

// Community model
class Community {
  final int id;
  final String code;
  final String name;

  Community({required this.id, required this.code, required this.name});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(id: json['id'], code: json['code'], name: json['name']);
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<User> _allUsers = []; // All users fetched from API
  List<User> _searchResults = []; // Filtered users for display
  List<User> _displayedUsers = []; // Paginated subset of users
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  final int _pageSize = 10; // Load 10 users per page

  @override
  void initState() {
    super.initState();
    _searchResults = _displayedUsers;
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(usersDetailsURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data['users'];
        final users = usersJson.map((json) => User.fromJson(json)).toList();

        setState(() {
          _allUsers = users;
          _displayedUsers = users.take(_pageSize).toList();
          _searchResults =
              _searchController.text.isEmpty
                  ? _displayedUsers
                  : _allUsers
                      .where(
                        (user) =>
                            user.name.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ) ||
                            user.username.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ),
                      )
                      .toList();
          _isLoading = false;
          _currentPage = 1;
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching users: $e';
      });
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = _displayedUsers; // Revert to paginated list
      } else {
        _searchResults =
            _allUsers
                .where(
                  (user) =>
                      user.name.toLowerCase().contains(query) ||
                      user.username.toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  void _onScroll() {
    if (_searchController.text.isNotEmpty)
      return; // Disable pagination during search
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore &&
        _displayedUsers.length < _allUsers.length) {
      _loadMoreUsers();
    }
  }

  void _loadMoreUsers() {
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final nextUsers =
            _allUsers.skip(_currentPage * _pageSize).take(_pageSize).toList();
        _displayedUsers.addAll(nextUsers);
        _searchResults =
            _searchController.text.isEmpty
                ? _displayedUsers
                : _allUsers
                    .where(
                      (user) =>
                          user.name.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ) ||
                          user.username.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                    )
                    .toList();
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kullanıcıları Bul',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Kullanıcı adı veya isimle ara...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Search Results
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    )
                    : _searchResults.isEmpty
                    ? const Center(
                      child: Text(
                        'Kullanıcı bulunamadı',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _searchResults.length +
                          (_isLoadingMore && _searchController.text.isEmpty
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index == _searchResults.length &&
                            _isLoadingMore &&
                            _searchController.text.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        final user = _searchResults[index];
                        return ListTile(
                          leading:
                              user.image != null
                                  ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '$baseNormalURL/${user.image}',
                                    ),
                                    backgroundColor: Colors.grey[300],
                                  )
                                  : CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                          title: Text(
                            user.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            '@${user.username}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            'Katılım: ${user.createdAt}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SearchedProfile(userId : user.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
