import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class ThreadPostCard extends StatelessWidget {
  final String title;
  final String content;
  final String userName;
  final String timeAgo;
  final String forumName;

  const ThreadPostCard({
    super.key,
    required this.title,
    required this.content,
    required this.userName,
    required this.timeAgo,
    this.forumName = ""
  });

  @override
  Widget build(BuildContext context) {
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
              // Avatar
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
                    // Thread Title
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimaryCommunity,
                          ),
                        ),
                        if(forumName != "")
                        const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text("•", style: TextStyle(color: Colors.grey)),
                        ),
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
                    // User info & post timeAgo
                    Row(
                      children: [
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
          
          // Threads content
          Text(
            content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondaryCommunity,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          
        ],
      ),
    );
  }

  
}