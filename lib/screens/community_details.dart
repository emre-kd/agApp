import 'package:agapp/constant.dart';
import 'package:agapp/screens/searched_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityDetails extends StatefulWidget {
  const CommunityDetails({super.key});

  @override
  State<CommunityDetails> createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  Map<String, dynamic>? communityData;
  Map<String, dynamic>? communityUserData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCommunityDetails();
  }

  Future<void> fetchCommunityDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('$getCommunities'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          communityData = data['community'];
          communityUserData = data['community']['user'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load community details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,  // <-- Siyah arka plan
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(
        communityData?['name'] ?? 'Topluluk Detayları',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    body: isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white, // Beyaz spinner
              strokeWidth: 2,
            ),
          )
        : errorMessage != null
            ? _buildErrorState()
            : _buildCommunityDetails(),
  );
}

Widget _buildErrorState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 60),
        const SizedBox(height: 16),
        Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
            fetchCommunityDetails();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'Tekrar Dene',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCommunityDetails() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Topluluk Bilgisi'),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.group,
            title: 'Topluluk Adı',
            subtitle: communityData?['name'] ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.code,
            title: 'Topluluk Kodu',
            subtitle: communityData?['code'] ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.person_4,
            title: 'Topluluk Kurucusu',
            subtitle:
                '${communityUserData?['name'] ?? 'N/A'} / ${communityUserData?['username'] ?? 'N/A'}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchedProfile(
                    userId: communityUserData?['id'],
                    userName: communityUserData?['username'],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.people,
            title: 'Üyeler',
            subtitle: '${communityData?['users_count'] ?? 0} üye',
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            icon: Icons.calendar_today,
            title: 'Oluşturulma Tarihi',
            subtitle: communityData?['created_at'] ?? 'N/A',
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(String title) {
  return Text(
    title,
    style: const TextStyle(
      color: Colors.white,  // Beyaz başlıklar
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildInfoCard({
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onTap, // Optional onTap callback
}) {
  return AnimatedOpacity(
    opacity: 1.0,
    duration: const Duration(milliseconds: 300),
    child: Card(
      color: const Color(0xFF121212), // koyu gri/siyah kart
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: 24), // Beyaz ikon
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    ),
  );
}

}
