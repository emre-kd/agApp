import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Placeholder for refresh action
  Future<void> _onRefresh(String type) async {
    // Simulate a refresh delay
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 0, 145, 230),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Most Liked Posts'),
            Tab(text: 'Most Commented Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Most Liked Posts Tab
          RefreshIndicator(
            onRefresh: () => _onRefresh('most_liked'),
            backgroundColor: Colors.black, // Black background for RefreshIndicator
            color: Colors.white, // White indicator
            strokeWidth: 3,
            child: _buildPostListView('most_liked'),
          ),
          // Most Commented Posts Tab
          RefreshIndicator(
            onRefresh: () => _onRefresh('most_commented'),
            backgroundColor: Colors.black, // Black background for RefreshIndicator
            color: Colors.white, // White indicator
            strokeWidth: 3,
            child: _buildPostListView('most_commented'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostListView(String type) {
    // Dummy data for posts
    final dummyPosts = List.generate(
      5,
      (index) => {
        'id': index,
        'userId': 1,
        'name': 'User $index',
        'username': '@user$index',
        'profileImage': '',
        'text': 'This is a sample post for the $type leaderboard.',
        'media': '',
        'createdAt': 'Just now',
        'commentsCount': type == 'most_commented' ? 100 - index * 10 : 10,
        'likeCount': type == 'most_liked' ? 500 - index * 50 : 20,
        'isLiked': false,
      },
    );

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: dummyPosts.length,
      itemBuilder: (context, index) {
        return _buildDummyPostWidget(dummyPosts[index]);
      },
    );
  }

  Widget _buildDummyPostWidget(Map<String, dynamic> post) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[800]!, width: 0.5),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[600]!,
                        width: 0.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[900],
                      child: Icon(Icons.person, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post['username'],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    post['createdAt'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (post['text'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    post['text'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                    color: post['isLiked'] ? Colors.red : Colors.grey[400],
                    label: post['likeCount'].toString(),
                    onTap: () {},
                  ),
                  _buildActionButton(
                    icon: Icons.mode_comment_outlined,
                    label: post['commentsCount'].toString(),
                    onTap: () {},
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[400], size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}