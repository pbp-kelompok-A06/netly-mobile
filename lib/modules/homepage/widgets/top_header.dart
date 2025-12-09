import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:netly_mobile/utils/path_web.dart';

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

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "U"; 
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10), 
      
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello,", 
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 2), 
                  Text(
                    userName ?? "Guest User",
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.w800, 
                      color: Color(0xFF243153)
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (userProfileImage != null && userProfileImage!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: "$pathWeb/proxy-image/?url=${Uri.encodeComponent(userProfileImage!.startsWith('http') ? userProfileImage! : "$pathWeb/$userProfileImage")}",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF243153),
                            child: Center(
                              child: Text(
                                _getInitials(userName),
                                style: const TextStyle(color: Color(0xFFD7FC64), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF243153), 
                          child: Center(
                            child: Text(
                              _getInitials(userName),
                              style: const TextStyle(
                                color: Color(0xFFD7FC64), 
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), 

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: onSearchSubmitted,
                    style: const TextStyle(color: Color(0xFF243153), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Search courts...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF243153),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF243153).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
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
}