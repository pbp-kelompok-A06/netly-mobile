import 'package:flutter/material.dart';
import 'package:netly_mobile/utils/colors.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ThreadPostCard extends StatelessWidget {
  final String idPost;
  final String creatorId;
  final String title;
  final String content;
  final String userName;
  final String timeAgo;
  final String forumName;
  final VoidCallback? onDelete;
  final VoidCallback? seePage;

  const ThreadPostCard({
    super.key,
    required this.idPost,
    required this.creatorId,
    required this.title,
    required this.content,
    required this.userName,
    required this.timeAgo,
    this.forumName = "",
    this.onDelete,
    this.seePage
  });

  Future<void> _handleDelete(BuildContext context, CookieRequest request) async {
    try {
      final response = await request.post('$pathWeb/community/delete-forum-post/$idPost/', {});
      if (response['success'] == true && context.mounted) {
        onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully!"), backgroundColor: Colors.green,),
        );
      }
    } catch (e){
      debugPrint("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // avatar user
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$userName&size=40&background=random'),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // thread title
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimaryCommunity,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      softWrap: true,  
                    ),
                    if (creatorId == request.jsonData['userData']['id'])
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _handleDelete(context, request);
                          }else if(value == 'more'){
                            seePage?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          if(seePage != null)
                          const PopupMenuItem(
                            value: 'more',
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app, color: Colors.black54, size: 20),
                                SizedBox(width: 8),
                                Text('See More', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete Post', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          
                        ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // check if forumName != '' (ini ada ketika di homepage community)
                        if(forumName != "")
                          const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text("•", style: TextStyle(color: Colors.grey)),
                          ),
                        
                        // check if forumName != '' (ini ada ketika di homepage community)
                        if(forumName != "")
                          Text(
                            "Forum: $forumName",
                            style: const TextStyle(
                              color: AppColors.textSecondaryCommunity,
                              fontSize: 12,
                            ),
                          ),
                      ]
                    ),
                    
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // username dari user 
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.joinButtonCommunity, 
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text("•", style: TextStyle(color: Colors.grey)),
                        ),
                        // datetime dari waktu pertama post sampai sekarang
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppColors.textSecondaryCommunity,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // threads content
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondaryCommunity,
              fontSize: 14,
              height: 1.5,
            ),
            softWrap: true,  
          ),
          
          
          const SizedBox(height: 16),
          
          
        ],
      ),
    );
  }

  
}