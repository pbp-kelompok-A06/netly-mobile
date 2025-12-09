import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart'; 

// Import Model & Utils
import 'package:netly_mobile/modules/community/model/post.dart';
import 'package:netly_mobile/utils/path_web.dart';
import '../../../utils/colors.dart';
import '../model/forum.dart';

// Import Widgets
import '../widgets/forum_card.dart';
import '../widgets/thread_post_card.dart';
import '../widgets/forum_dialog.dart'; 

class ForumShowPages extends StatefulWidget {
  const ForumShowPages({super.key});

  @override
  State<ForumShowPages> createState() => _ForumShowPagesState();
}

class _ForumShowPagesState extends State<ForumShowPages> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 1. VARIABLE UNTUK SEARCH & FUTURE
  bool _isSearching = false; // Status apakah sedang mencari
  final TextEditingController _searchController = TextEditingController(); // Kontrol input teks
  String _searchQuery = ""; // Menyimpan teks pencarian
  late Future<List<ForumData>> _futureForums; // Menyimpan future agar tidak reload saat ketik

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 2. INISIALISASI FUTURE DI SINI
    // Kita panggil fetchForum sekali saja saat halaman dibuka
    final request = context.read<CookieRequest>();
    _futureForums = fetchForum(request);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }

  // --- FETCH FORUM ---
  Future<List<ForumData>> fetchForum(CookieRequest request) async {
    
    request.headers['X-Requested-With'] = 'XMLHttpRequest';
    final response = await request.get('$pathWeb/community/');
    var data = response;
    List<ForumData> listForum = [];
    if (data['data'] != null) {
      for (var d in data['data']) { 
        if (d != null) listForum.add(ForumData.fromJson(d));
      }
    }
    return listForum;
  }

  // --- FETCH RECENT POSTS ---
  Future<List<PostData>> fetchPosts(CookieRequest request) async {
    final String url = '$pathWeb/community/forum/post/recent/3/';
    final response = await request.get(url);
    try {
      PostResponse postResponse = PostResponse.fromJson(response);
      return postResponse.data;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); 

    return Scaffold(
      backgroundColor: AppColors.backgroundCommunity,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        // 3. LOGIKA JUDUL APP BAR (Title vs Search Field)
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true, // Otomatis keyboard muncul
                decoration: const InputDecoration(
                  hintText: "Search forum...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (value) {
                  // Trigger rebuild untuk memfilter list
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                "Community",
                style: TextStyle(color: AppColors.textPrimaryCommunity, fontWeight: FontWeight.bold),
              ),
        
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.joinButtonCommunity,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.joinButtonCommunity,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: "Home"),
            Tab(text: "Explore Forum"),
            Tab(text: "My Forum"),
          ],
        ),
        
        actions: [
          // 4. LOGIKA TOMBOL SEARCH / CLOSE
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = ""; // Reset query
                  _searchController.clear(); // Bersihkan text field
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),

          // Tombol Add Forum
          IconButton(
            icon: const Icon(Icons.add, color: Colors.grey),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CreateForumDialog(
                    onForumCreated: () {
                      // Refresh data dari server
                      setState(() {
                        _futureForums = fetchForum(request);
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      
      body: FutureBuilder(
        future: _futureForums, // Gunakan variable future yang di-cache
        builder: (context, AsyncSnapshot<List<ForumData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab([], request),
                _buildExploreTab([]),
                _buildMyForumTab([]),
              ],
            );
          } else {
            final allForums = snapshot.data!;
            
            // 5. LOGIKA FILTERING PENCARIAN
            // Ambil semua data, lalu filter berdasarkan judul yang mengandung text search
            final filteredForums = allForums.where((forum) {
              final titleLower = forum.title.toLowerCase();
              final queryLower = _searchQuery.toLowerCase();
              return titleLower.contains(queryLower);
            }).toList();

            final currentUserId = request.jsonData['userData'] != null 
                ? request.jsonData['userData']['id'] 
                : -1; 

            // Bagi data yang SUDAH DI-FILTER ke dalam kategori tab
            final joinedForums = filteredForums.where((f) => f.isMember == true).toList();
            final exploreForums = filteredForums.where((f) => f.isMember == false).toList();
            final myForums = filteredForums.where((f) => f.creatorId.toString() == currentUserId.toString()).toList(); 

            return TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(joinedForums, request),
                _buildExploreTab(exploreForums),
                _buildMyForumTab(myForums),
              ],
            );
          }
        },
      ),
    );
  }

  // ... (Widget _buildHomeTab, _buildExploreTab, dll TETAP SAMA seperti sebelumnya)
  
  Widget _buildHomeTab(List<ForumData> data, CookieRequest request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Joined Forum", onSeeMore: () {
            _tabController.animateTo(1); 
          }),
          
          if (data.isEmpty)
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: Text(
                 _searchQuery.isNotEmpty 
                    ? "No forums found matching '$_searchQuery'." // Pesan jika search tidak ketemu
                    : "You haven't joined any forums yet."
               ),
             )
          else
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ForumCard(data: data[index]);
                },
              ),
            ),

          const SizedBox(height: 24),

          // Tampilkan Recent Post HANYA jika sedang TIDAK mencari
          // Karena search bar ini untuk mencari Forum, bukan Post.
          if (!_isSearching) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: const Text(
                "Recent Post",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryCommunity,
                ),
              ),
            ),
            
            FutureBuilder<List<PostData>>(
              future: fetchPosts(request), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(); // Hide if empty
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length, 
                    itemBuilder: (context, index) {
                      final post = snapshot.data![index];
                      return ThreadPostCard(
                        title: post.header,
                        userName: post.user.username,
                        timeAgo: timeAgo(post.createdAt),
                        content: post.content,
                        forumName: post.forumName ?? "Forum", 
                      );
                    },
                  );
                }
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildExploreTab(List<ForumData> data) {
    if (data.isEmpty) {
      return Center(child: Text(_searchQuery.isNotEmpty ? "No result." : "No new forums to explore."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.0, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => ForumCard(data: data[index]),
    );
  }

  Widget _buildMyForumTab(List<ForumData> data) {
    if (data.isEmpty) {
      return Center(child: Text(_searchQuery.isNotEmpty ? "No result." : "You haven't created any forums."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ForumCard(data: data[index], myForum: true),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryCommunity)),
          if (onSeeMore != null)
            TextButton(onPressed: onSeeMore, child: const Text("See More", style: TextStyle(color: AppColors.joinButtonCommunity))),
        ],
      ),
    );
  }
}
