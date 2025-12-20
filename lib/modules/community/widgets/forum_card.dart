import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/screen/forum_post_page.dart';
import 'package:netly_mobile/modules/community/widgets/forum_dialog.dart';
import 'package:netly_mobile/utils/colors.dart';
import 'package:netly_mobile/utils/path_web.dart';

class ForumCard extends StatelessWidget {
  final ForumData data;
  final bool myForum;
  final bool isListTab;
  final bool isJoined;
  final VoidCallback? onRefresh;

  const ForumCard({
    super.key,
    required this.data,
    this.myForum = false,
    this.onRefresh,
    this.isListTab = false,
    this.isJoined = true
  });

  Future<void> _handleDelete(BuildContext context, CookieRequest request) async {
    try {
      final response = await request.post('$pathWeb/community/delete-forum/${data.id}/', {});
      if (response['success'] == true && context.mounted) {
        onRefresh?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Forum deleted successfully!"), backgroundColor: Colors.green,),
          
        );
      }
    } catch (e){
      debugPrint("Error deleting forum: $e");
    }
  }

  Future<void> _handleJoinForum(BuildContext context, CookieRequest request) async {
    try{
      final response = await request.post('$pathWeb/community/join-forum/', {
        'id_forum': data.id
      });
      if(response['success'] == true){
        onRefresh?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully joined ${data.title}!"), backgroundColor: Colors.green,),
        );
      }
    } catch(e){
      debugPrint("Error joining forum: $e");
    }
  }

  Future<void> _handleLeaveForum(BuildContext context, CookieRequest request) async {
    try{
      final response = await request.post('$pathWeb/community/unjoin-forum/', {
        'id_forum': data.id
      });
      if(response['success'] == true){
        onRefresh?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully left ${data.title}!"), backgroundColor: Colors.green,),
        );
      }
    } catch(e){
      debugPrint("Error leaving forum: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return GestureDetector(
      onTap: () {
        if (data.isMember == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ForumPostPage(forumData: data)),
          );
        } else {
          _handleJoinForum(context, request);
        }
      },
      child: Container(
        
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:  AppColors.gradientStartCommunity,
         
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStartCommunity.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // action button if its forum that user created
                if (myForum || isJoined) 
                  _buildActionButtons(context, request),
              ],
            ),

            if(!isListTab)
              Expanded( 
                child: SingleChildScrollView( 
                  child: Text(
                    data.description,
                    style: const TextStyle(
                      color: AppColors.gradientEndCommunity, 
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

            if(isListTab)
              Text(
                data.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.gradientEndCommunity, fontSize: 12),
              ),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildButtonElements("${data.memberCount} Members"),
                _buildButtonElements(data.creatorName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CookieRequest request) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      padding: EdgeInsets.zero,
      
      onSelected: (String value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            builder: (_) => CreateForumDialog(
              forumId: data.id.toString(),
              initialTitle: data.title,
              initialDesc: data.description,
              isEdit: true,
              onForumCreated: () => onRefresh?.call(),
            ),
          );
        } else if (value == 'delete') {
          _handleDelete(context, request);
        } else if (value == 'leave'){
          _handleLeaveForum(context, request);
        }
      },
      
      itemBuilder: (BuildContext context) => [
        if(myForum)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: Colors.black54),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if(myForum || data.creatorId == request.jsonData['data']['id'])
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        if(isJoined && data.creatorId != request.jsonData['data']['id'])
        const PopupMenuItem<String>(
            value: 'leave',
            child: Row(
              children: [
                Icon(Icons.leave_bags_at_home, size: 18, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('Leave', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
        ),
      ],
    );
  }

  Widget _buildButtonElements(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}