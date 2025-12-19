import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/widgets/forum_card.dart';

class ForumExplore extends StatelessWidget {
  final List<ForumData> data;
  final bool isExplore;
  final VoidCallback? onRefresh;
  const ForumExplore({
    super.key,
    required this.data,
    this.isExplore = false,
    this.onRefresh


  });
  
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text("No new forums to ${isExplore ? "explore" : "see"}."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        if(isExplore){
          return ForumCard(
            data: data[index],
            onRefresh: onRefresh,
            isJoined: false,
          );
        }
        return ForumCard(
          data: data[index],
          onRefresh: onRefresh,
        );
      },
    );
  }
}