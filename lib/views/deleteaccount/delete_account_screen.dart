
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  bool _isDeleting = false;
  final TextEditingController _confirmController = TextEditingController();
  String _requiredConfirmation = 'DELETE';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });

    try {
      final userData = await AuthPreferences.getUserData();
      final token = await AuthPreferences.getToken();

      if (userData?.user?.id == null) {
        throw Exception('User ID not found in stored data');
      }

      final userId = userData!.user!.id;
      final url = Uri.parse('http://194.164.148.244:4061/api/users/delete-user/$userId');

      final response = await http
          .delete(url, headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        await AuthPreferences.clearUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Your account has been deleted successfully"),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        final errorMessage = _parseErrorMessage(response.body, response.statusCode);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to delete account: ${e.toString()}"),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _parseErrorMessage(String responseBody, int statusCode) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['message'] ??
          'HTTP $statusCode: ${errorData['error'] ?? 'Unknown error'}';
    } catch (e) {
      return 'HTTP $statusCode: Unable to delete account. Please try again.';
    }
  }

  void _onDeletePressed() {
    // Validate confirmation text
    if (_confirmController.text.trim().toUpperCase() != _requiredConfirmation) {
      setState(() {
        _errorText = 'Please type "$_requiredConfirmation" to confirm.';
      });
      return;
    }

    // Show final confirmation bottom-sheet style
    showModalBottomSheet(
      context: context,
      isDismissible: !_isDeleting,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Final confirmation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action will permanently remove your account and all associated data. This cannot be undone. Are you sure you want to proceed?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isDeleting ? null : () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _isDeleting
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                            _deleteAccount();
                          },
                    child: _isDeleting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Delete',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppText('delete_account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.red.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_forever, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Delete account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                          SizedBox(height: 6),
                          Text('Permanently remove your account and all related data. This action cannot be undone.'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bullet points
              // Card(
              //   elevation: 0,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: const [
              //         // Text('What will be removed', style: TextStyle(fontWeight: FontWeight.bold)),
              //         // SizedBox(height: 8),
              //         // _SimpleBullet(text: 'Your profile information and preferences'),
              //         // _SimpleBullet(text: 'Order history and saved items'),
              //         // _SimpleBullet(text: 'Messages and notifications'),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: 18),

              // Confirmation input
              // Text('Type "$_requiredConfirmation" to confirm', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: _requiredConfirmation,
                  errorText: _errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),

              const SizedBox(height: 20),

              // Danger action
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isDeleting ? null : _onDeletePressed,
                child: _isDeleting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Delete my account', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isDeleting ? null : () => Navigator.of(context).maybePop(),
                child: const Text('Cancel'),
              ),

              const SizedBox(height: 30),

              // Helpful footer
              Center(
                child: Text('If you have any issues, contact support before deleting your account.', style: theme.textTheme.bodySmall),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleBullet extends StatelessWidget {
  final String text;
  const _SimpleBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
