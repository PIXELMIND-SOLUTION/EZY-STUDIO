// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HoroscopeScreen extends StatefulWidget {
//   const HoroscopeScreen({super.key});

//   @override
//   State<HoroscopeScreen> createState() => _HoroscopeScreenState();
// }

// class _HoroscopeScreenState extends State<HoroscopeScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _scaleController;
//   late AnimationController _rotateController;
  
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotateAnimation;

//   String selectedSign = 'leo';
//   int selectedIndex = 4; // Default to Leo
//   Map<String, dynamic>? horoscopeData;
//   bool isLoading = false;

//   final List<Map<String, dynamic>> zodiacSigns = [
//     {
//       'name': 'Aries',
//       'apiName': 'aries',
//       'symbol': '♈',
//       'dates': 'Mar 21 - Apr 19',
//       'element': 'Fire',
//       'color': Colors.red,
//       'description': 'Bold and ambitious, Aries dives headfirst into even the most challenging situations.',
//     },
//     {
//       'name': 'Taurus',
//       'apiName': 'taurus',
//       'symbol': '♉',
//       'dates': 'Apr 20 - May 20',
//       'element': 'Earth',
//       'color': Colors.green,
//       'description': 'Smart, ambitious, and trustworthy, Taurus is the anchor of the Zodiac.',
//     },
//     {
//       'name': 'Gemini',
//       'apiName': 'gemini',
//       'symbol': '♊',
//       'dates': 'May 21 - Jun 20',
//       'element': 'Air',
//       'color': Colors.yellow,
//       'description': 'Playful and intellectually curious, Gemini is constantly juggling a variety of passions.',
//     },
//     {
//       'name': 'Cancer',
//       'apiName': 'cancer',
//       'symbol': '♋',
//       'dates': 'Jun 21 - Jul 22',
//       'element': 'Water',
//       'color': Colors.blue,
//       'description': 'Deeply intuitive and sentimental, Cancer can be one of the most challenging signs to get to know.',
//     },
//     {
//       'name': 'Leo',
//       'apiName': 'leo',
//       'symbol': '♌',
//       'dates': 'Jul 23 - Aug 22',
//       'element': 'Fire',
//       'color': Colors.orange,
//       'description': 'Bold, intelligent, warm, and courageous, Leo is a natural leader.',
//     },
//     {
//       'name': 'Virgo',
//       'apiName': 'virgo',
//       'symbol': '♍',
//       'dates': 'Aug 23 - Sep 22',
//       'element': 'Earth',
//       'color': Colors.brown,
//       'description': 'Logical, practical, and systematic, Virgo is the perfectionist of the zodiac.',
//     },
//     {
//       'name': 'Libra',
//       'apiName': 'libra',
//       'symbol': '♎',
//       'dates': 'Sep 23 - Oct 22',
//       'element': 'Air',
//       'color': Colors.pink,
//       'description': 'Diplomatic and fair-minded, Libra is obsessed with symmetry and balance.',
//     },
//     {
//       'name': 'Scorpio',
//       'apiName': 'scorpio',
//       'symbol': '♏',
//       'dates': 'Oct 23 - Nov 21',
//       'element': 'Water',
//       'color': Colors.deepPurple,
//       'description': 'Passionate, stubborn, and resourceful, Scorpio is one of the most dynamic signs.',
//     },
//     {
//       'name': 'Sagittarius',
//       'apiName': 'sagittarius',
//       'symbol': '♐',
//       'dates': 'Nov 22 - Dec 21',
//       'element': 'Fire',
//       'color': Colors.teal,
//       'description': 'Curious and energetic, Sagittarius is one of the biggest travelers among all zodiac signs.',
//     },
//     {
//       'name': 'Capricorn',
//       'apiName': 'capricorn',
//       'symbol': '♑',
//       'dates': 'Dec 22 - Jan 19',
//       'element': 'Earth',
//       'color': Colors.indigo,
//       'description': 'Responsible and disciplined, Capricorn is a sign that represents time and responsibility.',
//     },
//     {
//       'name': 'Aquarius',
//       'apiName': 'aquarius',
//       'symbol': '♒',
//       'dates': 'Jan 20 - Feb 18',
//       'element': 'Air',
//       'color': Colors.cyan,
//       'description': 'Progressive, original, and independent, Aquarius is a humanitarian at heart.',
//     },
//     {
//       'name': 'Pisces',
//       'apiName': 'pisces',
//       'symbol': '♓',
//       'dates': 'Feb 19 - Mar 20',
//       'element': 'Water',
//       'color': Colors.purple,
//       'description': 'Compassionate, artistic, and intuitive, Pisces are known for their wisdom.',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
    
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
    
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
    
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
    
