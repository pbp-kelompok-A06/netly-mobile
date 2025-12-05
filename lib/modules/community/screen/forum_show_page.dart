import 'package:flutter/material.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:provider/provider.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart'; 
import '../model/forum.dart';
import '../../../utils/colors.dart';
import '../widgets/forum_card.dart';
import '../widgets/thread_post_card.dart';

class ForumShowPage extends StatefulWidget {
  const ForumShowPage({super.key});

  @override
  State<ForumShowPage> createState() => _ForumShowPageState();
}

class _ForumShowPageState extends State<ForumShowPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // add TabController
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // fetch Async
  Future<List<ForumData>> fetchForum(CookieRequest request) async {
    request.headers['X-Requested-With'] = 'XMLHttpRequest';
    final response = await request.get('$pathWeb/community/');

    var data = response;

    List<ForumData> listForum = [];
    for (var d in data['data']) { 
      if (d != null) {
        listForum.add(ForumData.fromJson(d));
      }
    }
    return listForum;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); 

    return Scaffold(
      backgroundColor: AppColors.backgroundCommunity,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
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
        // add forum button
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      // 
      body: FutureBuilder(
        future: fetchForum(request),
        builder: (context, AsyncSnapshot<List<ForumData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('There is no forum yet.'));
          } else {

            final allForums = snapshot.data!;

            // Filtering tab
            // Joined Forum ketika isMember == true
            final joinedForums = allForums.where((f) => f.isMember == true).toList();
            
            // Explore Forum ketika isMember == false
            final exploreForums = allForums.where((f) => f.isMember == false).toList();
            
            // My Forum ketika creatorId == userId
            final myForums = allForums.where((f) => f.creatorId == request.jsonData['userData']['id']).toList(); 

            return TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(joinedForums),
                _buildExploreTab(exploreForums),
                _buildMyForumTab(myForums),
              ],
            );
          }
        },
      ),
    );
  }


  Widget _buildHomeTab(List<ForumData> data) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Joined Forum", onSeeMore: () {
            _tabController.animateTo(1); 
          }),
          
          if (data.isEmpty)
             const Padding(
               padding: EdgeInsets.symmetric(horizontal: 16),
               child: Text("You haven't joined any forums yet."),
             )
          else
            SizedBox(
              height: 160,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ForumCard(
                    data: data[index]
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          
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
          
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3, 
            itemBuilder: (context, index) {
              return ThreadPostCard(
                title: "Diskusi Hangat #${index + 1}",
                userName: "User ${index + 1}",
                timeAgo: "${index + 1}h ago",
                content: "Ini adalah contoh konten thread...",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(List<ForumData> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No new forums to explore."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ForumCard(
          data: data[index]
        );
      },
    );
  }

  Widget _buildMyForumTab(List<ForumData> data) {
    if (data.isEmpty) {
      return const Center(child: Text("You haven't created any forums."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ForumCard(
            data: data[index],
            myForum: true,
          ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryCommunity,
            ),
          ),
          if (onSeeMore != null)
            TextButton(
              onPressed: onSeeMore,
              child: const Text(
                "See More",
                style: TextStyle(color: AppColors.joinButtonCommunity),
              ),
            ),
        ],
      ),
    );
  }
}