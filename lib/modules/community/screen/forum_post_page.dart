import 'package:flutter/material.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/model/post.dart';
import 'package:netly_mobile/utils/colors.dart';
import 'package:netly_mobile/modules/community/widgets/thread_post_card.dart';
import 'package:netly_mobile/utils/helper.dart';

class ForumPostPage extends StatefulWidget {
  final ForumData forumData;

  const ForumPostPage({
    super.key, 
    required this.forumData
  });

  @override
  State<ForumPostPage> createState() => _ForumPostPageState();
}

class _ForumPostPageState extends State<ForumPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  late Future<List<PostData>> _threadPosts;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _threadPosts = fetchPosts(request);
  }


  Future<List<PostData>> fetchPosts(CookieRequest request) async {
    try {
      final String url = '$pathWeb/community/forum/post/${widget.forumData.id}/';
      final response = await request.get(url);
      PostResponse postResponse = PostResponse.fromJson(response);
    
      return postResponse.data;
    } catch (e) {
      debugPrint("Error fetching posts: $e");
      return [];
    }
    
    
  }

  Future<void> createPost(CookieRequest request) async {
    try {
      request.headers['X-Requested-With'] = 'XMLHttpRequest';
      final String url = '$pathWeb/community/create-post/${widget.forumData.id}/';
      
      final response = await request.post(url, {
          'header': _titleController.text,
          'content': _contentController.text,
      });

      if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Thread posted successfully!"),
              backgroundColor: Colors.green,
          ));
          
          _titleController.clear();
          _contentController.clear();
          FocusScope.of(context).unfocus();

        
          setState(() {
              _threadPosts = fetchPosts(request);
          });
      } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response['msg'] ?? "Failed to post thread."),
              backgroundColor: Colors.red,
          ));
      }
    } catch (e){
      debugPrint("Error creating posts: $e");
    }
    
  }

  

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    String currentUsername = "User";
    if (request.jsonData.isNotEmpty && 
        request.jsonData['userData'] != null && 
        request.jsonData['userData']['username'] != null) {
        currentUsername = request.jsonData['userData']['username'];
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundCommunity,
      appBar: AppBar(
        title: Text(
          widget.forumData.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              setState(() {
                _threadPosts = fetchPosts(request);
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$currentUsername&size=40&background=random'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title input
                        TextField(
                          controller: _titleController,
                          maxLength: 255,
                          decoration: const InputDecoration(
                            hintText: "Thread title...",
                            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black45),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimaryCommunity),
                        ),
                        // content / description input
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            hintText: "What's on your mind...",
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null, 
                          minLines: 1,
                        ),
                        const SizedBox(height: 16),
                        // post button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                                createPost(request);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Please fill in both title and content"),
                                    backgroundColor: Colors.red,
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.joinButtonCommunity, 
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            ),
                            child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  const Icon(Icons.tag, color: AppColors.textPrimaryCommunity),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Threads in ${widget.forumData.title}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryCommunity),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            FutureBuilder<List<PostData>>(
              future: _threadPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No threads yet. Be the first to post!", style: TextStyle(color: Colors.grey)),
                  ));
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data![index];
                        return ThreadPostCard(
                          idPost: post.id,
                          creatorId: post.user.id,
                          title: post.header,
                          content: post.content,
                          userName: post.user.username,
                          timeAgo: timeAgo(post.createdAt),
                          onDelete: () => setState(() {
                            _threadPosts = fetchPosts(request);
                          })
                        );
                      },
                    ),
                  );
                }
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}