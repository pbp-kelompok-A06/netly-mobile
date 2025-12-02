import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/model/forum.dart';
import 'package:netly_mobile/modules/community/model/post.dart';
import '../widgets/forum_card.dart';
import '../widgets/post_card.dart';

class ForumHomePage extends StatefulWidget {
  const ForumHomePage({super.key});

  @override
  State<ForumHomePage> createState() => _ForumHomePageState();
}

class _ForumHomePageState extends State<ForumHomePage> {

  final List<Forum> forums = [
    Forum(
      title: 'General Discussion',
      description: 'Diskusi umum tentang badminton',
      members: 245,
      gradientColors: [Color(0xFFF48FB1), Color(0xFFFF9E80)],
    ),
    Forum(
      title: 'Sports team finder',
      description: 'Main bareng, yuk!',
      members: 189,
      gradientColors: [Color(0xFF90CAF9), Color(0xFF64B5F6)],
    ),
  ];

  final List<Post> posts = [
    Post(
      title: 'Cara smash dengan baik',
      content: 'Bagaimana cara agar jago smash ',
      author: 'johndoe',
      time: '2 jam yang lalu',
      tags: ['General Discussion'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 16),
                  const Text('Joined Forum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...forums.map((forum) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ForumCard(forum: forum),
                  )),
                  const SizedBox(height: 24),

                  const Text('Explore Forum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...forums.map((forum) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ForumCard(forum: forum),
                  )),
                  const SizedBox(height: 24),

                  const Text('Newest Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...posts.map((post) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PostCard(post: post),
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
