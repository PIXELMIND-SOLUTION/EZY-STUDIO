// // ignore_for_file: use_build_context_synchronously
// import 'package:edit_ezy_project/controller/auth_controller.dart';
// import 'package:edit_ezy_project/views/auth/otp_screen.dart';
// import 'package:edit_ezy_project/views/auth/register_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<LoginScreen> with TickerProviderStateMixin {
//   final TextEditingController phoneController = TextEditingController();
//   final AuthController controller = AuthController();
//   String selectedCountryCode = '+91';
//   bool _isLoading = false;
  
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
    
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Start animations
//     _fadeController.forward();
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _slideController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     phoneController.dispose();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Container(
//             height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
//             padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20),
//             child: Column(
//               children: [
//                 // Header Section
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Color(0xFF6366F1),
//                           Color(0xFF8B5CF6),
//                           Color(0xFFF59E0B),
//                         ],
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 40),
                        
//                         // Logo/Icon
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.phone_android_rounded,
//                             size: 40,
//                             color: Colors.white,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 24),
                        
//                         // Title
//                         const Text(
//                           'Welcome Back!',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 8),
                        
//                         // Subtitle
//                         Text(
//                           'Sign in to continue creating amazing content',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.9),
//                             fontWeight: FontWeight.w300,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
                        
//                         const SizedBox(height: 40),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Form Section
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Phone Number Section
//                           const Text(
//                             'Phone Number',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1E293B),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 12),
                          
//                           // Phone Input Container
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: const Color(0xFFE2E8F0),
//                                 width: 1.5,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(0xFF64748B).withOpacity(0.1),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 // Country Code Dropdown
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                                   decoration: BoxDecoration(
//                                     border: Border(
//                                       right: BorderSide(
//                                         color: const Color(0xFFE2E8F0),
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                   ),
//                                   child: DropdownButton<String>(
//                                     value: selectedCountryCode,
//                                     items: const [
//                                       DropdownMenuItem(
//                                         value: '+91',
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Text('🇮🇳', style: TextStyle(fontSize: 18)),
//                                             SizedBox(width: 8),
//                                             Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
//                                           ],
//                                         ),
//                                       ),
//                                       DropdownMenuItem(
//                                         value: '+1',
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Text('🇺🇸', style: TextStyle(fontSize: 18)),
//                                             SizedBox(width: 8),
//                                             Text('+1', style: TextStyle(fontWeight: FontWeight.w600)),
//                                           ],
//                                         ),
//                                       ),
//                                       DropdownMenuItem(
//                                         value: '+44',
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Text('🇬🇧', style: TextStyle(fontSize: 18)),
//                                             SizedBox(width: 8),
//                                             Text('+44', style: TextStyle(fontWeight: FontWeight.w600)),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                     onChanged: (value) {
//                                       setState(() {
//                                         selectedCountryCode = value ?? '+91';
//                                       });
//                                     },
//                                     underline: const SizedBox(),
//                                     icon: const Icon(Icons.keyboard_arrow_down_rounded),
//                                     dropdownColor: Colors.white,
//                                   ),
//                                 ),
                                
//                                 // Phone Number Input
//                                 Expanded(
//                                   child: TextField(
//                                     controller: phoneController,
//                                     keyboardType: TextInputType.phone,
//                                     maxLength: 10,
//                                     autocorrect: false,
//                                     enableSuggestions: false,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                     ],
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: Color(0xFF1E293B),
//                                     ),
//                                     decoration: const InputDecoration(
//                                       hintText: 'Enter your phone number',
//                                       hintStyle: TextStyle(
//                                         color: Color(0xFF94A3B8),
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                       border: InputBorder.none,
//                                       contentPadding: EdgeInsets.all(16),
//                                       counterText: '',
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(height: 32),

//                           // Continue Button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 56,
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _handleContinue,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF6366F1),
//                                 foregroundColor: Colors.white,
//                                 elevation: 0,
//                                 shadowColor: Colors.transparent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 disabledBackgroundColor: const Color(0xFF94A3B8),
//                               ),
//                               child: _isLoading
//                                   ? const SizedBox(
//                                       width: 24,
//                                       height: 24,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Continue',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                             ),
//                           ),

//                           const SizedBox(height: 32),

//                           // Divider
//                           Row(
//                             children: [
//                               const Expanded(
//                                 child: Divider(
//                                   color: Color(0xFFE2E8F0),
//                                   thickness: 1,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                                 child: Text(
//                                   'or',
//                                   style: TextStyle(
//                                     color: const Color(0xFF64748B),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               const Expanded(
//                                 child: Divider(
//                                   color: Color(0xFFE2E8F0),
//                                   thickness: 1,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 24),

//                           // Sign Up Link
//                           Center(
//                             child: RichText(
//                               text: TextSpan(
//                                 text: "Don't have an account? ",
//                                 style: const TextStyle(
//                                   color: Color(0xFF64748B),
//                                   fontSize: 15,
//                                 ),
//                                 children: [
//                                   WidgetSpan(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => const RegisterScreen(),
//                                           ),
//                                         );
//                                       },
//                                       child: const Text(
//                                         'Sign Up',
//                                         style: TextStyle(
//                                           color: Color(0xFF6366F1),
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 40),

//                           // Security Info
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF6366F1).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: const Color(0xFF6366F1).withOpacity(0.2),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.security_rounded,
//                                   color: const Color(0xFF6366F1),
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     'Your phone number is secure and will only be used for verification.',
//                                     style: TextStyle(
//                                       color: const Color(0xFF475569),
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleContinue() async {
//     final mobile = phoneController.text.trim();
    
//     if (mobile.isEmpty) {
//       _showErrorSnackBar("Please enter a mobile number");
//       return;
//     }

//     if (mobile.length < 10) {
//       _showErrorSnackBar("Please enter a valid mobile number");
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final isSuccess = await controller.loginUser(context, mobile);
      
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });

