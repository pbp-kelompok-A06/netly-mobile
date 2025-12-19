import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/modules/auth/screen/login_page.dart';

class TopHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final Function(String) onSearchSubmitted;

  final String? userProfileImage;
  final String? userName;

  const TopHeader({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.onSearchSubmitted,
    this.userProfileImage,
    this.userName,
  });

  Future<void> _handleLogout(BuildContext context, CookieRequest request) async {
    final response = await request.logout("$pathWeb/logout-ajax/");

    if (context.mounted) {
      if (response['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF243153),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text("N", style: TextStyle(color: Color(0xFFD7FC64), fontWeight: FontWeight.bold, fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Hello,", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.0)),
                          const SizedBox(height: 2),
                          Text(
                            userName ?? "Guest",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF243153), height: 1.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                elevation: 2,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                constraints: const BoxConstraints.tightFor(width: 110),
                
                child: Container(
                  width: 45, height: 45,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ClipOval(
                    child: (userProfileImage != null && userProfileImage!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: "$pathWeb/proxy-image/?url=${Uri.encodeComponent(userProfileImage!.startsWith('http') ? userProfileImage! : "$pathWeb/$userProfileImage")}",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    height: 32,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.normal, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _handleLogout(context, request);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // === SEARCH BAR ===
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      onSearchSubmitted(value);
                      FocusScope.of(context).unfocus();
                    },
                    style: const TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      hintText: "Search courts...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.normal),
                      
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 24),
                        onPressed: () {
                          onSearchSubmitted(searchController.text);
                          FocusScope.of(context).unfocus();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      ),
                      
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 45, width: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF243153),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFF243153).withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFFD7FC64), size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF243153),
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFFD7FC64), size: 24),
      ),
    );
  }
}