//     _rotateController = AnimationController(
//       duration: const Duration(seconds: 20),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
//     );
    
//     _rotateAnimation = Tween<double>(begin: 0, end: 2).animate(
//       CurvedAnimation(parent: _rotateController, curve: Curves.linear),
//     );

//     // Start animations
//     Future.delayed(const Duration(milliseconds: 200), () {
//       _fadeController.forward();
//     });
    
//     Future.delayed(const Duration(milliseconds: 400), () {
//       _slideController.forward();
//     });
    
//     Future.delayed(const Duration(milliseconds: 600), () {
//       _scaleController.forward();
//     });
    
//     _rotateController.repeat();

//     // Fetch initial horoscope data
//     _fetchHoroscope(zodiacSigns[selectedIndex]['apiName']);
//   }

//   Future<void> _fetchHoroscope(String sign) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://194.164.148.244:4061/api/users/horoscope?sign=$sign'),
//       );
  

//       print('horror scope status code ${response.statusCode}');
//       if (response.statusCode == 200) {
//         setState(() {
//           horoscopeData = json.decode(response.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           horoscopeData = {
//             'horoscope': 'Failed to load horoscope. Please try again later.'
//           };
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         horoscopeData = {
//           'horoscope': 'Error fetching horoscope: $e'
//         };
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _scaleController.dispose();
//     _rotateController.dispose();
//     super.dispose();
//   }

//   void _selectSign(int index) {
//     setState(() {
//       selectedIndex = index;
//       selectedSign = zodiacSigns[index]['apiName'];
//     });
    
//     // Restart animations for new selection
//     _scaleController.reset();
//     _scaleController.forward();
    
//     // Fetch new horoscope data
//     _fetchHoroscope(zodiacSigns[index]['apiName']);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedSignData = zodiacSigns[selectedIndex];
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF1a1a2e),
//               const Color(0xFF16213e),
//               selectedSignData['color'].withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   child: Row(
//                     children: [
//                       AnimatedBuilder(
//                         animation: _rotateAnimation,
//                         builder: (context, child) {
//                           return Transform.rotate(
//                             angle: _rotateAnimation.value * 3.14159,
//                             child: Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     Colors.white.withOpacity(0.3),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.auto_awesome,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(width: 15),
//                       const Text(
//                         'Horoscope',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               // Zodiac Signs Selector
//               SlideTransition(
//                 position: _slideAnimation,
//                 child: Container(
//                   height: 100,
//                   margin: const EdgeInsets.symmetric(vertical: 10),
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: zodiacSigns.length,
//                     itemBuilder: (context, index) {
//                       final sign = zodiacSigns[index];
//                       final isSelected = index == selectedIndex;
                      
//                       return GestureDetector(
//                         onTap: () => _selectSign(index),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.only(right: 15),
//                           padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: isSelected 
//                                 ? sign['color'].withOpacity(0.2)
//                                 : Colors.white.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: isSelected 
//                                   ? sign['color']
//                                   : Colors.white.withOpacity(0.3),
//                               width: 2,
//                             ),
//                             boxShadow: isSelected ? [
//                               BoxShadow(
//                                 color: sign['color'].withOpacity(0.3),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ] : null,
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 sign['symbol'],
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   color: isSelected ? sign['color'] : Colors.white,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 sign['name'],
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: isSelected ? sign['color'] : Colors.white70,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
              
