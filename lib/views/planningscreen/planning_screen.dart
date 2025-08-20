
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/models/category_model.dart';
import 'package:edit_ezy_project/models/user_model.dart';
import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:edit_ezy_project/views/Birthday/birthday_greeting_screen.dart';
import 'package:edit_ezy_project/views/ai/ai_screen.dart';
import 'package:edit_ezy_project/views/auth/login_screen.dart';
import 'package:edit_ezy_project/views/auth/register_screen.dart';
import 'package:edit_ezy_project/views/backgroundremover/background_remover.dart';
import 'package:edit_ezy_project/views/brand/edit_brand.dart';
import 'package:edit_ezy_project/views/business/add_business_screen.dart';
import 'package:edit_ezy_project/views/caption/caption_screen.dart';
import 'package:edit_ezy_project/views/caption/whataspp_stickers.dart';
import 'package:edit_ezy_project/views/customer/add_customer.dart';
import 'package:edit_ezy_project/views/deleteaccount/delete_account_screen.dart';
import 'package:edit_ezy_project/views/invoices/create_invoice.dart';
import 'package:edit_ezy_project/views/profile/contact_us_screen.dart';
import 'package:edit_ezy_project/views/profile/profile_screen.dart';
import 'package:edit_ezy_project/views/referearn/refer_earn_screen.dart';
import 'package:edit_ezy_project/views/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanningScreen extends StatefulWidget {
  PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlaningDetailsScreenState();
}

