import 'dart:convert';
import 'dart:ui';
import 'package:edit_ezy_project/helper/modal_preferences.dart';
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/models/canva_poster_model.dart';
import 'package:edit_ezy_project/models/category_model.dart';
import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:edit_ezy_project/providers/festivals/date_time_provider.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
import 'package:edit_ezy_project/providers/posters/canva_poster_provider.dart';
import 'package:edit_ezy_project/providers/posters/getall_poster_provider.dart';
import 'package:edit_ezy_project/providers/story/story_provider.dart';
import 'package:edit_ezy_project/views/ai/ai_screen.dart';
import 'package:edit_ezy_project/views/planningscreen/planning_screen.dart';
import 'package:edit_ezy_project/views/poster/poster_making_screen.dart';
import 'package:edit_ezy_project/views/referearn/refer_earn_screen.dart';
import 'package:edit_ezy_project/views/story/stories_widget.dart';
import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
import 'package:edit_ezy_project/widgets/date_selctor_widget.dart';
import 'package:edit_ezy_project/widgets/home_courosel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marquee/marquee.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<CategoryModel> items = [];
  final String imageUrl =
      "https://fntarizona.com/wp-content/uploads/2017/05/shutterstock_624472886.jpg";

  bool serchValue = false;

  int _currentIndex = 0;
  String? posterId;
  String? currentUserId;
  String? username;
  String? userImage;
  String? userId;
  String? _savedImageBase64;

  Map<String, dynamic> birthdayData = {};
  Map<String, dynamic> anniversaryData = {};



  

  Locale _locale = const Locale('en');

  bool _isLoading = false;

  List<dynamic> festivaldata = [];
  List<dynamic> posterdata = [];
  List<dynamic> canvaposter = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;
  String _searchText = '';

  // late stt.SpeechToText _speech;
  List<dynamic> _filteredCategories = [];
  List<dynamic> _filteredNewposters = [];

  // late final CategoryProviderr categoryprovider;
  late final CanvaPosterProvider canvaPosterProvider;
  late final MyPlanProvider myplanprovider;
  Map<String, List<Map<String, dynamic>>> _categorizedPosters = {};

  // Animation controllers
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('language_code') ?? 'en';

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  static bool _hasShownReferAndEarnModal = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUser();
    _loadUserData();
    _loadSavedLanguage();
    _loadSavedProfileImage();
    _fetchnewposters();
    // _speech = stt.SpeechToText();
    // _initializeSpeech();
    _loadUserId();

    Future.microtask(() {
      final posterProvider = Provider.of<PosterProvider>(context, listen: false);
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

      posterProvider.fetchPosters().then((_) {
        print('Fetch posters completed - poster count: ${posterProvider.posters.length}');
      });

      storyProvider.fetchStories().then((_) {
        print('Fetch stories completed - story count: ${storyProvider.stories.length}');

        if (!_hasShownReferAndEarnModal) {
          showReferAndEarnModal(context);
          _hasShownReferAndEarnModal = true;
        }

        // categoryprovider = Provider.of<CategoryProviderr>(context, listen: false);
        canvaPosterProvider = Provider.of<CanvaPosterProvider>(context, listen: false);

        myPlanProvider.fetchMyPlan(userId.toString()).then((_) {
          print('Fetch MyPlan completed - isPurchase: ${myPlanProvider.isPurchase}');
          print('Subscribed Plan: ${myPlanProvider.subscribedPlan?.name ?? 'None'}');

          if (myPlanProvider.isPurchase) {
            print('User has an active subscription');
          } else {
            print('User does not have an active subscription');
            showSubscriptionModal(context);
          }
        }).catchError((error) {
          print('Error fetching MyPlan: $error');
          showSubscriptionModal(context);
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFestivalPosters(context.read<DateTimeProvider>().selectedDate);
      _startAnimations();
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutQuart),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutBack));

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimationController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _searchController.dispose();
    // _speech.stop();
    super.dispose();
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imageString = prefs.getString('profile_image');
    if (imageString != null && imageString.isNotEmpty) {
      setState(() {
        _savedImageBase64 = imageString;
      });
    }
  }

  void _showReferEarnModalIfNeeded() async {
    final hasShownReferEarnModal = await ModalPreferences.hasShownReferEarnModal();

    if (!hasShownReferEarnModal) {
      showReferAndEarnModal(context);
      await ModalPreferences.setReferEarnModalShown();
    }
  }

  Future<void> _initializeUser() async {
    final userData = await AuthPreferences.getUserData();
    if (userData != null && userData.user.id != null) {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);

      storyProvider.setCurrentUser(
        userId: userData.user.id,
        userImage: userData.user.profileImage,
        username: userData.user.name ?? '',
      );

      storyProvider.fetchStories();
    }
  }



  Future<void> _fetchnewposters() async {
    try {
      final canvaPosterProvider = Provider.of<CanvaPosterProvider>(context, listen: false);
      await canvaPosterProvider.fetchPosters();

      setState(() {
        canvaposter = canvaPosterProvider.posters;
      });

      print('Canva posters fetched: ${canvaposter.length}');
    } catch (e) {
      print('Error fetching canva posters: $e');
    }
  }
  Future<void> _loadUserData() async {
    final userData = await AuthPreferences.getUserData();
    print(userData);
    if (userData != null && userData.user != null) {
      setState(() {
        userId = userData.user.id;
      });
      print('User ID: $userId');
    } else {
      print("No User ID");
    }
  }

  Future<void> _loadUserId() async {
    try {
      final userData = await AuthPreferences.getUserData();
      if (userData != null) {
        setState(() {
          username = userData.user.name;
          currentUserId = userData.user.id;
        });

        final response = await http.get(
          Uri.parse('http://194.164.148.244:4061/api/users/wishes/$currentUserId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            birthdayData = Map<String, dynamic>.from(data);
            anniversaryData = Map<String, dynamic>.from(data);
          });
        } else {
          print('Failed to load birthday data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error loading user ID or birthday data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _fetchFestivalPosters(DateTime date) async {
    setState(() {
      _isLoading = true;
      festivaldata = [];
    });

    try {
      final response = await http.post(
        Uri.parse('http://194.164.148.244:4061/api/poster/festival'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'festivalDate': _formatDate(date)}),
      );

      if (response.statusCode == 200) {
        festivaldata = jsonDecode(response.body);
        setState(() {
          festivaldata = festivaldata;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

          final posterProvider = Provider.of<PosterProvider>(context);
              final posters = posterProvider.posters;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchFestivalPosters(context.read<DateTimeProvider>().selectedDate);
            await _fetchnewposters();
          },
          color: const Color(0xFF6366F1),
          child: CustomScrollView(
            slivers: [
              // Professional Header
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: _buildModernHeader(),
                  ),
                ),
              ),

              // Animated Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: Column(
                    children: [
                      _buildWishesSection(),
                      const SizedBox(height: 24),
                      _buildFeaturedCarousel(),
                      const SizedBox(height: 32),
                      _buildStoriesSection(),
                      const SizedBox(height: 32),
                      _buildUpcomingFestivalsSection(),
                      const SizedBox(height: 32),
                      _buildFestivalPostersSection(),
                      const SizedBox(height: 32),
                      _buildPremiumTemplatesSection(),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Section
          Expanded(
            child: Row(
              children: [
                Hero(
                  tag: 'profile_avatar',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PlanningScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final imageUrl = authProvider.user?.user.profileImage;
                          return CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? const Icon(Icons.person, color: Color(0xFF667EEA), size: 30)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        username ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              _buildHeaderActionButton(
                icon: Icons.memory,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AiScreen()));

                }
                
              ),
              const SizedBox(width: 12),
              _buildHeaderActionButton(
                icon: Icons.attach_money,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ReferEarnScreen()));
                }
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildWishesSection() {
    if (birthdayData['wishes'] == null || birthdayData['wishes'].isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF7CD), Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDE68A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 24,
              child: Marquee(
                text: birthdayData['wishes'].join("  •  "),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA16207),
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 50.0,
                velocity: 40.0,
                pauseAfterRound: const Duration(seconds: 2),
                startPadding: 10.0,
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Column(
      children: [
        // _buildSectionHeader(
        //   title: 'Featured Templates',
        //   subtitle: 'Trending designs for you',
        // ),
        const SizedBox(height: 16),
        const HomeCarousel(),
      ],
    );
  }

  Widget _buildStoriesSection() {
    return Column(
      children: [
        _buildSectionHeader(
          title: 'Moments',
          subtitle: '',
        ),
        const SizedBox(height: 16),
        const StoriesWidget(),
      ],
    );
  }

  Widget _buildUpcomingFestivalsSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          _buildSectionHeader(
            title: 'Seasonal Celebrations',
            subtitle: 'Never miss a celebration',
          ),
          const SizedBox(height: 16),
          Consumer<DateTimeProvider>(
            builder: (context, dateTimeProvider, _) {
              return DateSelectorRow(
                selectedDate: dateTimeProvider.selectedDate,
                onDateSelected: (date) {
                  dateTimeProvider.setStartDate(date);
                  _fetchFestivalPosters(date);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalPostersSection() {
    return Column(
      children: [
        _buildSectionHeader(
          title: 'Celebration Templates',
          subtitle: 'Perfect for every occasion',
          showViewAll: true,
          onViewAll: () {
            // Navigate to all festivals
          },
        ),
        const SizedBox(height: 16),
        _buildFestivalPostersGrid(),
      ],
    );
  }

  Widget _buildFestivalPostersGrid() {
    if (_isLoading) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    // if (festivaldata.isEmpty) {
    //   return Container(
    //     height: 200,
    //     margin: const EdgeInsets.symmetric(horizontal: 20),
    //     padding: const EdgeInsets.all(32),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(16),
    //       border: Border.all(color: const Color(0xFFE5E7EB)),
    //     ),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         // Container(
    //         //   padding: const EdgeInsets.all(16),
    //         //   decoration: BoxDecoration(
    //         //     color: const Color(0xFF6366F1).withOpacity(0.1),
    //         //     shape: BoxShape.circle,
    //         //   ),
    //         //   child: const Icon(
    //         //     Icons.event_busy,
    //         //     size: 32,
    //         //     color: Color(0xFF6366F1),
    //         //   ),
    //         // ),
    //         // const SizedBox(height: 16),
    //         const Text(
    //           'No festivals found',
    //           style: TextStyle(
    //             fontSize: 16,
    //             fontWeight: FontWeight.w600,
    //             color: Color(0xFF374151),
    //           ),
    //         ),
    //         const SizedBox(height: 4),
    //         Text(
    //           'Try selecting a different date',
    //           style: TextStyle(
    //             fontSize: 14,
    //             color: const Color(0xFF6B7280),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    if (festivaldata.isEmpty) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade50,
                      Colors.white,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, iconValue, child) {
                        return Transform.rotate(
                          angle: iconValue * 0.1,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.calendar_view_month_outlined,
                              size: 24,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Celebration Found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try to select  different date ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: festivaldata.length,
        itemBuilder: (context, index) {
          final poster = festivaldata[index];
          return _buildFestivalPosterCard(poster, index);
        },
      ),
    );
  }

  Widget _buildFestivalPosterCard(dynamic poster, int index) {

        final posterProvider = Provider.of<PosterProvider>(context);

     final posters = posterProvider.posters;
    return Consumer<MyPlanProvider>(
      builder: (context, myPlanProvider, child) {
        return Container(
          width: 160,
          margin: EdgeInsets.only(
            right: 16,
            left: index == 0 ? 0 : 0,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (myPlanProvider.isPurchase == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SamplePosterScreen(
                        posterId: poster['_id'] ?? poster['id'],
                      ),
                    ),
                  );
                } else {
                  _showPremiumDialog();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          color: const Color(0xFFF3F4F6),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            poster['images'][0],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Color(0xFF9CA3AF),
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poster['categoryName'] ?? 'Festival',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (!myPlanProvider.isPurchase) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                              const Icon(
                                Icons.trending_up,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildPremiumTemplatesSection() {
    return Column(
      children: [
        _buildSectionHeader(
          title: 'Premium Templates',
          subtitle: 'Professional designs',
          showViewAll: false,
          onViewAll: () {
            // Navigate to all premium templates
          },
        ),
        const SizedBox(height: 16),
        Consumer<CanvaPosterProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
              );
            }

            if (provider.error != null) {
              return Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load templates',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => provider.fetchPosters(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.posters.isEmpty) {
              return Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No templates available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group posters by category for better organization
            Map<String, List<CanvasPosterModel>> categorizedPosters = {};
            for (var poster in provider.posters) {
              String category = poster.categoryName.isEmpty ? 'Other' : poster.categoryName;
              if (!categorizedPosters.containsKey(category)) {
                categorizedPosters[category] = [];
              }
              categorizedPosters[category]!.add(poster);
            }

            return Column(
              children: categorizedPosters.entries.take(3).map((entry) {
                return _buildCategorySection(entry.key, entry.value);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(String categoryName, List<CanvasPosterModel> posters) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DetailsScreen(category: categoryName),
                  //   ),
                  // );
                },
                // icon: const Icon(
                //   Icons.arrow_forward_ios,
                //   size: 16,
                //   color: Color(0xFF6366F1),
                // ),
                label: const Text(
                  '',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: posters.length,
            itemBuilder: (context, index) {
              return _buildPremiumPosterCard(posters[index], index);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  Widget _buildPremiumPosterCard(CanvasPosterModel poster, int index) {
  return Consumer<MyPlanProvider>(
    builder: (context, myPlanProvider, child) {
      return Container(
        width: 170,
        margin: EdgeInsets.only(right: 16, left: index == 0 ? 0 : 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (myPlanProvider.isPurchase == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SamplePosterScreen(posterId: poster.id),
                  ),
                );
              } else {
                _showPremiumDialog();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        color: const Color(0xFFF3F4F6),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(16),  // 👈 add these
    bottomRight: Radius.circular(16), // 👈 add these
  ),
                            child: Image.network(
                              poster.images.isNotEmpty ? poster.images[0] : '',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFF9CA3AF),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Show PRO badge if not purchased
                          if (!myPlanProvider.isPurchase)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFF6366F1),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Premium Feature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'This template requires a premium subscription. Upgrade now to unlock all premium features and templates!',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSubscriptionModal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
//   void showReferAndEarnModal(BuildContext context) {
//   String? userId;
//   String? userReferralCode;
//   bool isLoading = true;
//   String? errorMessage;

//   showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: 'Refer and Earn Modal',
//     barrierColor: Colors.black.withOpacity(0.7),
//     transitionDuration: const Duration(milliseconds: 500),
//     pageBuilder: (context, animation, secondaryAnimation) {
//       return const SizedBox.shrink();
//     },
//     transitionBuilder: (context, animation, secondaryAnimation, child) {
//       final curvedAnimation = CurvedAnimation(
//         parent: animation,
//         curve: Curves.easeOutBack,
//       );

//       return BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: 5 * animation.value,
//           sigmaY: 5 * animation.value,
//         ),
//         child: SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 0.3),
//             end: Offset.zero,
//           ).animate(curvedAnimation),
//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.7,
//               end: 1.0,
//             ).animate(curvedAnimation),
//             child: FadeTransition(
//               opacity: animation,
//               child: Center(
//                 child: Material(
//                   color: Colors.transparent,
//                   child: StatefulBuilder(
//                     builder: (context, setState) {
//                       // Initialize data loading
//                       Future<void> loadUserDataAndFetchReferralCode() async {
//                         try {
//                           setState(() {
//                             isLoading = true;
//                             errorMessage = null;
//                           });

//                           final userData = await AuthPreferences.getUserData();
//                           if (userData != null && userData.user != null) {
//                             userId = userData.user.id;

//                             if (userId != null) {
//                               final response = await http.get(
//                                 Uri.parse('http://194.164.148.244:4061/api/users/refferalcode/$userId'),
//                                 headers: {'Content-Type': 'application/json'},
//                               );

//                               if (response.statusCode == 200) {
//                                 final data = json.decode(response.body);
//                                 String? fetchedCode = data['referralCode'] ??
//                                     data['refferalCode'] ??
//                                     data['code'] ??
//                                     data['referral_code'] ??
//                                     data['refferal_code'];

//                                 setState(() {
//                                   isLoading = false;
//                                   userReferralCode = fetchedCode;
//                                   errorMessage = fetchedCode == null ? 'No referral code found' : null;
//                                 });
//                               } else {
//                                 setState(() {
//                                   userReferralCode = null;
//                                   errorMessage = 'Failed to load referral code';
//                                   isLoading = false;
//                                 });
//                               }
//                             } else {
//                               setState(() {
//                                 userReferralCode = null;
//                                 errorMessage = 'User ID is null';
//                                 isLoading = false;
//                               });
//                             }
//                           } else {
//                             setState(() {
//                               userReferralCode = null;
//                               errorMessage = 'User data not found';
//                               isLoading = false;
//                             });
//                           }
//                         } catch (e) {
//                           setState(() {
//                             userReferralCode = null;
//                             errorMessage = 'Network error: ${e.toString()}';
//                             isLoading = false;
//                           });
//                         }
//                       }

//                       // Initialize loading
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (isLoading && userReferralCode == null && errorMessage == null) {
//                           loadUserDataAndFetchReferralCode();
//                         }
//                       });

//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 20),
//                         constraints: BoxConstraints(
//                           maxHeight: MediaQuery.of(context).size.height * 0.85,
//                           maxWidth: 420,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.18),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 // Header with animated gift icon
//                                 Container(
//                                   decoration: const BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
//                                     child: Row(
//                                       children: [
//                                         // Subtle floating animation using TweenAnimationBuilder
//                                         TweenAnimationBuilder<double>(
//                                           tween: Tween(begin: 0.0, end: 1.0),
//                                           duration: const Duration(seconds: 2),
//                                           curve: Curves.easeInOut,
//                                           builder: (context, value, child) {
//                                             final translateY = (0.6 - (value - 0.5).abs()) * -6; // small up-down
//                                             final scale = 0.96 + (value * 0.04);
//                                             return Transform.translate(
//                                               offset: Offset(0, translateY),
//                                               child: Transform.scale(scale: scale, child: child),
//                                             );
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.all(12),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.18),
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: const Icon(
//                                               Icons.card_giftcard,
//                                               color: Colors.white,
//                                               size: 26,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 14),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: const [
//                                               Text(
//                                                 'Refer & Earn',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 2),
//                                               Text(
//                                                 'Share your code — both earn rewards',
//                                                 style: TextStyle(
//                                                   fontSize: 13,
//                                                   color: Colors.white70,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Material(
//                                           color: Colors.transparent,
//                                           child: InkWell(
//                                             borderRadius: BorderRadius.circular(20),
//                                             onTap: () => Navigator.pop(context),
//                                             child: Container(
//                                               padding: const EdgeInsets.all(8),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withOpacity(0.12),
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: const Icon(
//                                                 Icons.close,
//                                                 color: Colors.white,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 Padding(
//                                   padding: const EdgeInsets.all(22),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Earnings highlight
//                                       Container(
//                                         width: double.infinity,
//                                         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                             colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
//                                           ),
//                                           borderRadius: BorderRadius.circular(14),
//                                           border: Border.all(
//                                             color: const Color(0xFFF59E0B).withOpacity(0.25),
//                                           ),
//                                         ),
//                                         child: Row(
//                                           children: const [
//                                             Icon(Icons.monetization_on, color: Color(0xFFF59E0B), size: 30),
//                                             SizedBox(width: 12),
//                                             Expanded(
//                                               child: Text(
//                                                 'Earn ₹200 when a friend upgrades — you both win!',
//                                                 style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: Color(0xFF92400E),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),

//                                       const SizedBox(height: 22),

//                                       // Your referral code label
//                                       const Text(
//                                         'Your Referral Code',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF111827),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 12),

//                                       // AnimatedSwitcher for seamless state transitions (loading / error / code)
//                                       AnimatedSwitcher(
//                                         duration: const Duration(milliseconds: 350),
//                                         switchInCurve: Curves.easeOut,
//                                         switchOutCurve: Curves.easeIn,
//                                         child: isLoading
//                                             ? Container(
//                                                 key: const ValueKey('loading'),
//                                                 padding: const EdgeInsets.all(16),
//                                                 decoration: BoxDecoration(
//                                                   color: const Color(0xFFF9FAFB),
//                                                   borderRadius: BorderRadius.circular(12),
//                                                   border: Border.all(color: const Color(0xFFE5E7EB)),
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: const [
//                                                     SizedBox(
//                                                       width: 20,
//                                                       height: 20,
//                                                       child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
//                                                     ),
//                                                     SizedBox(width: 12),
//                                                     Text(
//                                                       'Loading your referral code...',
//                                                       style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               )
//                                             : (errorMessage != null)
//                                                 ? Container(
//                                                     key: const ValueKey('error'),
//                                                     padding: const EdgeInsets.all(14),
//                                                     decoration: BoxDecoration(
//                                                       color: const Color(0xFFFEF2F2),
//                                                       borderRadius: BorderRadius.circular(12),
//                                                       border: Border.all(color: const Color(0xFFFECACA)),
//                                                     ),
//                                                     child: Column(
//                                                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                                                       children: [
//                                                         Row(
//                                                           children: [
//                                                             const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
//                                                             const SizedBox(width: 8),
//                                                             Expanded(
//                                                               child: Text(
//                                                                 errorMessage!,
//                                                                 style: const TextStyle(fontSize: 14, color: Color(0xFFDC2626)),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         const SizedBox(height: 12),
//                                                         SizedBox(
//                                                           width: double.infinity,
//                                                           child: ElevatedButton.icon(
//                                                             onPressed: loadUserDataAndFetchReferralCode,
//                                                             style: ElevatedButton.styleFrom(
//                                                               backgroundColor: const Color(0xFFEF4444),
//                                                               foregroundColor: Colors.white,
//                                                               padding: const EdgeInsets.symmetric(vertical: 10),
//                                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                                             ),
//                                                             icon: const Icon(Icons.refresh, size: 16),
//                                                             label: const Text('Retry', style: TextStyle(fontSize: 14)),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   )
//                                                 : Container(
//                                                     key: const ValueKey('code'),
//                                                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//                                                     decoration: BoxDecoration(
//                                                       color: const Color(0xFFF9FAFB),
//                                                       borderRadius: BorderRadius.circular(12),
//                                                       border: Border.all(color: const Color(0xFFE5E7EB)),
//                                                     ),
//                                                     child: Row(
//                                                       children: [
//                                                         Expanded(
//                                                           child: Text(
//                                                             userReferralCode ?? '--',
//                                                             style: const TextStyle(
//                                                               fontSize: 18,
//                                                               fontWeight: FontWeight.bold,
//                                                               letterSpacing: 2,
//                                                               color: Color(0xFF4F46E5),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Material(
//                                                           color: Colors.transparent,
//                                                           child: InkWell(
//                                                             borderRadius: BorderRadius.circular(8),
//                                                             onTap: () {
//                                                               if (userReferralCode != null && userReferralCode!.isNotEmpty) {
//                                                                 Clipboard.setData(ClipboardData(text: userReferralCode!));
//                                                                 ScaffoldMessenger.of(context).showSnackBar(
//                                                                   const SnackBar(
//                                                                     content: Text('Referral code copied!'),
//                                                                     backgroundColor: Color(0xFF10B981),
//                                                                   ),
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: Container(
//                                                               padding: const EdgeInsets.all(8),
//                                                               decoration: BoxDecoration(
//                                                                 color: const Color(0xFF4F46E5),
//                                                                 borderRadius: BorderRadius.circular(8),
//                                                               ),
//                                                               child: const Icon(Icons.copy, color: Colors.white, size: 18),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                       ),

//                                       const SizedBox(height: 22),

//                                       // How it works
//                                       Container(
//                                         padding: const EdgeInsets.all(14),
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFF9FAFB),
//                                           borderRadius: BorderRadius.circular(12),
//                                           border: Border.all(color: const Color(0xFFE5E7EB)),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             const Text(
//                                               'How it works',
//                                               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
//                                             ),
//                                             const SizedBox(height: 10),
//                                             _buildHowItWorksStep('1', 'Share your code', 'Send your referral code to friends'),
//                                             const SizedBox(height: 8),
//                                             _buildHowItWorksStep('2', 'Friend signs up', 'They use your code during registration'),
//                                             const SizedBox(height: 8),
//                                             // _buildHowItWorksStep('3', 'Both earn rewards', 'You get ₹200 when they upgrade'),
//                                           ],
//                                         ),
//                                       ),

//                                       const SizedBox(height: 16),

//                                       // Primary CTA
//                                       // Row(
//                                       //   children: [
//                                       //     Expanded(
//                                       //       child: ElevatedButton.icon(
//                                       //         onPressed: () {
//                                       //           if (userReferralCode != null && userReferralCode!.isNotEmpty) {
//                                       //             // share intent or copy
//                                       //             Clipboard.setData(ClipboardData(text: userReferralCode!));
//                                       //             ScaffoldMessenger.of(context).showSnackBar(
//                                       //               const SnackBar(content: Text('Referral code copied — share it with friends!')),
//                                       //             );
//                                       //           } else {
//                                       //             // if no code yet, try reload
//                                       //             loadUserDataAndFetchReferralCode();
//                                       //           }
//                                       //         },
//                                       //         icon: const Icon(Icons.share_outlined,color: Colors.white,),
//                                       //         label:  Text('Share Code',style: TextStyle(color: Colors.white),),
//                                       //         style: ElevatedButton.styleFrom(
//                                       //           backgroundColor: const Color(0xFF4F46E5),
//                                       //           padding: const EdgeInsets.symmetric(vertical: 12),
//                                       //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                       //         ),
//                                       //       ),
//                                       //     ),
//                                       //     const SizedBox(width: 12),
//                                       //     // SizedBox(
//                                       //     //   width: 48,
//                                       //     //   height: 48,
//                                       //     //   child: OutlinedButton(
//                                       //     //     onPressed: () {
//                                       //     //       // quick retry
//                                       //     //       loadUserDataAndFetchReferralCode();
//                                       //     //     },
//                                       //     //     style: OutlinedButton.styleFrom(
//                                       //     //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                       //     //       side: BorderSide(color: Colors.grey.shade300),
//                                       //     //     ),
//                                       //     //     child: const Icon(Icons.refresh, size: 20),
//                                       //     //   ),
//                                       //     // )
//                                       //   ],
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         )
//       );
//       },
//     );

// }



void showReferAndEarnModal(BuildContext context) {
  String? userId;
  String? userReferralCode;
  bool isLoading = true;
  String? errorMessage;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Refer and Earn Modal',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setState) {
                  // Initialize data loading
                  Future<void> loadUserDataAndFetchReferralCode() async {
                    try {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      final userData = await AuthPreferences.getUserData();
                      if (userData != null && userData.user != null) {
                        userId = userData.user.id;

                        if (userId != null) {
                          final response = await http.get(
                            Uri.parse('http://194.164.148.244:4061/api/users/refferalcode/$userId'),
                            headers: {'Content-Type': 'application/json'},
                          );

                          if (response.statusCode == 200) {
                            final data = json.decode(response.body);
                            String? fetchedCode = data['referralCode'] ??
                                data['refferalCode'] ??
                                data['code'] ??
                                data['referral_code'] ??
                                data['refferal_code'];

                            setState(() {
                              isLoading = false;
                              userReferralCode = fetchedCode;
                              errorMessage = fetchedCode == null ? 'No referral code found' : null;
                            });
                          } else {
                            setState(() {
                              userReferralCode = null;
                              errorMessage = 'Failed to load referral code';
                              isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            userReferralCode = null;
                            errorMessage = 'User ID is null';
                            isLoading = false;
                          });
                        }
                      } else {
                        setState(() {
                          userReferralCode = null;
                          errorMessage = 'User data not found';
                          isLoading = false;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        userReferralCode = null;
                        errorMessage = 'Network error: ${e.toString()}';
                        isLoading = false;
                      });
                    }
                  }

                  // Initialize loading
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (isLoading && userReferralCode == null && errorMessage == null) {
                      loadUserDataAndFetchReferralCode();
                    }
                  });

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                      maxWidth: 400,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clean Header
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.people_outline,
                                    color: Color(0xFF3B82F6),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invite Friends',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Share your referral code',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Benefits Section
                                  // R

                                  const SizedBox(height: 24),

                                  // Your referral code section
                                  const Text(
                                    'Your Referral Code',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Code display with loading states
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoading
                                        ? Container(
                                            key: const ValueKey('loading'),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFF3B82F6),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Loading...',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : (errorMessage != null)
                                            ? Container(
                                                key: const ValueKey('error'),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF2F2),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: const Color(0xFFFECACA)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.error_outline,
                                                          color: Color(0xFFDC2626),
                                                          size: 18,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            errorMessage!,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Color(0xFFDC2626),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: loadUserDataAndFetchReferralCode,
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFFDC2626),
                                                          foregroundColor: Colors.white,
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                        child: const Text(
                                                          'Try Again',
                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                key: const ValueKey('code'),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF8FAFC),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            'Code:',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(0xFF64748B),
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            userReferralCode ?? '--',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 1,
                                                              color: Color(0xFF1E293B),
                                                              fontFamily: 'monospace',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ElevatedButton.icon(
                                                      onPressed: () {
                                                        if (userReferralCode != null && userReferralCode!.isNotEmpty) {
                                                          Clipboard.setData(ClipboardData(text: userReferralCode!));
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Code copied to clipboard'),
                                                              backgroundColor: Color(0xFF059669),
                                                              behavior: SnackBarBehavior.floating,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      icon: const Icon(Icons.copy, size: 16),
                                                      label: const Text('Copy'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFF3B82F6),
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        elevation: 0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                  ),

                                  const SizedBox(height: 24),

                                  // How it works - Simple and clean
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'How it works',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStep('1', 'Share your referral code with friends'),
                                        _buildStep('2', 'Friend signs up using your code'),
                                        _buildStep('3', 'Both receive referral benefits'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildStep(String number, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}

// helper widget used in the updated UI (kept in-file intentionally)



  Widget _buildHowItWorksStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showSubscriptionModal(BuildContext context) async {
    final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

    if (myPlanProvider.isPurchase == true) {
      return;
    }

    final hasShownRecently = await ModalPreferences.hasShownSubscriptionModal();
    final shouldShowAgain = await ModalPreferences.shouldShowSubscriptionModalAgain(daysBetween: 7);

    if (hasShownRecently && !shouldShowAgain) {
      print('Subscription modal shown recently, skipping');
      return;
    }

    final planProvider = Provider.of<GetAllPlanProvider>(context, listen: false);
    if (planProvider.plans.isEmpty && !planProvider.isLoading) {
      planProvider.fetchAllPlans();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription Modal',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4 * animation.value,
            sigmaY: 4 * animation.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      maxWidth: 500,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Modern header with updated gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Choose Your Plan',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Consumer<GetAllPlanProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF6366F1),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading plans...',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (provider.error != null) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Color(0xFFEF4444),
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Failed to load plans',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Please try again later',
                                            style: TextStyle(color: Color(0xFF6B7280)),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () => provider.fetchAllPlans(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6366F1),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Try Again'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (provider.plans.isNotEmpty) {
                                  return AnimatedPlanList(
                                    plans: provider.plans,
                                    onPlanSelected: (plan) {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => 
                                              PlanDetailsAndPaymentScreen(plan: plan),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;

                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration: const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.subscriptions,
                                        size: 60,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No subscription plans available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required LanguageProvider languageProvider,
  }) {
    final isSelected = languageProvider.locale.languageCode == languageCode;

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF),
      ),
      title: Text(
        languageName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF111827),
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF6366F1)) : null,
      onTap: () async {
        try {
          await languageProvider.setLocale(Locale(languageCode));

          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFF10B981),
                content: Text('Language changed successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('Error changing language: $e');
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFFEF4444),
                content: Text('Failed to change language'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }

  Widget buildCategoryWisePosters() {
    return Consumer<CanvaPosterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
                const SizedBox(height: 8),
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Color(0xFFEF4444)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchPosters(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.posters.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 40, color: Color(0xFF9CA3AF)),
                SizedBox(height: 8),
                Text(
                  'No posters available',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          );
        }

        Map<String, List<CanvasPosterModel>> categorizedPosters = {};
        for (var poster in provider.posters) {
          String category = poster.categoryName.isEmpty ? 'Other' : poster.categoryName;
          if (!categorizedPosters.containsKey(category)) {
            categorizedPosters[category] = [];
          }
          categorizedPosters[category]!.add(poster);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categorizedPosters.entries.map((entry) {
              String categoryName = entry.key;
              List<CanvasPosterModel> categoryPosters = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '${categoryPosters.length} items',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryPosters.length,
                      itemBuilder: (context, index) {
                        final poster = categoryPosters[index];
                        return buildPosterCard(context, poster);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget buildPosterCard(BuildContext context, CanvasPosterModel poster) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SamplePosterScreen(posterId: poster.id),
                  //   ),
                  // );
                },
                child: Image.network(
                  poster.images.isNotEmpty ? poster.images[0] : '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Color(0xFF9CA3AF),
                        size: 30,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    poster.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        poster.price == 0 ? 'Free' : '₹${poster.price}',
                        style: TextStyle(
                          fontSize: 11,
                          color: poster.price == 0 ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!poster.inStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Out',
                            style: TextStyle(
                              fontSize: 8,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}