//               // Main Content
//               Expanded(
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: Container(
//                     margin: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.2),
//                         width: 1,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(25),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Sign Header
//                           Row(
//                             children: [
//                               Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: RadialGradient(
//                                     colors: [
//                                       selectedSignData['color'],
//                                       selectedSignData['color'].withOpacity(0.5),
//                                     ],
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     selectedSignData['symbol'],
//                                     style: const TextStyle(
//                                       fontSize: 28,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       selectedSignData['name'],
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     Text(
//                                       selectedSignData['dates'],
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.white.withOpacity(0.7),
//                                       ),
//                                     ),
//                                     Container(
//                                       margin: const EdgeInsets.only(top: 5),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 3,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: selectedSignData['color'].withOpacity(0.3),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Text(
//                                         selectedSignData['element'],
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: selectedSignData['color'],
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
                          
//                           const SizedBox(height: 30),
                          
//                           // Description
//                           Text(
//                             'About ${selectedSignData['name']}',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             selectedSignData['description'],
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white.withOpacity(0.8),
//                               height: 1.5,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 25),
                          
//                           // Today's Prediction
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   selectedSignData['color'].withOpacity(0.2),
//                                   selectedSignData['color'].withOpacity(0.1),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: selectedSignData['color'].withOpacity(0.3),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       color: selectedSignData['color'],
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       horoscopeData != null 
//                                           ? 'Horoscope for ${horoscopeData!['date'] ?? 'today'}'
//                                           : 'Today\'s Prediction',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 isLoading
//                                     ? const Center(
//                                         child: CircularProgressIndicator(),
//                                       )
//                                     : Text(
//                                         horoscopeData != null
//                                             ? horoscopeData!['horoscope'] ?? 'No horoscope available'
//                                             : 'Loading...',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white.withOpacity(0.9),
//                                           height: 1.5,
//                                         ),
//                                       ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



















import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  String selectedSign = 'leo';
  int selectedIndex = 4; // Default to Leo
  Map<String, dynamic>? horoscopeData;
  bool isLoading = false;

  final List<Map<String, dynamic>> zodiacSigns = [
    {
      'name': 'Aries',
      'apiName': 'aries',
      'symbol': '♈',
      'dates': 'Mar 21 - Apr 19',
      'element': 'Fire',
      'color': const Color(0xFFE74C3C),
      'gradient': [const Color(0xFFE74C3C), const Color(0xFFF39C12)],
      'description': 'Bold and ambitious, Aries dives headfirst into even the most challenging situations.',
    },
    {
      'name': 'Taurus',
      'apiName': 'taurus',
      'symbol': '♉',
      'dates': 'Apr 20 - May 20',
      'element': 'Earth',
      'color': const Color(0xFF27AE60),
      'gradient': [const Color(0xFF27AE60), const Color(0xFF2ECC71)],
      'description': 'Smart, ambitious, and trustworthy, Taurus is the anchor of the Zodiac.',
    },
    {
      'name': 'Gemini',
      'apiName': 'gemini',
      'symbol': '♊',
      'dates': 'May 21 - Jun 20',
      'element': 'Air',
      'color': const Color(0xFFF1C40F),
      'gradient': [const Color(0xFFF1C40F), const Color(0xFFE67E22)],
      'description': 'Playful and intellectually curious, Gemini is constantly juggling a variety of passions.',
    },
    {
      'name': 'Cancer',
      'apiName': 'cancer',
      'symbol': '♋',
      'dates': 'Jun 21 - Jul 22',
      'element': 'Water',
      'color': const Color(0xFF3498DB),
      'gradient': [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      'description': 'Deeply intuitive and sentimental, Cancer can be one of the most challenging signs to get to know.',
    },
    {
      'name': 'Leo',
      'apiName': 'leo',
      'symbol': '♌',
      'dates': 'Jul 23 - Aug 22',
      'element': 'Fire',
      'color': const Color(0xFFE67E22),
      'gradient': [const Color(0xFFE67E22), const Color(0xFFF39C12)],
      'description': 'Bold, intelligent, warm, and courageous, Leo is a natural leader.',
    },
    {
      'name': 'Virgo',
      'apiName': 'virgo',
      'symbol': '♍',
      'dates': 'Aug 23 - Sep 22',
      'element': 'Earth',
      'color': const Color(0xFF8E44AD),
      'gradient': [const Color(0xFF8E44AD), const Color(0xFF9B59B6)],
      'description': 'Logical, practical, and systematic, Virgo is the perfectionist of the zodiac.',
    },
    {
      'name': 'Libra',
      'apiName': 'libra',
      'symbol': '♎',
      'dates': 'Sep 23 - Oct 22',
      'element': 'Air',
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFF9C27B0)],
      'description': 'Diplomatic and fair-minded, Libra is obsessed with symmetry and balance.',
    },
    {
      'name': 'Scorpio',
      'apiName': 'scorpio',
      'symbol': '♏',
      'dates': 'Oct 23 - Nov 21',
      'element': 'Water',
      'color': const Color(0xFF8E24AA),
      'gradient': [const Color(0xFF8E24AA), const Color(0xFF673AB7)],
      'description': 'Passionate, stubborn, and resourceful, Scorpio is one of the most dynamic signs.',
    },
    {
      'name': 'Sagittarius',
      'apiName': 'sagittarius',
      'symbol': '♐',
      'dates': 'Nov 22 - Dec 21',
      'element': 'Fire',
      'color': const Color(0xFF00BCD4),
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF009688)],
      'description': 'Curious and energetic, Sagittarius is one of the biggest travelers among all zodiac signs.',
    },
    {
      'name': 'Capricorn',
      'apiName': 'capricorn',
      'symbol': '♑',
      'dates': 'Dec 22 - Jan 19',
      'element': 'Earth',
      'color': const Color(0xFF3F51B5),
      'gradient': [const Color(0xFF3F51B5), const Color(0xFF2196F3)],
      'description': 'Responsible and disciplined, Capricorn is a sign that represents time and responsibility.',
    },
    {
      'name': 'Aquarius',
      'apiName': 'aquarius',
      'symbol': '♒',
      'dates': 'Jan 20 - Feb 18',
      'element': 'Air',
      'color': const Color(0xFF00BCD4),
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF03A9F4)],
      'description': 'Progressive, original, and independent, Aquarius is a humanitarian at heart.',
    },
    {
      'name': 'Pisces',
      'apiName': 'pisces',
      'symbol': '♓',
      'dates': 'Feb 19 - Mar 20',
      'element': 'Water',
      'color': const Color(0xFF9C27B0),
      'gradient': [const Color(0xFF9C27B0), const Color(0xFFE91E63)],
      'description': 'Compassionate, artistic, and intuitive, Pisces are known for their wisdom.',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });

    // Fetch initial horoscope data
    _fetchHoroscope(zodiacSigns[selectedIndex]['apiName']);
  }

  Future<void> _fetchHoroscope(String sign) async {
    setState(() {
      isLoading = true;
    });
    
    _shimmerController.repeat();

    try {
      final response = await http.get(
        Uri.parse('http://194.164.148.244:4061/api/users/horoscope?sign=$sign'),
      );

      if (response.statusCode == 200) {
        setState(() {
          horoscopeData = json.decode(response.body);
          isLoading = false;
        });
        _shimmerController.stop();
      } else {
        setState(() {
          isLoading = false;
          horoscopeData = {
            'horoscope': 'Unable to load your horoscope at the moment. Please try again later.'
          };
        });
        _shimmerController.stop();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        horoscopeData = {
          'horoscope': 'Connection error. Please check your internet and try again.'
        };
      });
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _selectSign(int index) {
    setState(() {
      selectedIndex = index;
      selectedSign = zodiacSigns[index]['apiName'];
    });
    
    // Restart animations for new selection
    _scaleController.reset();
    _scaleController.forward();
    
    // Fetch new horoscope data
    _fetchHoroscope(zodiacSigns[index]['apiName']);
  }

  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          height: 100,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSignData = zodiacSigns[selectedIndex];
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F0F23),
              const Color(0xFF1A1A2E),
              selectedSignData['color'].withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: selectedSignData['gradient'],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedSignData['color'].withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Horoscope',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Discover what the stars have in store',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Zodiac Signs Selector
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    height: 90,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: zodiacSigns.length,
                      itemBuilder: (context, index) {
                        final sign = zodiacSigns[index];
                        final isSelected = index == selectedIndex;
                        
                        return GestureDetector(
                          onTap: () => _selectSign(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                  ? LinearGradient(colors: sign['gradient'])
                                  : null,
                              color: isSelected 
                                  ? null
                                  : const Color(0xFF1E1E3A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.transparent
                                    : const Color(0xFF2A2A4A),
                                width: 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: sign['color'].withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ] : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sign['symbol'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sign['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.7),
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
              
              // Main Content
              SliverToBoxAdapter(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2A2A4A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sign Header
                          Row(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: selectedSignData['gradient'],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: selectedSignData['color'].withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    selectedSignData['symbol'],
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedSignData['name'],
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedSignData['dates'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            selectedSignData['color'].withOpacity(0.2),
                                            selectedSignData['color'].withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedSignData['color'].withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${selectedSignData['element']} Element',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: selectedSignData['color'],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Description Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F0F23),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A4A),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: selectedSignData['color'],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'About ${selectedSignData['name']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  selectedSignData['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.6,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Today's Prediction
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  selectedSignData['color'].withOpacity(0.1),
                                  selectedSignData['color'].withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedSignData['color'].withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: selectedSignData['gradient'],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Today\'s Horoscope',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (horoscopeData != null && horoscopeData!['date'] != null)
                                            Text(
                                              horoscopeData!['date'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.6),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (isLoading)
                                  Column(
                                    children: [
                                      _buildShimmerLoading(),
                                      const SizedBox(height: 12),
                                      const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    horoscopeData != null
                                        ? horoscopeData!['horoscope'] ?? 'No horoscope available at the moment.'
                                        : 'Loading your cosmic insights...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.6,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
