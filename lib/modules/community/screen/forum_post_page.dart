import 'package:flutter/material.dart';
import '../model/forum.dart';
import '../../../utils/colors.dart'; // Menggunakan constants yang baru
import '../widgets/thread_post_card.dart'; // Pastikan arahnya ke widget card yang baru

class ForumPostPage extends StatefulWidget {
  final ForumData forumData;

  const ForumPostPage({super.key, required this.forumData});

  @override
  State<ForumPostPage> createState() => _ForumPostPageState();
}

class _ForumPostPageState extends State<ForumPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
       
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
                  // Avatar
                  CircleAvatar(
                    backgroundColor: AppColors.gradientStartCommunity.withOpacity(0.2),
                    radius: 22,
                    child: const Text("ME", style: TextStyle(color: AppColors.gradientStartCommunity, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FORM BIKIN POST
                        // Input Judul
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: "Thread title...",
                            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black45),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimaryCommunity),
                        ),
                        // Input Isi
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
                        // Tombol Post
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_titleController.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Posting thread...")));
                                _titleController.clear();
                                _contentController.clear();
                                FocusScope.of(context).unfocus();
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

            // Header Feed
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
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ThreadPostCard(
                    title: "Diskusi hari ini",
                    content: "Apakah ada yang sudah mencoba fitur baru Flutter 3.24? Sepertinya performa Impeller makin bagus.",
                    userName: "BaruJoin",
                    timeAgo: "2h ago",
                    
                  ),
                  ThreadPostCard(
                    title: "Tanya soal State Management",
                    content: "Bingung milih antara Riverpod atau Bloc untuk project skala menengah. Ada saran?",
                    userName: "HaloDunia",
                    timeAgo: "5h ago",
                  
                  ),
                   ThreadPostCard(
                    title: "Showcase Project",
                    content: "Baru aja rilis aplikasi to-do list sederhana pake Clean Architecture. Cek github saya ya!",
                    userName: "DevPemula",
                    timeAgo: "1d ago",
                   
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}