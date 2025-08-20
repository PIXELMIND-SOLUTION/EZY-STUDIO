// import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
// import 'package:edit_ezy_project/providers/auth/register_provider.dart';
// import 'package:edit_ezy_project/providers/customer/customer_provider.dart';
// import 'package:edit_ezy_project/providers/festivals/date_time_provider.dart';
// import 'package:edit_ezy_project/providers/language/language_provider.dart';
// import 'package:edit_ezy_project/providers/navbar/navbar_provider.dart';
// import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
// import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
// import 'package:edit_ezy_project/providers/plans/plan_provider.dart';
// import 'package:edit_ezy_project/providers/posters/canva_poster_provider.dart';
// import 'package:edit_ezy_project/providers/posters/category_poster_provider.dart';
// import 'package:edit_ezy_project/providers/posters/getall_poster_provider.dart';
// import 'package:edit_ezy_project/providers/story/story_provider.dart';
// import 'package:edit_ezy_project/views/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (context) => AuthProvider(),
//         ),
//         ChangeNotifierProvider(create: (context)=>SignupProvider()),
//         ChangeNotifierProvider(create: (context)=>BottomNavbarProvider()),
//         ChangeNotifierProvider(create: (context)=>StoryProvider()),
//         ChangeNotifierProvider(create: (context)=>LanguageProvider()),
//         ChangeNotifierProvider(create: (context)=>CanvaPosterProvider()),
//         ChangeNotifierProvider(create: (context)=>DateTimeProvider()),
//         ChangeNotifierProvider(create: (context)=>MyPlanProvider()),
//         ChangeNotifierProvider(create: (context)=>CategoryPosterProvider()),
//         ChangeNotifierProvider(create: (context)=>PosterProvider()),
//         ChangeNotifierProvider(create: (context)=>GetAllPlanProvider()),
//         ChangeNotifierProvider(create: (context)=>CreateCustomerProvider()),
//         ChangeNotifierProvider(create: (context)=>PlanProvider())
  
//       ],
//       child: MaterialApp(
//         title: 'Edit Ezy App',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         ),
//         home: const SplashScreen(),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }





import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:edit_ezy_project/providers/auth/register_provider.dart';
import 'package:edit_ezy_project/providers/business/business_category_provider.dart';
import 'package:edit_ezy_project/providers/business/business_poster_provider.dart';
import 'package:edit_ezy_project/providers/customer/customer_provider.dart';
import 'package:edit_ezy_project/providers/festivals/date_time_provider.dart';
import 'package:edit_ezy_project/providers/invoices/invoice_provider.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/logo/logo_provider.dart';
import 'package:edit_ezy_project/providers/navbar/navbar_provider.dart';
import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
import 'package:edit_ezy_project/providers/plans/plan_provider.dart';
import 'package:edit_ezy_project/providers/posters/canva_poster_provider.dart';
import 'package:edit_ezy_project/providers/posters/category_poster_provider.dart';
import 'package:edit_ezy_project/providers/posters/getall_poster_provider.dart';
import 'package:edit_ezy_project/providers/redeem/redeem_provider.dart';
import 'package:edit_ezy_project/providers/story/report_story_provider.dart';
import 'package:edit_ezy_project/providers/story/story_provider.dart';
import 'package:edit_ezy_project/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme/theme_provider.dart';  // <-- import your ThemeProvider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavbarProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CanvaPosterProvider()),
        ChangeNotifierProvider(create: (_) => DateTimeProvider()),
        ChangeNotifierProvider(create: (_) => MyPlanProvider()),
        ChangeNotifierProvider(create: (_) => CategoryPosterProvider()),
        ChangeNotifierProvider(create: (_) => PosterProvider()),
        ChangeNotifierProvider(create: (_) => GetAllPlanProvider()),
        ChangeNotifierProvider(create: (_) => CreateCustomerProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_)=>RedeemProvider()) ,
        ChangeNotifierProvider(create: (_)=>BusinessCategoryProvider()),
        ChangeNotifierProvider(create: (_)=>BusinessPosterProvider()) ,
        ChangeNotifierProvider(create: (_)=>ProductInvoiceProvider()) ,
        ChangeNotifierProvider(create: (_)=>LogoProvider()),
        ChangeNotifierProvider(create: (_)=>ReportStoryProvider())
      ],
      child: Consumer<ThemeProvider>( // <-- listen to ThemeProvider
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Edit Ezy App',
            theme: ThemeData.light().copyWith(
              textTheme:
                  ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            darkTheme: ThemeData.dark().copyWith(
              textTheme:
                  ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
            ),
            themeMode: themeProvider.themeMode, // <-- apply mode here
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
