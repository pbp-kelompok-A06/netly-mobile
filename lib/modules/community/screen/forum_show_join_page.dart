import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/widgets/forum_explore.dart';
import 'package:netly_mobile/utils/colors.dart';

class ForumJoined extends StatelessWidget {
  final List<ForumData> data;

  const ForumJoined({
    super.key,
    required this.data,

  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Joined Forum", style: TextStyle(color: AppColors.textPrimaryCommunity, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        
        
      ),

      body:  ForumExplore(data: data),
    );

  
  }
}