//         if (isSuccess) {
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => OtpScreen(mobile: mobile),
//           //   ),
//           // );
//         } else {
//           _showErrorSnackBar("Login Failed. Please Register First");
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         _showErrorSnackBar("Something went wrong. Please try again.");
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFEF4444),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }




















// ignore_for_file: use_build_context_synchronously
import 'package:edit_ezy_project/controller/auth_controller.dart';
import 'package:edit_ezy_project/views/auth/otp_screen.dart';
import 'package:edit_ezy_project/views/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final AuthController controller = AuthController();
  String selectedCountryCode = '+91';
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header Section - Flexible height based on keyboard visibility
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                                Color(0xFFF59E0B),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: isKeyboardVisible ? 20 : 40),
                              
                              // Logo/Icon - Smaller when keyboard is visible
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isKeyboardVisible ? 60 : 80,
                                height: isKeyboardVisible ? 60 : 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  size: isKeyboardVisible ? 30 : 40,
                                  color: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: isKeyboardVisible ? 12 : 24),
                              
                              // Title - Smaller when keyboard is visible
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: isKeyboardVisible ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                child: const Text('Welcome Back!'),
                              ),
                              
                              if (!isKeyboardVisible) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue creating amazing content',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              
                              SizedBox(height: isKeyboardVisible ? 20 : 40),
                            ],
                          ),
                        ),
                      ),

                      // Form Section - Expanded to fill remaining space
                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Phone Number Section
                                  const Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Phone Input Container
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF64748B).withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Country Code Dropdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Color(0xFFE2E8F0),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            value: selectedCountryCode,
                                            items: const [
                                              DropdownMenuItem(
                                                value: '+91',
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                                    SizedBox(width: 8),
                                                    Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
                                              // DropdownMenuItem(
                                              //   value: '+1',
                                              //   child: Row(
                                              //     mainAxisSize: MainAxisSize.min,
                                              //     children: [
                                              //       Text('🇺🇸', style: TextStyle(fontSize: 18)),
                                              //       SizedBox(width: 8),
                                              //       Text('+1', style: TextStyle(fontWeight: FontWeight.w600)),
                                              //     ],
                                              //   ),
                                              // ),
                                              // DropdownMenuItem(
                                              //   value: '+44',
                                              //   child: Row(
                                              //     mainAxisSize: MainAxisSize.min,
                                              //     children: [
                                              //       Text('🇬🇧', style: TextStyle(fontSize: 18)),
                                              //       SizedBox(width: 8),
                                              //       Text('+44', style: TextStyle(fontWeight: FontWeight.w600)),
                                              //     ],
                                              //   ),
                                              // ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCountryCode = value ?? '+91';
                                              });
                                            },
                                            underline: const SizedBox(),
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                            dropdownColor: Colors.white,
                                          ),
                                        ),
                                        
                                        // Phone Number Input
                                        Expanded(
                                          child: TextField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            maxLength: 10,
                                            autocorrect: false,
                                            enableSuggestions: false,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: 'Enter your phone number',
                                              hintStyle: TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontWeight: FontWeight.w400,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(16),
                                              counterText: '',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Continue Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleContinue,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        disabledBackgroundColor: const Color(0xFF94A3B8),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  // Spacer to push content up when keyboard is visible
                                  if (!isKeyboardVisible) ...[
                                    const SizedBox(height: 32),

                                    // Divider
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            color: Color(0xFFE2E8F0),
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'or',
                                            style: TextStyle(
                                              color: const Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            color: Color(0xFFE2E8F0),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                    // Sign Up Link
                                    Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Don't have an account? ",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 15,
                                          ),
                                          children: [
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const RegisterScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    color: Color(0xFF6366F1),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 40),

                                    // Security Info
                                    // Container(
                                    //   padding: const EdgeInsets.all(16),
                                    //   decoration: BoxDecoration(
                                    //     color: const Color(0xFF6366F1).withOpacity(0.1),
                                    //     borderRadius: BorderRadius.circular(12),
                                    //     border: Border.all(
                                    //       color: const Color(0xFF6366F1).withOpacity(0.2),
                                    //       width: 1,
                                    //     ),
                                    //   ),
                                    //   child: Row(
                                    //     children: [
                                    //       const Icon(
                                    //         Icons.security_rounded,
                                    //         color: Color(0xFF6366F1),
                                    //         size: 20,
                                    //       ),
                                    //       const SizedBox(width: 12),
                                    //       // Expanded(
                                    //       //   child: Text(
                                    //       //     'Your phone number is secure and will only be used for verification.',
                                    //       //     style: TextStyle(
                                    //       //       color: const Color(0xFF475569),
                                    //       //       fontSize: 13,
                                    //       //       fontWeight: FontWeight.w500,
                                    //       //     ),
                                    //       //   ),
                                    //       // ),
                                    //     ],
                                    //   ),
                                    // ),

                                    const SizedBox(height: 24),
                                  ] else ...[
                                    // When keyboard is visible, add minimal spacing
                                    SizedBox(height: keyboardHeight > 0 ? 20 : 0),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    final mobile = phoneController.text.trim();
    
    if (mobile.isEmpty) {
      _showErrorSnackBar("Please enter a mobile number");
      return;
    }

    if (mobile.length < 10) {
      _showErrorSnackBar("Please enter a valid mobile number");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isSuccess = await controller.loginUser(context, mobile);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (isSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(mobile: mobile),
            ),
          );
        } else {
          _showErrorSnackBar("Login Failed. Please Register First");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar("Something went wrong. Please try again.");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}