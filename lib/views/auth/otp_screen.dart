import 'dart:convert';
import 'dart:async';
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/models/otp_model.dart';
import 'package:edit_ezy_project/services/otp_service.dart';
import 'package:edit_ezy_project/views/auth/navbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String? mobile;
  
  const OtpScreen({super.key, this.mobile});

  @override
  _ScreenOtpState createState() => _ScreenOtpState();
}

class _ScreenOtpState extends State<OtpScreen> with TickerProviderStateMixin {
  String enteredPin = '';
  final SmsService _smsService = SmsService();
  bool _isResending = false;
  bool _isVerifying = false;
  
  // Timer for resend countdown
  Timer? _timer;
  int _resendCountdown = 30;
  bool _canResend = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });

    _pulseController.repeat(reverse: true);
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future verifyOtp(VerifyOtpRequest request) async {
    final url = Uri.parse('http://194.164.148.244:4061/api/users/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.tojson()),
      );
      return response;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<void> _verifyOtp() async {
    if (enteredPin.length != 4) {
      _showErrorSnackBar('Please enter a valid 4-digit OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final otpRequest = VerifyOtpRequest(otp: enteredPin);

    try {
      final response = await verifyOtp(otpRequest);
      if (response.statusCode == 200) {
        await AuthPreferences.setUserVerified();
        await AuthPreferences.isUserVerified();

        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Verification failed. Please try again.');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (widget.mobile == null || widget.mobile!.isEmpty) {
      _showErrorSnackBar('Mobile number not available. Please go back and try again.');
      return;
    }

    setState(() {
      _isResending = true;
    });

    final url = Uri.parse('http://194.164.148.244:4061/api/users/resend-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': widget.mobile!}),
      );
      
      if (response.statusCode == 200) {
        _showSuccessSnackBar('OTP sent successfully');
        setState(() {
          _canResend = false;
          _resendCountdown = 30;
          enteredPin = '';
        });
        _startResendTimer();
      } else {
        _showErrorSnackBar('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Network error. Please check your connection.');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your phone number has been verified successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavbarScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return "your phone number";
    if (phone.length >= 4) {
      return "****${phone.substring(phone.length - 4)}";
    }
    return phone;
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
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
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
                              
                              // Back Button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Logo/Icon with pulse animation
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: AnimatedContainer(
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
                                        Icons.sms_rounded,
                                        size: isKeyboardVisible ? 30 : 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              SizedBox(height: isKeyboardVisible ? 12 : 24),
                              
                              // Title
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: isKeyboardVisible ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                child: const Text('Verify Your Phone'),
                              ),
                              
                              if (!isKeyboardVisible) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Enter the 4-digit code sent to ${_formatPhoneNumber(widget.mobile)}',
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

                      // Form Section
                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // OTP Input Section
                                  const Text(
                                    'Enter Verification Code',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // PIN Input Field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF64748B).withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: PinCodeTextField(
                                      appContext: context,
                                      length: 4,
                                      obscureText: false,
                                      animationType: AnimationType.fade,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(12),
                                        fieldHeight: 56,
                                        fieldWidth: 56,
                                        borderWidth: 2,
                                        activeColor: const Color(0xFF6366F1),
                                        inactiveColor: const Color(0xFFE2E8F0),
                                        selectedColor: const Color(0xFF6366F1),
                                        activeFillColor: Colors.white,
                                        inactiveFillColor: Colors.white,
                                        selectedFillColor: Colors.white,
                                      ),
                                      enableActiveFill: true,
                                      animationDuration: const Duration(milliseconds: 300),
                                      backgroundColor: Colors.transparent,
                                      onChanged: (value) {
                                        setState(() {
                                          enteredPin = value;
                                        });
                                      },
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Verify Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: (_isVerifying || enteredPin.length != 4) ? null : _verifyOtp,
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
                                      child: _isVerifying
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Verifying...',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Text(
                                              'Verify Code',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  if (!isKeyboardVisible) ...[
                                    const SizedBox(height: 24),

                                    // Resend Section
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF64748B).withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Didn't receive the code?",
                                            style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          
                                          if (_canResend)
                                            TextButton(
                                              onPressed: _isResending ? null : _resendOtp,
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFF6366F1),
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                              child: _isResending
                                                  ? const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text("Sending..."),
                                                      ],
                                                    )
                                                  : const Text(
                                                      "Resend Code",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Resend in ${_resendCountdown}s",
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Security Info
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF10B981).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.shield_rounded,
                                            color: Color(0xFF10B981),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'We protect your privacy. Your phone number is secure.',
                                              style: TextStyle(
                                                color: const Color(0xFF059669),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),
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
}