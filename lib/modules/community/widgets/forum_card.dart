import 'package:flutter/material.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../model/forum.dart';
import '../../../utils/colors.dart';
import '../screen/forum_post_page.dart'; 

class ForumCard extends StatelessWidget {
  final ForumData data;
  final bool myForum;
  final VoidCallback? onDelete; 

  const ForumCard({
    super.key,
    required this.data,
    this.myForum = false,
    this.onDelete
  });

  Future<bool> deleteForum(CookieRequest request) async{
    request.headers['X-Requested-With'] = 'XMLHttpRequest';
    final response = await request.post(
      '$pathWeb/community/delete-forum/${data.id}/', 
      {}
    );

    if(response['success'] == true){
      return true;
    }
    return false;

  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); 

    return GestureDetector(
      onTap: () {
        // check user is part of member of forum or not
        if(data.isMember == true){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForumPostPage(forumData: data)),
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text('You are not a member of ${data.title}!'),
            backgroundColor: Colors.red,
        ));
        }
       
      },
      // forum card
      child: Container(
        width: 200, 
        height: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStartCommunity, AppColors.gradientEndCommunity],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStartCommunity.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // details of Forum
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
          children: [
            // Title Forum
            Row(
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                if (myForum)
                  Row(
                    children: [
                      // Edit Icon
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Edit clicked"))
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                      
                      // Delete Icon
                      InkWell(
                        onTap: () async {
                          await deleteForum(request);
                          if (onDelete != null){
                            onDelete!(); 
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Delete successfully!"))
                          );
                          
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                        ),
                      ),
                    ]
                  )
                ] 
            ),
            // Description Forum
            Text(
              data.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            // Jumlah Member and Creator Name
            Row(
              children: [
                // Jumlah member
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: 
                      Text(
                        "${data.memberCount} Members",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ), 
                ),
                const SizedBox(width: 2.5),
                // Nama Creator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: 
                      Text(
                        data.creatorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ), 
                ),

                
                
              ],
            ),
            
              
            
            
          ],
        ),
      ),
    );
  }
}