class _PlaningDetailsScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  String phoneNumber = "";
  // String currentPlan = "Trail Plan";
  String mediaCredits = "100";
  String expiryDate = "Lifetime";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final CategoryModel poster = CategoryModel.fromJson({
    "_id": "682dab4ec3f68068cb9649ac",
    "name": "poster",
    "categoryName": "singing",
    "price": 500,
    "images": [
      "https://res.cloudinary.com/dokfnv3vy/image/upload/v1747823437/posters/okipr7ohkjcs3gccxhw4.png"
    ],
    "description": "songs",
    "size": "A4",
    "festivalDate": "2025-05-21",
    "inStock": true,
    "tags": [],
    "createdAt": "2025-05-21T10:30:38.165Z",
    "updatedAt": "2025-05-21T10:30:38.165Z",
    "__v": 0
  });

  Future<void> _loadUserData() async {
    final userData = await AuthPreferences.getUserData();
    if (userData != null) {
      setState(() {
        phoneNumber = userData.user?.mobile ?? phoneNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('refer_earn_modal_shown', false);

              await authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.orange,
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue[600],
          labelColor: Colors.blue[600],
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(text: 'Tools', icon: Icon(Icons.build_rounded, size: 20)),
            Tab(text: 'Account', icon: Icon(Icons.person_rounded, size: 20)),
            Tab(text: 'Support', icon: Icon(Icons.help_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildToolsTab(),
          _buildAccountTab(),
          _buildSupportTab(),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    final tools = [
      // {
      //   'title': 'Birthday Greetings',
      //   'subtitle': 'Create personalized birthday cards',
      //   'icon': Icons.cake_rounded,
      //   'color': Colors.pink[100],
      //   'iconColor': Colors.pink[600],
      //   'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BirthdayGreetingScreen())),

      // },
      // {
      //   'title': 'Brand Information',
      //   'subtitle': 'Manage your brand details',
      //   'icon': Icons.business_rounded,
      //   'color': Colors.blue[100],
      //   'iconColor': Colors.blue[600],
      //   'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditBrand())),
      // },
      {
        'title': 'Background Remover',
        'subtitle': 'Remove image backgrounds instantly',
        'icon': Icons.layers_clear_rounded,
        'color': Colors.green[100],
        'iconColor': Colors.green[600],
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BackgroundRemoverScreen())),
      },
      {
        'title': 'Caption Generator',
        'subtitle': 'Generate engaging captions',
        'icon': Icons.text_fields_rounded,
        'color': Colors.orange[100],
        'iconColor': Colors.orange[600],
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CaptionScreen())),
      },
      {
        'title': 'WhatsApp Stickers',
        'subtitle': 'Create custom stickers',
        'icon': Icons.sticky_note_2_rounded,
        'color': Colors.teal[100],
        'iconColor': Colors.teal[600],
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WhatasppStickers())),
      },
      // {
      //   'title': 'Auto Product Ads',
      //   'subtitle': 'Generate product advertisements',
      //   'icon': Icons.campaign_rounded,
      //   'color': Colors.purple[100],
      //   'iconColor': Colors.purple[600],
      //   'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => AutoProductScreen())),
      // },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: tool['onTap'] as VoidCallback,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: tool['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tool['icon'] as IconData,
                        color: tool['iconColor'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tool['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tool['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountTab() {
    final accountItems = [
      {
        'title': 'My Profile',
        'subtitle': 'Manage your personal information',
        'icon': Icons.person_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
      },
      // {
      //   'title': 'Settings',
      //   'subtitle': 'App preferences and configuration',
      //   'icon': Icons.settings_rounded,
      //   'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
      // },
      {
        'title': 'Refer & Earn',
        'subtitle': 'Invite friends and earn rewards',
        'icon': Icons.share_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferEarnScreen())),
      },
      {
        'title': 'Add Customers',
        'subtitle': 'Manage your customer database',
        'icon': Icons.person_add_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomer())),
      },
      {
        'title': 'Create Invoice',
        'subtitle': 'Generate professional invoices',
        'icon': Icons.receipt_long_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) =>CreateInvoiceScreen())),
      },
      {
        'title': 'Add Business',
        'subtitle': 'Register your business profile',
        'icon': Icons.business_center_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBusinessScreen())),
      },
      {
        'title': 'Delete Account',
        'subtitle': 'Permanently remove your account',
        'icon': Icons.delete_forever_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccountScreen())),
        'isDestructive': true,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User info card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phoneNumber.isNotEmpty ? phoneNumber : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Text(
                        //   currentPlan,
                        //   style: TextStyle(
                        //     color: Colors.white.withOpacity(0.9),
                        //     fontSize: 14,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildInfoCard('Media Credits', mediaCredits, Icons.photo_library_rounded),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: _buildInfoCard('Expires On', expiryDate, Icons.schedule_rounded),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),

        // Account options
        ...accountItems.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: item['onTap'] as VoidCallback,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['isDestructive'] == true ? Colors.red[600] : Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: item['isDestructive'] == true ? Colors.red[600] : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSupportTab() {
    final supportItems = [
      // {
      //   'title': 'How to Use',
      //   'subtitle': 'Learn about app features',
      //   'icon': Icons.help_outline_rounded,
      //   // 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanDetails())),
      // },
      {
        'title': 'Contact Us',
        'subtitle': 'Get in touch with our team',
        'icon': Icons.mail_outline_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen())),
      },
      // {
      //   'title': 'Partner With Us',
      //   'subtitle': 'Business partnership opportunities',
      //   'icon': Icons.handshake_rounded,
      //   // 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PartnerScreen())),
      // },
      // {
      //   'title': 'Rate App',
      //   'subtitle': 'Share your feedback on the store',
      //   'icon': Icons.star_rate_rounded,
      //   // 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => RateApp())),
      // },
      {
        'title': 'Chat with AI',
        'subtitle': 'Get instant help from our AI assistant',
        'icon': Icons.smart_toy_rounded,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AiScreen())),
      },
      {
        'title': 'Privacy Policy',
        'subtitle': 'How we protect your data',
        'icon': Icons.privacy_tip_rounded,
        'onTap': () => _launchUrl('https://ezystudio.onrender.com/privacy-and-policy'),
      },
      {
        'title': 'Terms & Conditions',
        'subtitle': 'App usage terms and conditions',
        'icon': Icons.description_rounded,
        'onTap': () => _launchUrl('https://ezystudio.onrender.com/terms-and-conditions'),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: supportItems.length,
      itemBuilder: (context, index) {
        final item = supportItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 1,
            shadowColor: Colors.black12,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: item['onTap'] as VoidCallback,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Extension remains the same
extension AuthProviderExtension on AuthProvider {
  static Future<LoginResponse?> getUserData() async {
    return await AuthPreferences.getUserData();
  }
}