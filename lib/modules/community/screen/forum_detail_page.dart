import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';

class ForumDetailPage extends StatelessWidget {
  final Forum forum;

  const ForumDetailPage({super.key, required this.forum}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: forum.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
