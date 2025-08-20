// // common_modal.dart
// import 'package:flutter/material.dart';

// class CommonModal {
//   static void show({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     bool barrierDismissible = true,
//     Color? primaryColor,
//     IconData? icon,
//     ModalType modalType = ModalType.info,
//   }) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: Duration(milliseconds: 400),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return _AnimatedModal(
//           animation: animation,
//           title: title,
//           message: message,
//           primaryButtonText: primaryButtonText,
//           secondaryButtonText: secondaryButtonText,
//           onPrimaryPressed: onPrimaryPressed,
//           onSecondaryPressed: onSecondaryPressed,
//           primaryColor: primaryColor,
//           icon: icon,
//           modalType: modalType,
//         );
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, -1),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(
//             parent: animation,
//             curve: Curves.elasticOut,
//           )),
//           child: ScaleTransition(
//             scale: Tween<double>(
//               begin: 0.7,
//               end: 1.0,
//             ).animate(CurvedAnimation(
//               parent: animation,
//               curve: Curves.easeOutBack,
//             )),
//             child: FadeTransition(
//               opacity: animation,
//               child: child,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Convenience methods remain the same...
//   static void showSuccess({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     bool barrierDismissible = true,
//   }) {
//     show(
//       context: context,
//       title: title,
//       message: message,
//       primaryButtonText: primaryButtonText,
//       secondaryButtonText: secondaryButtonText,
//       onPrimaryPressed: onPrimaryPressed,
//       onSecondaryPressed: onSecondaryPressed,
//       barrierDismissible: barrierDismissible,
//       modalType: ModalType.success,
//       icon: Icons.check_circle_outline,
//     );
//   }

//   static void showError({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     bool barrierDismissible = true,
//   }) {
//     show(
//       context: context,
//       title: title,
//       message: message,
//       primaryButtonText: primaryButtonText,
//       secondaryButtonText: secondaryButtonText,
//       onPrimaryPressed: onPrimaryPressed,
//       onSecondaryPressed: onSecondaryPressed,
//       barrierDismissible: barrierDismissible,
//       modalType: ModalType.error,
//       icon: Icons.error_outline,
//     );
//   }

//   static void showWarning({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     bool barrierDismissible = true,
//   }) {
//     show(
//       context: context,
//       title: title,
//       message: message,
//       primaryButtonText: primaryButtonText,
//       secondaryButtonText: secondaryButtonText,
//       onPrimaryPressed: onPrimaryPressed,
//       onSecondaryPressed: onSecondaryPressed,
//       barrierDismissible: barrierDismissible,
//       modalType: ModalType.warning,
//       icon: Icons.warning_amber_outlined,
//     );
//   }

//   static void showInfo({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     bool barrierDismissible = true,
//   }) {
//     show(
//       context: context,
//       title: title,
//       message: message,
//       primaryButtonText: primaryButtonText,
//       secondaryButtonText: secondaryButtonText,
//       onPrimaryPressed: onPrimaryPressed,
//       onSecondaryPressed: onSecondaryPressed,
//       barrierDismissible: barrierDismissible,
//       modalType: ModalType.info,
//       icon: Icons.info_outline,
//     );
//   }

//   static ModalColorScheme _getColorScheme(ModalType type, Color? customColor) {
//     if (customColor != null) {
//       return ModalColorScheme(primary: customColor);
//     }

//     switch (type) {
//       case ModalType.success:
//         return ModalColorScheme(primary: Color(0xFF10B981));
//       case ModalType.warning:
//         return ModalColorScheme(primary: Color(0xFFF59E0B));
//       case ModalType.error:
//         return ModalColorScheme(primary: Color(0xFFEF4444));
//       case ModalType.info:
//       default:
//         return ModalColorScheme(primary: Color(0xFF3B82F6));
//     }
//   }
// }

// class _AnimatedModal extends StatefulWidget {
//   final Animation<double> animation;
//   final String title;
//   final String message;
//   final String? primaryButtonText;
//   final String? secondaryButtonText;
//   final VoidCallback? onPrimaryPressed;
//   final VoidCallback? onSecondaryPressed;
//   final Color? primaryColor;
//   final IconData? icon;
//   final ModalType modalType;

//   const _AnimatedModal({
//     required this.animation,
//     required this.title,
//     required this.message,
//     this.primaryButtonText,
//     this.secondaryButtonText,
//     this.onPrimaryPressed,
//     this.onSecondaryPressed,
//     this.primaryColor,
//     this.icon,
//     required this.modalType,
//   });

//   @override
//   _AnimatedModalState createState() => _AnimatedModalState();
// }

// class _AnimatedModalState extends State<_AnimatedModal>
//     with TickerProviderStateMixin {
//   late AnimationController _iconController;
//   late AnimationController _buttonController;
//   late AnimationController _pulseController;
//   late Animation<double> _iconScaleAnimation;
//   late Animation<double> _buttonSlideAnimation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     _iconController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
    
//     _buttonController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
    
//     _pulseController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _iconScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _iconController,
//       curve: Curves.elasticOut,
//     ));

//     _buttonSlideAnimation = Tween<double>(
//       begin: 50.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _buttonController,
//       curve: Curves.easeOutCubic,
//     ));

//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     // Start animations with delays
//     Future.delayed(Duration(milliseconds: 200), () {
//       if (mounted) _iconController.forward();
//     });
    
//     Future.delayed(Duration(milliseconds: 400), () {
//       if (mounted) _buttonController.forward();
//     });
    
//     Future.delayed(Duration(milliseconds: 600), () {
//       if (mounted) {
//         _pulseController.repeat(reverse: true);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _iconController.dispose();
//     _buttonController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = CommonModal._getColorScheme(widget.modalType, widget.primaryColor);
    
//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 20),
//           constraints: BoxConstraints(
//             maxWidth: 400,
//             minWidth: 320,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 20,
//                 spreadRadius: 0,
//                 offset: Offset(0, 10),
//               ),
//               BoxShadow(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 blurRadius: 40,
//                 spreadRadius: 0,
//                 offset: Offset(0, 20),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Animated Header
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       colorScheme.primary,
//                       colorScheme.primary.withOpacity(0.8),
//                       colorScheme.primary.withOpacity(0.9),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     if (widget.icon != null) ...[
//                       ScaleTransition(
//                         scale: _iconScaleAnimation,
//                         child: AnimatedBuilder(
//                           animation: _pulseAnimation,
//                           builder: (context, child) {
//                             return Transform.scale(
//                               scale: _pulseAnimation.value,
//                               child: Container(
//                                 padding: EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.white.withOpacity(0.3),
//                                       blurRadius: 10,
//                                       spreadRadius: 2,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   widget.icon,
//                                   size: 40,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                     ],
//                     SlideTransition(
//                       position: Tween<Offset>(
//                         begin: Offset(0, 0.3),
//                         end: Offset.zero,
//                       ).animate(CurvedAnimation(
//                         parent: widget.animation,
//                         curve: Interval(0.3, 1.0, curve: Curves.easeOut),
//                       )),
//                       child: FadeTransition(
//                         opacity: CurvedAnimation(
//                           parent: widget.animation,
//                           curve: Interval(0.3, 1.0),
//                         ),
//                         child: Text(
//                           widget.title,
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 0.5,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Animated Content
//               SlideTransition(
//                 position: Tween<Offset>(
//                   begin: Offset(0, 0.5),
//                   end: Offset.zero,
//                 ).animate(CurvedAnimation(
//                   parent: widget.animation,
//                   curve: Interval(0.5, 1.0, curve: Curves.easeOut),
//                 )),
//                 child: FadeTransition(
//                   opacity: CurvedAnimation(
//                     parent: widget.animation,
//                     curve: Interval(0.5, 1.0),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(32),
//                     child: Text(
//                       widget.message,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[700],
//                         height: 1.6,
//                         letterSpacing: 0.2,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ),
              
//               // Animated Action Buttons
//               AnimatedBuilder(
//                 animation: _buttonSlideAnimation,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(0, _buttonSlideAnimation.value),
//                     child: FadeTransition(
//                       opacity: CurvedAnimation(
//                         parent: _buttonController,
//                         curve: Curves.easeOut,
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
//                         child: Row(
//                           children: [
//                             if (widget.secondaryButtonText != null) ...[
//                               Expanded(
//                                 child: _AnimatedButton(
//                                   onPressed: widget.onSecondaryPressed ?? () => Navigator.of(context).pop(),
//                                   text: widget.secondaryButtonText!,
//                                   isSecondary: true,
//                                   color: colorScheme.primary,
//                                   delay: Duration(milliseconds: 100),
//                                 ),
//                               ),
//                               SizedBox(width: 16),
//                             ],
//                             if (widget.primaryButtonText != null)
//                               Expanded(
//                                 child: _AnimatedButton(
//                                   onPressed: widget.onPrimaryPressed ?? () => Navigator.of(context).pop(),
//                                   text: widget.primaryButtonText!,
//                                   isSecondary: false,
//                                   color: colorScheme.primary,
//                                   delay: Duration(milliseconds: 200),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AnimatedButton extends StatefulWidget {
//   final VoidCallback onPressed;
//   final String text;
//   final bool isSecondary;
//   final Color color;
//   final Duration delay;

//   const _AnimatedButton({
//     required this.onPressed,
//     required this.text,
//     required this.isSecondary,
//     required this.color,
//     required this.delay,
//   });

//   @override
//   _AnimatedButtonState createState() => _AnimatedButtonState();
// }

// class _AnimatedButtonState extends State<_AnimatedButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     setState(() => _isPressed = true);
//     _controller.forward();
//   }

//   void _handleTapUp(TapUpDetails details) {
//     setState(() => _isPressed = false);
//     _controller.reverse();
//   }

//   void _handleTapCancel() {
//     setState(() => _isPressed = false);
//     _controller.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: GestureDetector(
//         onTapDown: _handleTapDown,
//         onTapUp: _handleTapUp,
//         onTapCancel: _handleTapCancel,
//         onTap: widget.onPressed,
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           height: 48,
//           decoration: BoxDecoration(
//             gradient: widget.isSecondary
//                 ? null
//                 : LinearGradient(
//                     colors: [
//                       widget.color,
//                       widget.color.withOpacity(0.8),
//                     ],
//                   ),
//             color: widget.isSecondary ? Colors.transparent : null,
//             border: widget.isSecondary
//                 ? Border.all(
//                     color: widget.color.withOpacity(0.3),
//                     width: 2,
//                   )
//                 : null,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: widget.isSecondary
//                 ? null
//                 : [
//                     BoxShadow(
//                       color: widget.color.withOpacity(_isPressed ? 0.2 : 0.4),
//                       blurRadius: _isPressed ? 8 : 12,
//                       offset: Offset(0, _isPressed ? 2 : 6),
//                     ),
//                   ],
//           ),
//           child: Center(
//             child: Text(
//               widget.text,
//               style: TextStyle(
//                 color: widget.isSecondary ? widget.color : Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum ModalType { success, error, warning, info }

// class ModalColorScheme {
//   final Color primary;

//   ModalColorScheme({required this.primary});
// }















// common_modal.dart
import 'package:flutter/material.dart';

class CommonModal {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    Color? primaryColor,
    IconData? icon,
    ModalType modalType = ModalType.info,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _ModalContent(
            title: title,
            message: message,
            primaryButtonText: primaryButtonText,
            secondaryButtonText: secondaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            onSecondaryPressed: onSecondaryPressed,
            primaryColor: primaryColor,
            icon: icon,
            modalType: modalType,
          ),
        );
      },
    );
  }

  // Convenience methods
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      barrierDismissible: barrierDismissible,
      modalType: ModalType.success,
      icon: Icons.check_circle_outline,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      barrierDismissible: barrierDismissible,
      modalType: ModalType.error,
      icon: Icons.error_outline,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      barrierDismissible: barrierDismissible,
      modalType: ModalType.warning,
      icon: Icons.warning_amber_outlined,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      barrierDismissible: barrierDismissible,
      modalType: ModalType.info,
      icon: Icons.info_outline,
    );
  }

  static ModalColorScheme _getColorScheme(ModalType type, Color? customColor,BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    if (customColor != null) {
      return ModalColorScheme(
        primary: customColor,
        container: isDark ? Colors.grey[900]! : Colors.white,
        onContainer: isDark ? Colors.white : Colors.black87,
      );
    }

    switch (type) {
      case ModalType.success:
        return ModalColorScheme(
          primary: Color(0xFF388E3C),
          container: isDark ? Colors.grey[900]! : Colors.white,
          onContainer: isDark ? Colors.white : Colors.black87,
        );
      case ModalType.warning:
        return ModalColorScheme(
          primary: Color(0xFFF57C00),
          container: isDark ? Colors.grey[900]! : Colors.white,
          onContainer: isDark ? Colors.white : Colors.black87,
        );
      case ModalType.error:
        return ModalColorScheme(
          primary: Color(0xFFD32F2F),
          container: isDark ? Colors.grey[900]! : Colors.white,
          onContainer: isDark ? Colors.white : Colors.black87,
        );
      case ModalType.info:
      default:
        return ModalColorScheme(
          primary: Color(0xFF1976D2),
          container: isDark ? Colors.grey[900]! : Colors.white,
          onContainer: isDark ? Colors.white : Colors.black87,
        );
    }
  }
}

class _ModalContent extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Color? primaryColor;
  final IconData? icon;
  final ModalType modalType;

  const _ModalContent({
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryColor,
    this.icon,
    required this.modalType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = CommonModal._getColorScheme(modalType, primaryColor,context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.container,
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon section
          if (icon != null)
            Container(
              padding: const EdgeInsets.only(top: 24.0),
              child: Icon(
                icon,
                size: 48.0,
                color: colorScheme.primary,
              ),
            ),
          
          // Title section
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Message section
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onContainer.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Buttons section
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(
              children: [
                if (secondaryButtonText != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton(
                        onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          side: BorderSide(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Text(
                          secondaryButtonText!,
                          style: TextStyle(
                            color: colorScheme.onContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                if (primaryButtonText != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        // primary: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(primaryButtonText!),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ModalType { success, error, warning, info }

class ModalColorScheme {
  final Color primary;
  final Color container;
  final Color onContainer;

  ModalColorScheme({
    required this.primary,
    required this.container,
    required this.onContainer,
  });
}