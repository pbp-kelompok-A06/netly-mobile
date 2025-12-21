import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/screen/forum_post_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/model/post.dart';
import 'package:netly_mobile/modules/community/widgets/forum_card.dart';
import 'package:netly_mobile/modules/community/widgets/thread_post_card.dart';
import 'package:netly_mobile/modules/community/widgets/forum_dialog.dart';
import 'package:netly_mobile/modules/community/widgets/forum_explore.dart';
import 'package:netly_mobile/modules/community/screen/forum_show_join_page.dart';
import 'package:netly_mobile/utils/colors.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/utils/helper.dart';

class ForumShowPage extends StatefulWidget {
  const ForumShowPage({super.key});

  @override
  State<ForumShowPage> createState() => _ForumShowPageState();
}

class _ForumShowPageState extends State<ForumShowPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Future<List<ForumData>> _fetchForums(CookieRequest request) async {
    request.headers['X-Requested-With'] = 'XMLHttpRequest';
    try {
      final response = await request.get('$pathWeb/community/');
      return ForumResponse.fromJson(response).data;
    } catch (e) {
      debugPrint("Error fetching forums: $e");
      return [];
    }
  }

  Future<List<PostData>> _fetchRecentPosts(CookieRequest request) async {
    try {
      final response = await request.get('$pathWeb/community/forum/post/recent/3/');
      return PostResponse.fromJson(response).data;
    } catch (e) {
      debugPrint("Error fetching posts: $e");
      return [];
    }
  }

  void _refreshPage(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: AppColors.backgroundCommunity,
      appBar: _buildAppBar(context),
      body: FutureBuilder<List<ForumData>>(
        future: _fetchForums(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada forum tersedia.'));
          }

          final allForums = snapshot.data!;
          final userId = request.jsonData['userData']?['id'] ?? -1;

          final joinedForums = allForums.where((f) => f.isMember ).toList();
          final exploreForums = allForums.where((f) => !(f.isMember )).toList();
          final myForums = allForums.where((f) => f.creatorId == userId).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHomeTab(joinedForums, allForums, request),
              _buildExploreTab(exploreForums),
              _buildMyForumTab(myForums),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Community",
        style: TextStyle(color: AppColors.textPrimaryCommunity, fontWeight: FontWeight.bold),
      ),
      actions: [
        // refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.grey),
          onPressed: _refreshPage,
        ),
        // create forum button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.grey),
          onPressed: () => _dialogCreateForum(context),
        ),
      ],
      // tabBar
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.joinButtonCommunity,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.joinButtonCommunity,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Home"),
          Tab(text: "Explore"),
          Tab(text: "My Forum"),
        ],
      ),
    );
  }

  Widget _buildHomeTab(List<ForumData> joinedData, List<ForumData> allForums, CookieRequest request) {
    return RefreshIndicator(
      onRefresh: () async => _refreshPage(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header joined forum
            _buildSectionHeader("Joined Forum", onSeeMore: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ForumJoined(data: joinedData)));
            }),
            // list of card joined forum
            _buildJoinedForumList(joinedData),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Recent Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // recent post list
            _buildRecentPostsList(request, allForums),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinedForumList(List<ForumData> data) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("You haven't joined any forums yet."),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ForumCard(
            data: data[index], 
            isListTab: true, 
            onRefresh: _refreshPage
          );
        }
      ),
    );
  }

  Widget _buildRecentPostsList(CookieRequest request, List<ForumData> allForums) {
    return FutureBuilder<List<PostData>>(
      future: _fetchRecentPosts(request),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("No new posts available."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final post = snapshot.data![index];
            return ThreadPostCard(
              idPost: post.id,
              creatorId: post.user.id,
              title: post.header,
              userName: post.user.username,
              timeAgo: timeAgo(post.createdAt),
              content: post.content,
              forumName: post.forumName,
              onDelete: () => setState(() {}),
              seePage: () {
                try {
                  final targetForum = allForums.firstWhere(
                    (f) => f.title == post.forumName
                  );
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ForumPostPage(forumData: targetForum)
                    )
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Forum details not found."))
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildExploreTab(List<ForumData> data){
    return ForumExplore(data: data, isExplore: true, onRefresh: _refreshPage);
  }

  Widget _buildMyForumTab(List<ForumData> data) {
    if (data.isEmpty){
      return const Center(child: Text("You haven't created any forums."));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ForumCard(
          data: data[index],
          myForum: true,
          onRefresh: _refreshPage,
        ),
      ),
    );
  }

  void _dialogCreateForum(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateForumDialog(onForumCreated: _refreshPage),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          if (onSeeMore != null)
            TextButton(
              onPressed: onSeeMore, 
              child: const Text("See More")
            ),
        ],
      ),
    );
  }
}