import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:netly_mobile/utils/path_web.dart'; 

class CreateForumDialog extends StatefulWidget {
  final VoidCallback onForumCreated;
  final String? forumId;
  final String? initialTitle;
  final String? initialDesc;
  final bool isEdit;
  
  const CreateForumDialog({
    super.key, 
    required this.onForumCreated,
    this.isEdit = false,
    this.forumId,
    this.initialTitle,
    this.initialDesc
  });

  @override
  State<CreateForumDialog> createState() => _CreateForumDialogState();
}

class _CreateForumDialogState extends State<CreateForumDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
 
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? "");
    _descriptionController = TextEditingController(text: widget.initialDesc ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForum(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String url = widget.isEdit ? 'update-forum/${widget.forumId}' : 'create-forum';
      final response = await request.post(
       
        '$pathWeb/community/$url/', 
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
        },
      );

      String status = widget.isEdit ? 'update' : 'create';
      if (response['success'] == true) {

        if (!mounted) return;
        Navigator.pop(context); 
        widget.onForumCreated(); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Forum ${status}d successfully!"),
          backgroundColor: Colors.green,
        ));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['msg'] ?? "Failed to $status forum."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color headerColor = Color(0xFF2D2A70); 

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text( 
                    widget.isEdit ? 'Update a Forum' : 'Create a Forum',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextFormField(
                        controller: _titleController,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: "Enter forum title",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: headerColor, width: 2)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Title cannot be empty' : null,
                      ),
                      
                      const SizedBox(height: 24),

                      const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Write a short description...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: headerColor, width: 2)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Description cannot be empty' : null,
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => _submitForum(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: headerColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              
              
            ),
          ],
        ),
      ),
    );
  }
}