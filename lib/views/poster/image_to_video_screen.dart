// // import 'dart:io';
// // import 'dart:async';
// // import 'dart:ui'as ui;
// // import 'dart:ui';
// // import 'package:device_info_plus/device_info_plus.dart';
// // import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
// // import 'package:edit_ezy_project/views/poster/audio_selection_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/rendering.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:image/image.dart' as img;
// // import 'package:flutter/services.dart';
// // import 'package:just_audio/just_audio.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'dart:math' as math;
// // import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// // import 'package:ffmpeg_kit_flutter/return_code.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:photo_manager/photo_manager.dart';
// // import 'package:provider/provider.dart';
// // import 'package:share_plus/share_plus.dart';

// // // Filter model
// // enum FilterType {
// //   none,
// //   blackWhite,
// //   watercolor,
// //   snow,
// //   waterDrops,
// // }

// // // Animation model
// // enum AnimationType {
// //   none,
// //   leftRight,
// //   upDown,
// //   window,
// //   gradient,
// //   transition,
// //   thaw,
// //   scale,
// // }

// // class UploadImage extends StatefulWidget {
// //   const UploadImage({super.key});

// //   @override
// //   _UploadImageState createState() => _UploadImageState();
// // }

// // class _UploadImageState extends State<UploadImage> {

// //    final GlobalKey _posterKey = GlobalKey();



// // Future<void> _shareVideo() async {
// //   if (_images.isEmpty) return;

// //   try {
// //     showDialog(context: context, barrierDismissible: false, builder: (_) => 
// //       const AlertDialog(content: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           CircularProgressIndicator(),
// //           SizedBox(height: 20),
// //           Text("Creating video..."),
// //         ],
// //       )),
// //     );

// //     final tempDir = await getTemporaryDirectory();
// //     final outputPath = '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
// //     final inputListPath = '${tempDir.path}/input.txt';
    
// //     // Create input file
// //     await File(inputListPath).writeAsString(
// //       _processedImages.map((img) => "file '${img.path}'\nduration ${_durationPerImageMs/1000}\n").join() +
// //       "file '${_processedImages.last.path}'\n"
// //     );

// //     // Build FFmpeg command
// //     List<String> ffmpegArgs = [
// //       '-f', 'concat',
// //       '-safe', '0',
// //       '-i', inputListPath,
// //       '-vf', 'scale=640:480:force_original_aspect_ratio=decrease,pad=640:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
// //       '-r', '15', // Lower frame rate for compatibility
// //       '-c:v', 'mpeg4',
// //       '-qscale:v', '3',
// //       '-y',
// //       outputPath
// //     ];

// //     // Add audio if selected (simplified)
// //     if (_selectedAudio != null) {
// //       ffmpegArgs.insertAll(ffmpegArgs.length - 1, [
// //         '-i', _selectedAudio!.url,
// //         '-c:a', 'aac',
// //         '-shortest'
// //       ]);
// //     }

// //     print('Executing: ffmpeg ${ffmpegArgs.join(' ')}');
// //     final session = await FFmpegKit.executeWithArguments(ffmpegArgs);
// //     final returnCode = await session.getReturnCode();

// //     if (!mounted) return;
// //     Navigator.of(context).pop();

// //     if (ReturnCode.isSuccess(returnCode)) {
// //       await Share.shareXFiles([XFile(outputPath)]);
// //     } else {
// //       throw Exception('Failed with code $returnCode');
// //     }
// //   } catch (e) {
// //     if (mounted) {
// //       Navigator.of(context).pop();
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: ${e.toString()}')),
// //       );
// //     }
// //   }
// // }



// //   List<File> _images = [];
// //   List<File> _processedImages = []; // Filtered images
// //   int _currentIndex = 0;
// //   final ImagePicker _picker = ImagePicker();
// //   Timer? _imageTimer;
// //   bool _isPlaying = false;
// //   bool  _isLoading = true;

// //   AudioTrack? _selectedAudio;
// //   AudioPlayer? _backgroundAudioPlayer;

// //   // Timer related variables
// //   int _elapsedSeconds = 0;
// //   Timer? _secondTimer;
// //   bool _showControls = true;

// //   // Filter and animation related
// //   FilterType _selectedFilter = FilterType.none;
// //   AnimationType _selectedAnimation = AnimationType.none;
// //   bool _showFilters = false;
// //   bool _showAnimations = false;
// //   bool _processingImages = false;

// //   // Animation controller
// //   double _animationValue = 0.2;
// //   Timer? _animationTimer;

// //   // Duration per image in milliseconds
// //   final int _durationPerImageMs = 3000;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSubscriptions();
// //     _initializeAudioPlayer();
// //     // Automatically open image picker when screen loads
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _pickInitialImages();
// //     });
// //   }


// //   Future<void> _loadSubscriptions() async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //       final userId = authProvider.user?.user.id;
// //       // Get this from your auth state
// //       // await Provider.of<SubscriptionProvider>(context, listen: false)
// //       //     .fetchSubscriptions(userId.toString());
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }



// //   @override
// //   void dispose() {
// //     _imageTimer?.cancel();
// //     _secondTimer?.cancel();
// //     _animationTimer?.cancel();
// //     _backgroundAudioPlayer?.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _pickInitialImages() async {
// //     try {
// //       final List<XFile>? pickedFiles = await _picker.pickMultiImage();

// //       if (pickedFiles != null && pickedFiles.isNotEmpty) {
// //         setState(() {
// //           _images = pickedFiles.map((file) => File(file.path)).toList();
// //           _processedImages = List.from(_images); // Start with original images
// //           _currentIndex = 0;
// //           _isPlaying = true;
// //           _elapsedSeconds = 0;
// //         });

// //         // Start auto-playing the images as a video
// //         _startVideoPlayback();
// //         _startTimer();
// //         // Start animation if one is selected
// //         if (_selectedAnimation != AnimationType.none) {
// //           _startAnimationTimer();
// //         }
// //       }
// //     } catch (e) {
// //       print('Error picking images: $e');
// //     }
// //   }

// //   void _openEditImagesScreen() {
// //     // Pause playback when going to edit screen
// //     _imageTimer?.cancel();
// //     _secondTimer?.cancel();
// //     _animationTimer?.cancel();

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => EditImagesScreen(
// //           existingImages: _images,
// //           onComplete: (updatedImages) {
// //             // This will be called when the user presses Done
// //             setState(() {
// //               _images = updatedImages;
// //               // If using filters, we need to reprocess the images
// //               if (_selectedFilter != FilterType.none) {
// //                 _applySelectedFilter();
// //               } else {
// //                 _processedImages = List.from(_images);
// //               }

// //               // If no images remain, reset to default state
// //               if (_images.isEmpty) {
// //                 _isPlaying = false;
// //                 _currentIndex = 0;
// //                 _elapsedSeconds = 0;
// //               } else {
// //                 // Make sure current index is valid
// //                 _currentIndex = _currentIndex.clamp(0, _images.length - 1);
// //                 _isPlaying = true;
// //                 // Restart playback
// //                 _startVideoPlayback();
// //                 _startTimer();
// //                 // Restart animation if needed
// //                 if (_selectedAnimation != AnimationType.none) {
// //                   _startAnimationTimer();
// //                 }
// //               }
// //             });
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   void _startVideoPlayback() {
// //     _imageTimer?.cancel();

// //     if (_images.length > 1) {
// //       _imageTimer = Timer.periodic(
// //         Duration(milliseconds: _durationPerImageMs),
// //         (timer) {
// //           if (mounted) {
// //             setState(() {
// //               if (_currentIndex < _images.length - 1) {
// //                 _currentIndex++;
// //                 // Reset animation value for transition effects
// //                 if (_selectedAnimation == AnimationType.transition) {
// //                   _animationValue = 0.0;
// //                 }
// //               } else {
// //                 // At the end of the video, pause playback
// //                 _currentIndex = 0;
// //                 precacheImage(FileImage(_processedImages[0]), context);
// //                 // Loop back to start
// //                 // _isPlaying = false; // Uncomment if you want to stop at the end instead of looping
// //                 // timer.cancel();
// //                 // _secondTimer?.cancel();
// //               }
// //             });
// //           }
// //         },
// //       );
// //     }
// //   }

// //   void _startTimer() {
// //     _secondTimer?.cancel();
// //     _secondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (mounted && _isPlaying) {
// //         setState(() {
// //           // Calculate elapsed seconds based on current index
// //           _elapsedSeconds =
// //               (_currentIndex * _durationPerImageMs / 1000).round();

// //           // If we've reached the end, stop the timer
// //           if (_currentIndex >= _images.length - 1) {
// //             _elapsedSeconds =
// //                 (_images.length * _durationPerImageMs / 1000).round();
// //             // timer.cancel(); // Remove this if you want to loop
// //           }
// //         });
// //       }
// //     });
// //   }

// //   void _startAnimationTimer() {
// //     _animationTimer?.cancel();
// //     _animationValue = 0.0;

// //     // Use a faster update rate for smoother animations
// //     const animationUpdateRate = 16; // ~60fps for smooth motion

// //     _animationTimer = Timer.periodic(
// //         const Duration(milliseconds: animationUpdateRate), (timer) {
// //       if (mounted) {
// //         setState(() {
// //           // Adjust speed based on animation type - slower speed means smoother animation
// //           double speedFactor;
// //           // Reduced from 1.0 to make all animations smoother
// //           switch (_selectedAnimation) {
// //             case AnimationType.transition:
// //               speedFactor = 0.25; // Slower for transitions
// //               break;
// //             case AnimationType.thaw:
// //               speedFactor = 0.3; // Slow for thaw effect
// //               break;
// //             case AnimationType.leftRight:
// //             case AnimationType.upDown:
// //               speedFactor = 0.4; // Medium for movement
// //               break;
// //             default:
// //               speedFactor = 0.35; // Default smooth speed
// //           }

// //           _animationValue += 0.01 * speedFactor;

// //           if (_animationValue >= 1.0) {
// //             if (_selectedAnimation == AnimationType.transition ||
// //                 _selectedAnimation == AnimationType.thaw) {
// //               _animationValue =
// //                   1.0; // Keep at full for completion-based animations
// //             } else {
// //               _animationValue = 0.0; // Reset for continuous animations
// //             }
// //           }

// //           double _getEasedValue(double value) {
// //             // Using cubic bezier curve for more natural animation
// //             if (value < 0.5) {
// //               // Ease in - slow start, faster middle
// //               return 4 * value * value * value;
// //             } else {
// //               // Ease out - slower end for more natural feel
// //               final double f = ((2 * value) - 2);
// //               return 0.5 * f * f * f + 1;
// //             }
// //           }
// //         });
// //       }
// //     });
// //   }

// //   void _togglePlayback() {
// //     setState(() {
// //       _isPlaying = !_isPlaying;
// //     });

// //     if (_isPlaying) {
// //       // If we're at the end, start over
// //       if (_currentIndex >= _images.length - 1) {
// //         setState(() {
// //           _currentIndex = 0;
// //           _elapsedSeconds = 0;
// //         });
// //       }
// //       _startVideoPlayback();
// //       _startTimer();

// //       // Restart animation if one is selected
// //       if (_selectedAnimation != AnimationType.none) {
// //         _startAnimationTimer();
// //       }
      
// //       // Play background audio if selected
// //       if (_selectedAudio != null) {
// //         _playBackgroundAudio();
// //       }
// //     } else {
// //       _imageTimer?.cancel();
// //       _secondTimer?.cancel();
// //       _animationTimer?.cancel();
      
// //       // Pause background audio
// //       _pauseBackgroundAudio();
// //     }
// //   }

// //   void _toggleControls() {
// //     setState(() {
// //       _showControls = !_showControls;
// //     });
// //   }

// //   // Format seconds into MM:SS
// //   String _formatDuration(int totalSeconds) {
// //     final minutes = totalSeconds ~/ 60;
// //     final seconds = totalSeconds % 60;
// //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// //   }

// //   // Calculate estimated total duration based on number of images and transition time
// //   String _getTotalDuration() {
// //     final totalSeconds =
// //         (_images.length * (_durationPerImageMs / 1000)).round();
// //     return _formatDuration(totalSeconds);
// //   }

// //   // Toggle filter panel visibility
// //   void _toggleFilters() {
// //     setState(() {
// //       _showFilters = !_showFilters;
// //       if (_showFilters) {
// //         _showAnimations = false;
// //       }
// //     });
// //   }

// //   // Toggle animation panel visibility
// //   void _toggleAnimations() {
// //     setState(() {
// //       _showAnimations = !_showAnimations;
// //       if (_showAnimations) {
// //         _showFilters = false;
// //       }
// //     });
// //   }

// //   // Apply selected filter to all images
// //   Future<void> _applySelectedFilter() async {
// //     if (_images.isEmpty) return;

// //     setState(() {
// //       _processingImages = true;
// //     });

// //     // Show a loading indicator
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           content: Row(
// //             children: [
// //               CircularProgressIndicator(),
// //               SizedBox(width: 20),
// //               Text("Applying filter..."),
// //             ],
// //           ),
// //         );
// //       },
// //     );

// //     try {
// //       // Process images in background
// //       List<File> newProcessedImages = [];

// //       for (int i = 0; i < _images.length; i++) {
// //         File processedFile = await _applyFilterToImage(_images[i], _selectedFilter);
// //         newProcessedImages.add(processedFile);
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _processedImages = newProcessedImages;
// //           _processingImages = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error applying filter: $e');
// //     } finally {
// //       // Pop the loading dialog
// //       if (mounted && Navigator.canPop(context)) {
// //         Navigator.of(context).pop();
// //       }
// //     }
// //   }

// //   // Apply a filter to an individual image
// //   Future<File> _applyFilterToImage(File imageFile, FilterType filter) async {
// //     // For "none" filter, return the original image
// //     if (filter == FilterType.none) {
// //       return imageFile;
// //     }

// //     try {
// //       // Read the image file
// //       final Uint8List bytes = await imageFile.readAsBytes();
// //       img.Image? image = img.decodeImage(bytes);

// //       if (image == null) {
// //         return imageFile; // Return original if decode fails
// //       }

// //       // Apply filter based on type
// //       img.Image filteredImage;
// //       switch (filter) {
// //         case FilterType.blackWhite:
// //           filteredImage = img.grayscale(image);
// //           break;
// //         case FilterType.watercolor:
// //           // For watercolor effect, apply some color adjustments and slight blur
// //           filteredImage = img.adjustColor(
// //             image,
// //             saturation: 1.3,
// //             contrast: 1.1,
// //             exposure: 1.05,
// //           );
// //           // filteredImage = img.gaussianBlur(filteredImage, radius: 1);
// //           break;
// //         case FilterType.snow:
// //           // For snow effect, brighten and add blue tint
// //           filteredImage = img.adjustColor(
// //             image,
// //             brightness: 1.2,
// //             exposure: 1.1,
// //           );
// //           // Add a cool/blue tint
// //           filteredImage = img.colorOffset(
// //             filteredImage,
// //             red: 0,
// //             green: 5,
// //             blue: 15,
// //           );
// //           break;
// //         case FilterType.waterDrops:
// //           // For water drops, enhance blue channel and add contrast
// //           filteredImage = img.adjustColor(
// //             image,
// //             brightness: 1.0,
// //             exposure: 1.0,
// //             contrast: 1.2,
// //             saturation: 1.1,
// //           );
// //           // Enhance blue channel
// //           filteredImage = img.colorOffset(
// //             filteredImage,
// //             red: 0,
// //             green: 0,
// //             blue: 10,
// //           );
// //           break;
// //         default:
// //           return imageFile;
// //       }

// //       // Save the filtered image to a temporary file
// //       final tempDir = await getTemporaryDirectory();
// //       final String fileName = '${DateTime.now().millisecondsSinceEpoch}_filtered.jpg';
// //       final String filePath = '${tempDir.path}/$fileName';
      
// //       // Encode and save
// //       final Uint8List encodedImage = Uint8List.fromList(img.encodeJpg(filteredImage, quality: 90));
// //       final File filteredFile = File(filePath);
// //       await filteredFile.writeAsBytes(encodedImage);
      
// //       return filteredFile;
// //     } catch (e) {
// //       print('Error in _applyFilterToImage: $e');
// //       return imageFile; // Return original on error
// //     }
// //   }

// //   Future<File> applyFilterToVideo(File videoFile, FilterType filter) async {
// //     // For "none" filter, return the original video
// //     if (filter == FilterType.none) {
// //       return videoFile;
// //     }

// //     final tempDir = await getTemporaryDirectory();
// //     final outputPath =
// //         '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

// //     // Create FFmpeg command based on filter type
// //     String ffmpegCommand;

// //     switch (filter) {
// //       case FilterType.blackWhite:
// //         // Convert to grayscale using FFmpeg
// //         ffmpegCommand =
// //             '-i ${videoFile.path} -vf colorchannelmixer=.3:.4:.3:0:.3:.4:.3:0:.3:.4:.3 $outputPath';
// //         break;

// //       case FilterType.watercolor:
// //         // Apply watercolor-like effect
// //         ffmpegCommand =
// //             '-i ${videoFile.path} -vf "colorbalance=rs=0.1:gs=0:bs=0.2,boxblur=1:1" $outputPath';
// //         break;

// //       case FilterType.snow:
// //         // Add snow effect and cool tint
// //         // Add snow effect and cool tint
// //         ffmpegCommand =
// //             '-i ${videoFile.path} -vf "colorbalance=rm=-0.1:bm=0.1:gm=-0.05,eq=brightness=0.1:contrast=1.1" $outputPath';
// //         break;

// //       case FilterType.waterDrops:
// //         // Add water drops effect (blue tint with contrast)
// //         ffmpegCommand =
// //             '-i ${videoFile.path} -vf "colorbalance=rm=-0.05:gm=0:bm=0.15,eq=contrast=1.2:saturation=1.2" $outputPath';
// //         break;

// //       default:
// //         return videoFile;
// //     }

// //     // Execute FFmpeg command
// //     final session = await FFmpegKit.execute(ffmpegCommand);
// //     final returnCode = await session.getReturnCode();

// //     if (ReturnCode.isSuccess(returnCode)) {
// //       return File(outputPath);
// //     } else {
// //       // Return original file if filter application fails
// //       print('FFmpeg filter application failed');
// //       return videoFile;
// //     }
// //   }

// //   // Apply an animation to the current image
// //   Widget _applyAnimation(Widget child) {
// //     if (_selectedAnimation == AnimationType.none) {
// //       return child;
// //     }

// //     switch (_selectedAnimation) {
// //       case AnimationType.leftRight:
// //         // Smooth horizontal panning animation
// //         double offsetX = (_animationValue * 2 - 1) * 0.1; // Range from -0.1 to 0.1
// //         return Transform.translate(
// //           offset: Offset(offsetX * MediaQuery.of(context).size.width, 0),
// //           child: child,
// //         );

// //       case AnimationType.upDown:
// //         // Smooth vertical panning animation
// //         double offsetY = (_animationValue * 2 - 1) * 0.08; // Range from -0.08 to 0.08
// //         return Transform.translate(
// //           offset: Offset(0, offsetY * MediaQuery.of(context).size.height),
// //           child: child,
// //         );

// //       case AnimationType.window:
// //         // Zoom-in effect with slight oscillation
// //         double scale = 1.0 + (_animationValue * 0.15);
// //         return Transform.scale(
// //           scale: scale,
// //           child: child,
// //         );

// //       case AnimationType.gradient:
// //         // Subtle brightness/contrast oscillation
// //         return ColorFiltered(
// //           colorFilter: ColorFilter.matrix(<double>[
// //             1, 0, 0, 0, _animationValue * 0.1,
// //             0, 1, 0, 0, _animationValue * 0.08,
// //             0, 0, 1, 0, _animationValue * 0.12,
// //             0, 0, 0, 1, 0,
// //           ]),
// //           child: child,
// //         );

// //       case AnimationType.transition:
// //         // Smooth fade-in transition
// //         return Opacity(
// //           opacity: _animationValue.clamp(0.0, 1.0),
// //           child: child,
// //         );

// //       case AnimationType.thaw:
// //         // Image "thawing" from the center outward
// //         return ClipRect(
// //           child: AnimatedBuilder(
// //             animation: AlwaysStoppedAnimation<double>(_animationValue),
// //             builder: (context, _) {
// //               return ShaderMask(
// //                 shaderCallback: (Rect bounds) {
// //                   return RadialGradient(
// //                     center: Alignment.center,
// //                     radius: 0.5 + (_animationValue * 1.5),
// //                     colors: const [Colors.black, Colors.transparent],
// //                     stops: const [0.8, 1.0],
// //                   ).createShader(bounds);
// //                 },
// //                 blendMode: BlendMode.dstIn,
// //                 child: child,
// //               );
// //             },
// //           ),
// //         );

// //       case AnimationType.scale:
// //         // Gentle scale/zoom animation
// //         double scaleValue = 1.0 + (math.sin(_animationValue * math.pi) * 0.08);
// //         return Transform.scale(
// //           scale: scaleValue,
// //           child: child,
// //         );

// //       default:
// //         return child;
// //     }
// //   }

// //   // Initialize audio player
// //   void _initializeAudioPlayer() {
// //     _backgroundAudioPlayer = AudioPlayer();
// //   }

// //   // Select background audio
// //   void _selectBackgroundAudio() async {
// //     // Pause current playback
// //     _imageTimer?.cancel();
// //     _isPlaying = false;

// //     final result = await Navigator.push<AudioTrack?>(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => AudioSelectionScreen(
// //           onAudioSelected: (audio) {
// //             Navigator.pop(context, audio);
// //           },
// //         ),
// //       ),
// //     );

// //     if (result != null) {
// //       setState(() {
// //         _selectedAudio = result;
// //       });

// //       // Resume playback with new audio
// //       if (_images.isNotEmpty) {
// //         setState(() {
// //           _isPlaying = true;
// //         });
// //         _startVideoPlayback();
// //         _startTimer();
// //         if (_selectedAnimation != AnimationType.none) {
// //           _startAnimationTimer();
// //         }
// //         _playBackgroundAudio();
// //       }
// //     } else {
// //       // Resume playback without changing audio
// //       if (_images.isNotEmpty) {
// //         setState(() {
// //           _isPlaying = true;
// //         });
// //         _startVideoPlayback();
// //         _startTimer();
// //         if (_selectedAnimation != AnimationType.none) {
// //           _startAnimationTimer();
// //         }
// //         if (_selectedAudio != null) {
// //           _playBackgroundAudio();
// //         }
// //       }
// //     }
// //   }

// //   // Play selected background audio
// //   Future<void> _playBackgroundAudio() async {
// //     if (_selectedAudio != null && _backgroundAudioPlayer != null) {
// //       try {
// //         await _backgroundAudioPlayer!.setUrl(_selectedAudio!.url);
// //         await _backgroundAudioPlayer!.setLoopMode(LoopMode.all);
// //         await _backgroundAudioPlayer!.play();
// //       } catch (e) {
// //         print('Error playing background audio: $e');
// //       }
// //     }
// //   }

// //   // Pause background audio
// //   void _pauseBackgroundAudio() {
// //     if (_backgroundAudioPlayer != null) {
// //       _backgroundAudioPlayer!.pause();
// //     }
// //   }

// // // // Add this helper method to properly check and request permissions
// // Future<bool> _checkAndRequestPermissions() async {
// //   if (Platform.isAndroid) {
// //     // Get Android version
// //     final androidInfo = await DeviceInfoPlugin().androidInfo;
// //     final sdkInt = androidInfo.version.sdkInt;
    
// //     if (sdkInt >= 33) {
// //       // Android 13+ (API 33+) - Request specific media permissions
// //       final photos = await Permission.photos.status;
// //       final videos = await Permission.videos.status;
      
// //       if (!photos.isGranted || !videos.isGranted) {
// //         final results = await [
// //           Permission.photos,
// //           Permission.videos,
// //         ].request();
        
// //         return results[Permission.photos]!.isGranted && 
// //                results[Permission.videos]!.isGranted;
// //       }
// //       return true;
// //     } else if (sdkInt >= 30) {
// //       // Android 11-12 (API 30-32) - Request manage external storage or use scoped storage
// //       final manageStorage = await Permission.manageExternalStorage.status;
// //       if (!manageStorage.isGranted) {
// //         final result = await Permission.manageExternalStorage.request();
// //         if (!result.isGranted) {
// //           // Fallback to scoped storage permissions
// //           final storage = await Permission.storage.status;
// //           if (!storage.isGranted) {
// //             final storageResult = await Permission.storage.request();
// //             return storageResult.isGranted;
// //           }
// //           return true;
// //         }
// //         return true;
// //       }
// //       return true;
// //     } else {
// //       // Android 10 and below - Use traditional storage permission
// //       final storage = await Permission.storage.status;
// //       if (!storage.isGranted) {
// //         final result = await Permission.storage.request();
// //         return result.isGranted;
// //       }
// //       return true;
// //     }
// //   } else if (Platform.isIOS) {
// //     // iOS permissions
// //     final photos = await Permission.photos.status;
// //     if (!photos.isGranted) {
// //       final result = await Permission.photos.request();
// //       return result.isGranted;
// //     }
// //     return true;
// //   }
  
// //   return true; // For other platforms
// // }


// // Future<void> _exportVideo() async {
// //   if (_images.isEmpty) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('No images to export')),
// //     );
// //     return;
// //   }

// //   // Check and request permissions
// //   bool hasPermission = await _checkAndRequestPermissions();
// //   if (!hasPermission) return;

// //   // Show loading dialog
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (BuildContext context) {
// //       return AlertDialog(
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const CircularProgressIndicator(),
// //             const SizedBox(height: 20),
// //             const Text("Creating video...", style: TextStyle(fontWeight: FontWeight.bold)),
// //             const SizedBox(height: 10),
// //             const Text("This may take a moment", style: TextStyle(fontSize: 12)),
// //           ],
// //         ),
// //       );
// //     },
// //   );

// //   try {
// //     final tempDir = await getTemporaryDirectory();
// //     final outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    
// //     // Create input file for FFmpeg
// //     final inputListPath = '${tempDir.path}/input.txt';
// //     final inputListFile = File(inputListPath);
    
// //     // Write input file content with durations
// //     String inputFileContent = '';
// //     for (String path in _processedImages.map((f) => f.path)) {
// //       inputFileContent += "file '$path'\n";
// //       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
// //     }
// //     if (_processedImages.isNotEmpty) {
// //       inputFileContent += "file '${_processedImages.last.path}'\n";
// //     }
// //     await inputListFile.writeAsString(inputFileContent);

// //     // Base FFmpeg command
// // List<String> ffmpegArgs = [
// //   '-f', 'concat',
// //   '-safe', '0',
// //   '-i', inputListPath,
// //   '-vf', 'scale=640:480:force_original_aspect_ratio=decrease,pad=640:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
// //   '-framerate', '15', // Use framerate instead of -r for input
// //   '-r', '15',         // Output frame rate
// //   '-c:v', 'libx264',  // Better to use h264
// //   '-preset', 'fast',
// //   '-crf', '23',       // Quality range (18-28, lower is better)
// //   '-pix_fmt', 'yuv420p',
// //   '-movflags', '+faststart', // For better streaming
// //   '-y',
// //   outputPath
// // ];

// //     // Add animation effects based on selected animation type
// //     String filterComplex = '';
// //     switch (_selectedAnimation) {
// //       case AnimationType.leftRight:
// //         filterComplex = 'zoompan=z=1:x=\'iw/2-(iw/4)*sin(2*PI*t)\':y=\'ih/2\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.upDown:
// //         filterComplex = 'zoompan=z=1:x=\'iw/2\':y=\'ih/2-(ih/4)*sin(2*PI*t)\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.window:
// //         filterComplex = 'zoompan=z=\'1+0.2*sin(2*PI*t)\':x=\'iw/2\':y=\'ih/2\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.scale:
// //         filterComplex = 'scale=w=\'iw*(1+0.1*sin(2*PI*t))\':h=\'ih*(1+0.1*sin(2*PI*t))\',setsar=1';
// //         break;
// //       case AnimationType.transition:
// //         case AnimationType.thaw:
// //         // For complex animations, we need to use the blend filter
// //         // This is a simplified version - you might need more complex filters
// //         filterComplex = 'framerate=fps=30,scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2';
// //         break;
// //       default:
// //         filterComplex = 'scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2';
// //     }

// //     // Update FFmpeg arguments with animation filter
// //     ffmpegArgs = [
// //       '-f', 'concat',
// //       '-safe', '0',
// //       '-i', inputListPath,
// //       '-vf', filterComplex,
// //       '-r', '30',
// //       '-pix_fmt', 'yuv420p',
// //       '-y',
// //       outputPath
// //     ];

// //     // Add audio if selected
// //     if (_selectedAudio != null) {
// //       ffmpegArgs.insertAll(ffmpegArgs.length - 2, [
// //         '-i', _selectedAudio!.url,
// //         '-c:a', 'aac',
// //         '-shortest'
// //       ]);
// //     }

// //     // Execute FFmpeg command
// //     final session = await FFmpegKit.executeWithArguments(ffmpegArgs);
// //     final returnCode = await session.getReturnCode();

// //     // Close loading dialog
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }

// //     if (ReturnCode.isSuccess(returnCode)) {
// //       // Share the created video
// //       await Share.shareXFiles([XFile(outputPath)], text: 'Check out my video!');
// //     } else {
// //       final String? failStackTrace = await session.getFailStackTrace();
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to create video: ${failStackTrace ?? "Unknown error"}')),
// //       );
// //     }
// //   } catch (e) {
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Error creating video: $e')),
// //     );
// //   }
// // }
 
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: _images.isEmpty
// //           ? _buildEmptyState()
// //           : GestureDetector(
// //               onTap: _toggleControls,
// //               child: Stack(
// //                 children: [
// //                   // Main display area for images
// //                   Center(
// //                     child: RepaintBoundary(
// //                       key: _posterKey,
// //                       child: Container(
// //                         width: double.infinity,
// //                         height: double.infinity,
// //                         color: Colors.black,
// //                         child: _processedImages.isNotEmpty
// //                             ? _applyAnimation(
// //                                 Image.file(
// //                                   _processedImages[_currentIndex],
// //                                   fit: BoxFit.contain,
// //                                   gaplessPlayback: true,
// //                                 ),
// //                               )
// //                             : const Center(child: CircularProgressIndicator()),
// //                       ),
// //                     ),
// //                   ),
                  
// //                   // Controls overlay
// //                   if (_showControls)
// //                     _buildControlsOverlay(),
                  
// //                   // Filter panel
// //                   if (_showFilters)
// //                     _buildFilterPanel(),
                  
// //                   // Animation panel
// //                   if (_showAnimations)
// //                     _buildAnimationPanel(),
// //                 ],
// //               ),
// //             ),
// //     );
// //   }

// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.photo_library_outlined,
// //             size: 80,
// //             color: Colors.white.withOpacity(0.7),
// //           ),
// //           const SizedBox(height: 16),
// //           Text(
// //             'Select multiple images to create a video',
// //             style: TextStyle(
// //               fontSize: 18,
// //               color: Colors.white.withOpacity(0.9),
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           ElevatedButton.icon(
// //             onPressed: _pickInitialImages,
// //             icon: const Icon(Icons.add_photo_alternate),
// //             label: const Text('Select Images'),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Theme.of(context).primaryColor,
// //               foregroundColor: Colors.white,
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 24,
// //                 vertical: 12,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildControlsOverlay() {
// //     return SafeArea(
// //       child: Column(
// //         children: [
// //           // Top bar
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 IconButton(
// //                   icon: const Icon(Icons.arrow_back, color: Colors.white),
// //                   onPressed: () => Navigator.of(context).pop(),
// //                 ),
// //                 Row(
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.filter, color: Colors.white),
// //                       onPressed: _toggleFilters,
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.animation, color: Colors.white),
// //                       onPressed: _toggleAnimations,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
          
// //           // Spacer to push bottom controls to the bottom
// //           const Spacer(),
          
// //           // Playback controls
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               children: [
              
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.edit, color: Colors.white),
// //                       onPressed: _openEditImagesScreen,
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.share, color: Colors.white),
// //                       onPressed: _shareVideo,
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.save_alt, color: Colors.white),
// //                       onPressed: _exportVideo,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFilterPanel() {
// //     return Positioned(
// //       top: 80,
// //       left: 0,
// //       right: 0,
// //       child: Container(
// //         height: 120,
// //         margin: const EdgeInsets.symmetric(horizontal: 16),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.8),
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: Colors.white.withOpacity(0.2)),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Padding(
// //               padding: EdgeInsets.only(left: 16, top: 8),
// //               child: Text(
// //                 'Filters',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: ListView(
// //                 padding: const EdgeInsets.all(8),
// //                 scrollDirection: Axis.horizontal,
// //                 children: [
// //                   _buildFilterOption(FilterType.none, 'None'),
// //                   _buildFilterOption(FilterType.blackWhite, 'B&W'),
// //                   _buildFilterOption(FilterType.watercolor, 'Watercolor'),
// //                   _buildFilterOption(FilterType.snow, 'Snow'),
// //                   _buildFilterOption(FilterType.waterDrops, 'Water'),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilterOption(FilterType filter, String label) {
// //     final bool isSelected = _selectedFilter == filter;
    
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _selectedFilter = filter;
// //           _applySelectedFilter();
// //         });
// //       },
// //       child: Container(
// //         width: 70,
// //         margin: const EdgeInsets.symmetric(horizontal: 8),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
// //             width: 2,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.filter,
// //               color: isSelected ? Theme.of(context).primaryColor : Colors.white,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 color: isSelected ? Theme.of(context).primaryColor : Colors.white,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAnimationPanel() {
// //     return Positioned(
// //       top: 80,
// //       left: 0,
// //       right: 0,
// //       child: Container(
// //         height: 120,
// //         margin: const EdgeInsets.symmetric(horizontal: 16),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.8),
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: Colors.white.withOpacity(0.2)),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Padding(
// //               padding: EdgeInsets.only(left: 16, top: 8),
// //               child: Text(
// //                 'Animations',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: ListView(
// //                 padding: const EdgeInsets.all(8),
// //                 scrollDirection: Axis.horizontal,
// //                 children: [
// //                   _buildAnimationOption(AnimationType.none, 'None'),
// //                   _buildAnimationOption(AnimationType.leftRight, 'Pan'),
// //                   _buildAnimationOption(AnimationType.upDown, 'Vert'),
// //                   _buildAnimationOption(AnimationType.window, 'Zoom'),
// //                   _buildAnimationOption(AnimationType.gradient, 'Pulse'),
// //                   _buildAnimationOption(AnimationType.transition, 'Fade'),
// //                   _buildAnimationOption(AnimationType.thaw, 'Thaw'),
// //                   _buildAnimationOption(AnimationType.scale, 'Scale'),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAnimationOption(AnimationType animation, String label) {
// //     final bool isSelected = _selectedAnimation == animation;
    
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _selectedAnimation = animation;
// //           if (animation != AnimationType.none) {
// //             _startAnimationTimer();
// //           } else {
// //             _animationTimer?.cancel();
// //           }
// //         });
// //       },
// //       child: Container(
// //         width: 70,
// //         margin: const EdgeInsets.symmetric(horizontal: 8),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
// //             width: 2,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.animation,
// //               color: isSelected ? Theme.of(context).primaryColor : Colors.white,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 color: isSelected ? Theme.of(context).primaryColor : Colors.white,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // EditImagesScreen widget for managing selected images
// // class EditImagesScreen extends StatefulWidget {
// //   final List<File> existingImages;
// //   final Function(List<File>) onComplete;

// //   const EditImagesScreen({
// //     Key? key,
// //     required this.existingImages,
// //     required this.onComplete,
// //   }) : super(key: key);

// //   @override
// //   _EditImagesScreenState createState() => _EditImagesScreenState();
// // }

// // class _EditImagesScreenState extends State<EditImagesScreen> {
// //   List<File> _images = [];
// //   final ImagePicker _picker = ImagePicker();
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _images = List.from(widget.existingImages);
// //   }
  
// //   Future<void> _addImages() async {
// //     try {
// //       final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      
// //       if (pickedFiles != null && pickedFiles.isNotEmpty) {
// //         setState(() {
// //           _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
// //         });
// //       }
// //     } catch (e) {
// //       print('Error picking additional images: $e');
// //     }
// //   }
  
// //   void _removeImage(int index) {
// //     setState(() {
// //       _images.removeAt(index);
// //     });
// //   }
  
// //   void _moveImage(int oldIndex, int newIndex) {
// //     if (oldIndex < newIndex) {
// //       // Removing the item at oldIndex will shorten the list by 1
// //       newIndex -= 1;
// //     }
// //     setState(() {
// //       final File item = _images.removeAt(oldIndex);
// //       _images.insert(newIndex, item);
// //     });
// //   }
  
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Edit Images'),
// //         actions: [
// //           TextButton(
// //             onPressed: () {
// //               widget.onComplete(_images);
// //               Navigator.pop(context);
// //             },
// //             child: const Text('Done'),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: _images.isEmpty
// //                 ? const Center(child: Text('No images selected'))
// //                 : ReorderableListView.builder(
// //                     itemCount: _images.length,
// //                     itemBuilder: (context, index) {
// //                       return ListTile(
// //                         key: Key('image_$index'),
// //                         leading: ClipRRect(
// //                           borderRadius: BorderRadius.circular(8),
// //                           child: Image.file(
// //                             _images[index],
// //                             width: 50,
// //                             height: 50,
// //                             fit: BoxFit.cover,
// //                           ),
// //                         ),
// //                         title: Text('Image ${index + 1}'),
// //                         trailing: IconButton(
// //                           icon: const Icon(Icons.delete),
// //                           onPressed: () => _removeImage(index),
// //                         ),
// //                       );
// //                     },
// //                     onReorder: _moveImage,
// //                   ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _addImages,
// //         child: const Icon(Icons.add_photo_alternate),
// //       ),
// //     );
// //   }
// // }

// // // Model class for audio tracks
// // class AudioTrack {
// //   final String id;
// //   final String title;
// //   final String artist;
// //   final String url;
// //   final String? coverUrl;

// //   AudioTrack({
// //     required this.id,
// //     required this.title,
// //     required this.artist,
// //     required this.url,
// //     this.coverUrl,
// //   });
// // }








































// import 'dart:io';
// import 'dart:async';
// import 'dart:ui'as ui;
// import 'dart:ui';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
// import 'package:edit_ezy_project/views/poster/audio_selection_screen.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
// import 'package:ffmpeg_kit_flutter/log.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/services.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:math' as math;
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';

// // Filter model
// enum FilterType {
//   none,
//   blackWhite,
//   watercolor,
//   snow,
//   waterDrops,
// }

// // Animation model
// enum AnimationType {
//   none,
//   leftRight,
//   upDown,
//   window,
//   gradient,
//   transition,
//   thaw,
//   scale,
// }

// class UploadImage extends StatefulWidget {
//   const UploadImage({super.key});

//   @override
//   _UploadImageState createState() => _UploadImageState();
// }

// class _UploadImageState extends State<UploadImage> with TickerProviderStateMixin {
//   final GlobalKey _posterKey = GlobalKey();
//   late AnimationController _fabAnimationController;
//   late AnimationController _slideAnimationController;
//   late Animation<double> _fabAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Your existing variables remain the same
//   List<File> _images = [];
//   List<File> _processedImages = [];
//   int _currentIndex = 0;
//   final ImagePicker _picker = ImagePicker();
//   Timer? _imageTimer;
//   bool _isPlaying = false;
//   bool _isLoading = true;
  
//   AudioTrack? _selectedAudio;
//   AudioPlayer? _backgroundAudioPlayer;
  
//   int _elapsedSeconds = 0;
//   Timer? _secondTimer;
//   bool _showControls = true;
  
//   FilterType _selectedFilter = FilterType.none;
//   AnimationType _selectedAnimation = AnimationType.none;
//   bool _showFilters = false;
//   bool _showAnimations = false;
//   bool _processingImages = false;
  
//   double _animationValue = 0.2;
//   Timer? _animationTimer;
//   final int _durationPerImageMs = 3000;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadSubscriptions();
//     _initializeAudioPlayer();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _pickInitialImages();
//     });
//   }

//   void _initializeAnimations() {
//     _fabAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic));
//   }

//   @override
//   void dispose() {
//     _fabAnimationController.dispose();
//     _slideAnimationController.dispose();
//     _imageTimer?.cancel();
//     _secondTimer?.cancel();
//     _animationTimer?.cancel();
//     _backgroundAudioPlayer?.dispose();
//     super.dispose();
//   }

//   // Your existing methods remain mostly the same, just updating UI-related ones
//   Future<void> _loadSubscriptions() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final userId = authProvider.user?.user.id;
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickInitialImages() async {
//     try {
//       final List<XFile>? pickedFiles = await _picker.pickMultiImage();

//       if (pickedFiles != null && pickedFiles.isNotEmpty) {
//         setState(() {
//           _images = pickedFiles.map((file) => File(file.path)).toList();
//           _processedImages = List.from(_images);
//           _currentIndex = 0;
//           _isPlaying = true;
//           _elapsedSeconds = 0;
//         });

//         _fabAnimationController.forward();
//         _slideAnimationController.forward();
//         _startVideoPlayback();
//         _startTimer();
        
//         if (_selectedAnimation != AnimationType.none) {
//           _startAnimationTimer();
//         }
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error selecting images: ${e.toString()}');
//     }
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red.shade700,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   // Your existing video/image processing methods remain the same
//   // I'll include the key ones here for completeness

//   void _startVideoPlayback() {
//     _imageTimer?.cancel();

//     if (_images.length > 1) {
//       _imageTimer = Timer.periodic(
//         Duration(milliseconds: _durationPerImageMs),
//         (timer) {
//           if (mounted) {
//             setState(() {
//               if (_currentIndex < _images.length - 1) {
//                 _currentIndex++;
//                 if (_selectedAnimation == AnimationType.transition) {
//                   _animationValue = 0.0;
//                 }
//               } else {
//                 _currentIndex = 0;
//                 precacheImage(FileImage(_processedImages[0]), context);
//               }
//             });
//           }
//         },
//       );
//     }
//   }

//   void _startTimer() {
//     _secondTimer?.cancel();
//     _secondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted && _isPlaying) {
//         setState(() {
//           _elapsedSeconds = (_currentIndex * _durationPerImageMs / 1000).round();
//           if (_currentIndex >= _images.length - 1) {
//             _elapsedSeconds = (_images.length * _durationPerImageMs / 1000).round();
//           }
//         });
//       }
//     });
//   }

//   void _togglePlayback() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });

//     if (_isPlaying) {
//       if (_currentIndex >= _images.length - 1) {
//         setState(() {
//           _currentIndex = 0;
//           _elapsedSeconds = 0;
//         });
//       }
//       _startVideoPlayback();
//       _startTimer();

//       if (_selectedAnimation != AnimationType.none) {
//         _startAnimationTimer();
//       }
      
//       if (_selectedAudio != null) {
//         _playBackgroundAudio();
//       }
//     } else {
//       _imageTimer?.cancel();
//       _secondTimer?.cancel();
//       _animationTimer?.cancel();
//       _pauseBackgroundAudio();
//     }
//   }

//   void _initializeAudioPlayer() {
//     _backgroundAudioPlayer = AudioPlayer();
//   }

//   Future<void> _playBackgroundAudio() async {
//     if (_selectedAudio != null && _backgroundAudioPlayer != null) {
//       try {
//         // await _backgroundAudioPlayer!.setUrl(_selectedAudio!.url);
//         await _backgroundAudioPlayer!.setLoopMode(LoopMode.all);
//         await _backgroundAudioPlayer!.play();
//       } catch (e) {
//         print('Error playing background audio: $e');
//       }
//     }
//   }

//   void _pauseBackgroundAudio() {
//     if (_backgroundAudioPlayer != null) {
//       _backgroundAudioPlayer!.pause();
//     }
//   }

//   // Include your existing animation and filter methods here
//   void _startAnimationTimer() {
//     _animationTimer?.cancel();
//     _animationValue = 0.0;

//     const animationUpdateRate = 16;

//     _animationTimer = Timer.periodic(
//         const Duration(milliseconds: animationUpdateRate), (timer) {
//       if (mounted) {
//         setState(() {
//           double speedFactor;
//           switch (_selectedAnimation) {
//             case AnimationType.transition:
//               speedFactor = 0.25;
//               break;
//             case AnimationType.thaw:
//               speedFactor = 0.3;
//               break;
//             case AnimationType.leftRight:
//             case AnimationType.upDown:
//               speedFactor = 0.4;
//               break;
//             default:
//               speedFactor = 0.35;
//           }

//           _animationValue += 0.01 * speedFactor;

//           if (_animationValue >= 1.0) {
//             if (_selectedAnimation == AnimationType.transition ||
//                 _selectedAnimation == AnimationType.thaw) {
//               _animationValue = 1.0;
//             } else {
//               _animationValue = 0.0;
//             }
//           }
//         });
//       }
//     });
//   }

//   Widget _applyAnimation(Widget child) {
//     if (_selectedAnimation == AnimationType.none) {
//       return child;
//     }

//     switch (_selectedAnimation) {
//       case AnimationType.leftRight:
//         double offsetX = (_animationValue * 2 - 1) * 0.1;
//         return Transform.translate(
//           offset: Offset(offsetX * MediaQuery.of(context).size.width, 0),
//           child: child,
//         );

//       case AnimationType.upDown:
//         double offsetY = (_animationValue * 2 - 1) * 0.08;
//         return Transform.translate(
//           offset: Offset(0, offsetY * MediaQuery.of(context).size.height),
//           child: child,
//         );

//       case AnimationType.window:
//         double scale = 1.0 + (_animationValue * 0.15);
//         return Transform.scale(
//           scale: scale,
//           child: child,
//         );

//       case AnimationType.gradient:
//         return ColorFiltered(
//           colorFilter: ColorFilter.matrix(<double>[
//             1, 0, 0, 0, _animationValue * 0.1,
//             0, 1, 0, 0, _animationValue * 0.08,
//             0, 0, 1, 0, _animationValue * 0.12,
//             0, 0, 0, 1, 0,
//           ]),
//           child: child,
//         );

//       case AnimationType.transition:
//         return Opacity(
//           opacity: _animationValue.clamp(0.0, 1.0),
//           child: child,
//         );

//       case AnimationType.thaw:
//         return ClipRect(
//           child: AnimatedBuilder(
//             animation: AlwaysStoppedAnimation<double>(_animationValue),
//             builder: (context, _) {
//               return ShaderMask(
//                 shaderCallback: (Rect bounds) {
//                   return RadialGradient(
//                     center: Alignment.center,
//                     radius: 0.5 + (_animationValue * 1.5),
//                     colors: const [Colors.black, Colors.transparent],
//                     stops: const [0.8, 1.0],
//                   ).createShader(bounds);
//                 },
//                 blendMode: BlendMode.dstIn,
//                 child: child,
//               );
//             },
//           ),
//         );

//       case AnimationType.scale:
//         double scaleValue = 1.0 + (math.sin(_animationValue * math.pi) * 0.08);
//         return Transform.scale(
//           scale: scaleValue,
//           child: child,
//         );

//       default:
//         return child;
//     }
//   }

//   // Include your filter application methods here
//   Future<void> _applySelectedFilter() async {
//     if (_images.isEmpty) return;

//     setState(() {
//       _processingImages = true;
//     });

//     _showProcessingDialog("Applying filter...");

//     try {
//       List<File> newProcessedImages = [];

//       for (int i = 0; i < _images.length; i++) {
//         File processedFile = await _applyFilterToImage(_images[i], _selectedFilter);
//         newProcessedImages.add(processedFile);
//       }

//       if (mounted) {
//         setState(() {
//           _processedImages = newProcessedImages;
//           _processingImages = false;
//         });
//         Navigator.of(context).pop();
//         _showSuccessSnackbar("Filter applied successfully!");
//       }
//     } catch (e) {
//       Navigator.of(context).pop();
//       _showErrorSnackbar("Failed to apply filter");
//     }
//   }

//   void _showProcessingDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       strokeWidth: 3,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   message,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Please wait...",
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<File> _applyFilterToImage(File imageFile, FilterType filter) async {
//     if (filter == FilterType.none) {
//       return imageFile;
//     }

//     try {
//       final Uint8List bytes = await imageFile.readAsBytes();
//       img.Image? image = img.decodeImage(bytes);

//       if (image == null) {
//         return imageFile;
//       }

//       img.Image filteredImage;
//       switch (filter) {
//         case FilterType.blackWhite:
//           filteredImage = img.grayscale(image);
//           break;
//         case FilterType.watercolor:
//           filteredImage = img.adjustColor(
//             image,
//             saturation: 1.3,
//             contrast: 1.1,
//             exposure: 1.05,
//           );
//           break;
//         case FilterType.snow:
//           filteredImage = img.adjustColor(
//             image,
//             brightness: 1.2,
//             exposure: 1.1,
//           );
//           filteredImage = img.colorOffset(
//             filteredImage,
//             red: 0,
//             green: 5,
//             blue: 15,
//           );
//           break;
//         case FilterType.waterDrops:
//           filteredImage = img.adjustColor(
//             image,
//             brightness: 1.0,
//             exposure: 1.0,
//             contrast: 1.2,
//             saturation: 1.1,
//           );
//           filteredImage = img.colorOffset(
//             filteredImage,
//             red: 0,
//             green: 0,
//             blue: 10,
//           );
//           break;
//         default:
//           return imageFile;
//       }

//       final tempDir = await getTemporaryDirectory();
//       final String fileName = '${DateTime.now().millisecondsSinceEpoch}_filtered.jpg';
//       final String filePath = '${tempDir.path}/$fileName';
      
//       final Uint8List encodedImage = Uint8List.fromList(img.encodeJpg(filteredImage, quality: 90));
//       final File filteredFile = File(filePath);
//       await filteredFile.writeAsBytes(encodedImage);
      
//       return filteredFile;
//     } catch (e) {
//       return imageFile;
//     }
//   }

//   // Include your export methods here (keeping them the same)
//   // Future<bool> _checkAndRequestPermissions() async {
//   //   if (Platform.isAndroid) {
//   //     final androidInfo = await DeviceInfoPlugin().androidInfo;
//   //     final sdkInt = androidInfo.version.sdkInt;
      
//   //     if (sdkInt >= 33) {
//   //       final photos = await Permission.photos.status;
//   //       final videos = await Permission.videos.status;
        
//   //       if (!photos.isGranted || !videos.isGranted) {
//   //         final results = await [
//   //           Permission.photos,
//   //           Permission.videos,
//   //         ].request();
          
//   //         return results[Permission.photos]!.isGranted && 
//   //                results[Permission.videos]!.isGranted;
//   //       }
//   //       return true;
//   //     } else if (sdkInt >= 30) {
//   //       final manageStorage = await Permission.manageExternalStorage.status;
//   //       if (!manageStorage.isGranted) {
//   //         final result = await Permission.manageExternalStorage.request();
//   //         if (!result.isGranted) {
//   //           final storage = await Permission.storage.status;
//   //           if (!storage.isGranted) {
//   //             final storageResult = await Permission.storage.request();
//   //             return storageResult.isGranted;
//   //           }
//   //           return true;
//   //         }
//   //         return true;
//   //       }
//   //       return true;
//   //     } else {
//   //       final storage = await Permission.storage.status;
//   //       if (!storage.isGranted) {
//   //         final result = await Permission.storage.request();
//   //         return result.isGranted;
//   //       }
//   //       return true;
//   //     }
//   //   } else if (Platform.isIOS) {
//   //     final photos = await Permission.photos.status;
//   //     if (!photos.isGranted) {
//   //       final result = await Permission.photos.request();
//   //       return result.isGranted;
//   //     }
//   //     return true;
//   //   }
    
//   //   return true;
//   // }





// // Replace your existing permission methods with this improved version
// Future<bool> _checkAndRequestPermissions() async {
//   try {
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       final sdkInt = androidInfo.version.sdkInt;
      
//       print('Android SDK: $sdkInt');
      
//       if (sdkInt >= 33) {
//         // Android 13+ (API level 33+) - Use granular media permissions
//         print('Requesting Android 13+ permissions...');
        
//         // Request photos and videos permissions
//         Map<Permission, PermissionStatus> statuses = await [
//           Permission.photos,
//           Permission.videos,
//         ].request();
        
//         final photosStatus = statuses[Permission.photos];
//         final videosStatus = statuses[Permission.videos];
        
//         print('Photos permission: $photosStatus');
//         print('Videos permission: $videosStatus');
        
//         if (photosStatus != PermissionStatus.granted || videosStatus != PermissionStatus.granted) {
//           _showPermissionDialog();
//           return false;
//         }
//         return true;
        
//       } else if (sdkInt >= 30) {
//         // Android 11-12 (API level 30-32)
//         print('Requesting Android 11-12 permissions...');
        
//         final storageStatus = await Permission.storage.request();
//         print('Storage permission: $storageStatus');
        
//         if (storageStatus != PermissionStatus.granted) {
//           // Try manage external storage as backup
//           final manageStorageStatus = await Permission.manageExternalStorage.request();
//           print('Manage external storage: $manageStorageStatus');
          
//           if (manageStorageStatus != PermissionStatus.granted && storageStatus != PermissionStatus.granted) {
//             _showPermissionDialog();
//             return false;
//           }
//         }
//         return true;
        
//       } else {
//         // Android 10 and below (API level 29 and below)
//         print('Requesting legacy storage permissions...');
        
//         final storageStatus = await Permission.storage.request();
//         print('Storage permission (legacy): $storageStatus');
        
//         if (storageStatus != PermissionStatus.granted) {
//           _showPermissionDialog();
//           return false;
//         }
//         return true;
//       }
      
//     } else if (Platform.isIOS) {
//       // iOS permissions
//       print('Requesting iOS permissions...');
      
//       final photosStatus = await Permission.photos.request();
//       print('iOS Photos permission: $photosStatus');
      
//       if (photosStatus != PermissionStatus.granted) {
//         _showPermissionDialog();
//         return false;
//       }
//       return true;
//     }
    
//     return true;
    
//   } catch (e) {
//     print('Error requesting permissions: $e');
//     _showErrorSnackbar('Error requesting permissions: ${e.toString()}');
//     return false;
//   }
// }

// // Show a dialog explaining why permissions are needed
// void _showPermissionDialog() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Permissions Required'),
//         content: const Text(
//           'This app needs storage permissions to save and share your videos. Please grant the required permissions in the app settings.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               openAppSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       );
//     },
//   );
// }

// // Alternative method using PhotoManager (if you have it)
// Future<bool> _requestPhotoManagerPermissions() async {
//   try {
//     final PermissionState ps = await PhotoManager.requestPermissionExtend();
//     if (ps == PermissionState.authorized || ps == PermissionState.limited) {
//       return true;
//     } else {
//       _showPermissionDialog();
//       return false;
//     }
//   } catch (e) {
//     print('PhotoManager permission error: $e');
//     return await _checkAndRequestPermissions(); // Fallback to regular permissions
//   }
// }

// // You can also try this simplified approach
// Future<bool> _checkPermissionsSimplified() async {
//   try {
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       final sdkInt = androidInfo.version.sdkInt;
      
//       if (sdkInt >= 33) {
//         // For Android 13+, we need both photos and videos
//         final results = await [
//           Permission.photos,
//           Permission.videos,
//         ].request();
        
//         bool allGranted = results.values.every(
//           (status) => status == PermissionStatus.granted
//         );
        
//         if (!allGranted) {
//           _showErrorSnackbar('Storage permissions are required to export and share videos');
//           return false;
//         }
//         return true;
        
//       } else {
//         // For older Android versions
//         final status = await Permission.storage.request();
//         if (status != PermissionStatus.granted) {
//           _showErrorSnackbar('Storage permission is required');
//           return false;
//         }
//         return true;
//       }
//     } else if (Platform.isIOS) {
//       final status = await Permission.photos.request();
//       if (status != PermissionStatus.granted) {
//         _showErrorSnackbar('Photos permission is required');
//         return false;
//       }
//       return true;
//     }
    
//     return true;
//   } catch (e) {
//     print('Permission error: $e');
//     _showErrorSnackbar('Error checking permissions');
//     return false;
//   }
// }





//   // Future<void> _exportVideo() async {
//   //   if (_images.isEmpty) {
//   //     _showErrorSnackbar('No images to export');
//   //     return;
//   //   }

//   //   bool hasPermission = await _checkAndRequestPermissions();
//   //   if (!hasPermission) {
//   //     _showErrorSnackbar('Storage permissions required');
//   //     return;
//   //   }

//   //   _showProcessingDialog("Creating video...");

//   //   try {
//   //     final tempDir = await getTemporaryDirectory();
//   //     final outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      
//   //     final inputListPath = '${tempDir.path}/input.txt';
//   //     final inputListFile = File(inputListPath);
      
//   //     String inputFileContent = '';
//   //     for (String path in _processedImages.map((f) => f.path)) {
//   //       inputFileContent += "file '$path'\n";
//   //       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
//   //     }
//   //     if (_processedImages.isNotEmpty) {
//   //       inputFileContent += "file '${_processedImages.last.path}'\n";
//   //     }
//   //     await inputListFile.writeAsString(inputFileContent);

//   //     List<String> ffmpegArgs = [
//   //       '-f', 'concat',
//   //       '-safe', '0',
//   //       '-i', inputListPath,
//   //       '-vf', 'scale=640:480:force_original_aspect_ratio=decrease,pad=640:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
//   //       '-framerate', '15',
//   //       '-r', '15',
//   //       '-c:v', 'libx264',
//   //       '-preset', 'fast',
//   //       '-crf', '23',
//   //       '-pix_fmt', 'yuv420p',
//   //       '-movflags', '+faststart',
//   //       '-y',
//   //       outputPath
//   //     ];

//   //     if (_selectedAudio != null) {
//   //       ffmpegArgs.insertAll(ffmpegArgs.length - 2, [
//   //         // '-i', _selectedAudio!.url,
//   //         '-c:a', 'aac',
//   //         '-shortest'
//   //       ]);
//   //     }

//   //     final session = await FFmpegKit.executeWithArguments(ffmpegArgs);
//   //     final returnCode = await session.getReturnCode();

//   //     if (mounted && Navigator.canPop(context)) {
//   //       Navigator.of(context).pop();
//   //     }

//   //     if (ReturnCode.isSuccess(returnCode)) {
//   //       await Share.shareXFiles([XFile(outputPath)], text: 'Check out my video!');
//   //       _showSuccessSnackbar("Video exported successfully!");
//   //     } else {
//   //       _showErrorSnackbar("Failed to create video");
//   //     }
//   //   } catch (e) {
//   //     if (mounted && Navigator.canPop(context)) {
//   //       Navigator.of(context).pop();
//   //     }
//   //     _showErrorSnackbar("Error creating video: ${e.toString()}");
//   //   }
//   // }


// //   Future<void> _exportVideo() async {
// //   if (_images.isEmpty) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('No images to export')),
// //     );
// //     return;
// //   }

// //   // Check and request permissions
// //   bool hasPermission = await _checkAndRequestPermissions();
// //   if (!hasPermission) return;

// //   // Show loading dialog
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (BuildContext context) {
// //       return AlertDialog(
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const CircularProgressIndicator(),
// //             const SizedBox(height: 20),
// //             const Text("Creating video...", style: TextStyle(fontWeight: FontWeight.bold)),
// //             const SizedBox(height: 10),
// //             const Text("This may take a moment", style: TextStyle(fontSize: 12)),
// //           ],
// //         ),
// //       );
// //     },
// //   );

// //   try {
// //     final tempDir = await getTemporaryDirectory();
// //     final outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    
// //     // Create input file for FFmpeg
// //     final inputListPath = '${tempDir.path}/input.txt';
// //     final inputListFile = File(inputListPath);
    
// //     // Write input file content with durations
// //     String inputFileContent = '';
// //     for (String path in _processedImages.map((f) => f.path)) {
// //       inputFileContent += "file '$path'\n";
// //       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
// //     }
// //     if (_processedImages.isNotEmpty) {
// //       inputFileContent += "file '${_processedImages.last.path}'\n";
// //     }
// //     await inputListFile.writeAsString(inputFileContent);

// //     // Base FFmpeg command
// // List<String> ffmpegArgs = [
// //   '-f', 'concat',
// //   '-safe', '0',
// //   '-i', inputListPath,
// //   '-vf', 'scale=640:480:force_original_aspect_ratio=decrease,pad=640:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
// //   '-framerate', '15', // Use framerate instead of -r for input
// //   '-r', '15',         // Output frame rate
// //   '-c:v', 'libx264',  // Better to use h264
// //   '-preset', 'fast',
// //   '-crf', '23',       // Quality range (18-28, lower is better)
// //   '-pix_fmt', 'yuv420p',
// //   '-movflags', '+faststart', // For better streaming
// //   '-y',
// //   outputPath
// // ];

// //     // Add animation effects based on selected animation type
// //     String filterComplex = '';
// //     switch (_selectedAnimation) {
// //       case AnimationType.leftRight:
// //         filterComplex = 'zoompan=z=1:x=\'iw/2-(iw/4)*sin(2*PI*t)\':y=\'ih/2\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.upDown:
// //         filterComplex = 'zoompan=z=1:x=\'iw/2\':y=\'ih/2-(ih/4)*sin(2*PI*t)\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.window:
// //         filterComplex = 'zoompan=z=\'1+0.2*sin(2*PI*t)\':x=\'iw/2\':y=\'ih/2\':d=1:s=1280x720';
// //         break;
// //       case AnimationType.scale:
// //         filterComplex = 'scale=w=\'iw*(1+0.1*sin(2*PI*t))\':h=\'ih*(1+0.1*sin(2*PI*t))\',setsar=1';
// //         break;
// //       case AnimationType.transition:
// //         case AnimationType.thaw:
// //         // For complex animations, we need to use the blend filter
// //         // This is a simplified version - you might need more complex filters
// //         filterComplex = 'framerate=fps=30,scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2';
// //         break;
// //       default:
// //         filterComplex = 'scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2';
// //     }

// //     // Update FFmpeg arguments with animation filter
// //     ffmpegArgs = [
// //       '-f', 'concat',
// //       '-safe', '0',
// //       '-i', inputListPath,
// //       '-vf', filterComplex,
// //       '-r', '30',
// //       '-pix_fmt', 'yuv420p',
// //       '-y',
// //       outputPath
// //     ];

// //     // Add audio if selected
// //     if (_selectedAudio != null) {
// //       ffmpegArgs.insertAll(ffmpegArgs.length - 2, [
// //         // '-i', _selectedAudio!.url,
// //         '-c:a', 'aac',
// //         '-shortest'
// //       ]);
// //     }

// //     // Execute FFmpeg command
// //     final session = await FFmpegKit.executeWithArguments(ffmpegArgs);
// //     final returnCode = await session.getReturnCode();

// //     // Close loading dialog
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }

// //     if (ReturnCode.isSuccess(returnCode)) {
// //       // Share the created video
// //       await Share.shareXFiles([XFile(outputPath)], text: 'Check out my video!');
// //     } else {
// //       final String? failStackTrace = await session.getFailStackTrace();
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to create video: ${failStackTrace ?? "Unknown error"}')),
// //       );
// //     }
// //   } catch (e) {
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Error creating video: $e')),
// //     );
// //   }
// // }













// Future<void> _exportVideo() async {
//   if (_images.isEmpty) {
//     _showErrorSnackbar('No images to export');
//     return;
//   }

//   bool hasPermission = await _checkAndRequestPermissions();
//   if (!hasPermission) {
//     _showErrorSnackbar('Storage permissions required');
//     return;
//   }

//   _showProcessingDialog("Creating video...");

//   try {
//     final tempDir = await getTemporaryDirectory();
//     final outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
//     final inputListPath = '${tempDir.path}/input.txt';
    
//     // Create input file for FFmpeg concat
//     String inputFileContent = '';
//     for (File imageFile in _processedImages) {
//       inputFileContent += "file '${imageFile.path}'\n";
//       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
//     }
//     if (_processedImages.isNotEmpty) {
//       inputFileContent += "file '${_processedImages.last.path}'\n";
//     }
    
//     await File(inputListPath).writeAsString(inputFileContent);

//     // Build FFmpeg command with animation effects
//     String filterComplex = '';
//     switch (_selectedAnimation) {
//       case AnimationType.leftRight:
//         filterComplex = 'zoompan=z=1.1:x=\'iw/2-(iw/zoom/4)*sin(2*PI*t)\':y=\'ih/2\':d=1:s=1280x720:fps=30';
//         break;
//       case AnimationType.upDown:
//         filterComplex = 'zoompan=z=1.1:x=\'iw/2\':y=\'ih/2-(ih/zoom/4)*sin(2*PI*t)\':d=1:s=1280x720:fps=30';
//         break;
//       case AnimationType.window:
//         filterComplex = 'zoompan=z=\'1.1+0.1*sin(2*PI*t)\':x=\'iw/2\':y=\'ih/2\':d=1:s=1280x720:fps=30';
//         break;
//       case AnimationType.scale:
//         filterComplex = 'zoompan=z=\'1+0.2*sin(2*PI*t)\':x=\'iw/2\':y=\'ih/2\':d=1:s=1280x720:fps=30';
//         break;
//       default:
//         filterComplex = 'scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2';
//     }

//     String ffmpegCommand = '-f concat -safe 0 -i "$inputListPath" -vf "$filterComplex" -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 -movflags +faststart -y "$outputPath"';

//     // Add audio if selected
//     // if (_selectedAudio != null) {
//     //   ffmpegCommand = '-f concat -safe 0 -i "$inputListPath" -i -vf "$filterComplex" -c:v libx264 -c:a aac -preset medium -crf 20 -pix_fmt yuv420p -r 30 -shortest -movflags +faststart -y "$outputPath"';
//     // }

//     print('FFmpeg command: $ffmpegCommand');

//     // Execute FFmpeg command
//     await FFmpegKit.execute(ffmpegCommand).then((session) async {
//       final returnCode = await session.getReturnCode();

//       // Close loading dialog
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }

//       if (ReturnCode.isSuccess(returnCode)) {
//         // Share the created video
//         await Share.shareXFiles([XFile(outputPath)], text: 'Check out my video!');
//         _showSuccessSnackbar("Video exported successfully!");
//       } else {
//         final failStackTrace = await session.getFailStackTrace();
//         print('FFmpeg failed: $failStackTrace');
//         _showErrorSnackbar("Failed to export video. Please try again.");
//       }
//     }).catchError((error) {
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }
//       _showErrorSnackbar("Error exporting video: ${error.toString()}");

//       print('${error.toString()}');
//     });

//   } catch (e) {
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//     _showErrorSnackbar("Error creating video: ${e.toString()}");
//   }
// }
  


// //   Future<void> _shareVideo() async {
// //   if (_images.isEmpty) {
// //     _showErrorSnackbar('No images to share');
// //     return;
// //   }

// //   // Check and request permissions
// //   bool hasPermission = await _checkAndRequestPermissions();
// //   if (!hasPermission) {
// //     _showErrorSnackbar('Storage permissions required');
// //     return;
// //   }

// //   _showProcessingDialog("Creating video...");

// //   try {
// //     final tempDir = await getTemporaryDirectory();
// //     final outputPath = '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
// //     final inputListPath = '${tempDir.path}/input.txt';
    
// //     // Create input file for FFmpeg concat
// //     String inputFileContent = '';
// //     for (String path in _processedImages.map((f) => f.path)) {
// //       inputFileContent += "file '$path'\n";
// //       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
// //     }
// //     // Add the last image without duration for proper ending
// //     if (_processedImages.isNotEmpty) {
// //       inputFileContent += "file '${_processedImages.last.path}'\n";
// //     }
    
// //     await File(inputListPath).writeAsString(inputFileContent);

// //     // Build FFmpeg command with proper error handling
// //     List<String> ffmpegArgs = [
// //       '-f', 'concat',
// //       '-safe', '0',
// //       '-i', inputListPath,
// //       '-vf', 'scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
// //       '-r', '30',
// //       '-c:v', 'libx264',
// //       '-preset', 'medium',
// //       '-crf', '23',
// //       '-pix_fmt', 'yuv420p',
// //       '-movflags', '+faststart',
// //       '-avoid_negative_ts', 'make_zero',
// //       '-fflags', '+genpts',
// //       '-y',
// //       outputPath
// //     ];

// //     // Add audio if selected (commented out for now)
// //     if (_selectedAudio != null) {
// //       ffmpegArgs.insertAll(ffmpegArgs.length - 2, [
// //         // '-i', _selectedAudio!.url,
// //         '-c:a', 'aac',
// //         '-b:a', '128k',
// //         '-shortest'
// //       ]);
// //     }

// //     print('FFmpeg command: ${ffmpegArgs.join(' ')}');

// //     // Execute FFmpeg with proper session handling
// //     FFmpegSession session = await FFmpegKit.executeWithArguments(ffmpegArgs);
// //     final returnCode = await session.getReturnCode();
// //     final output = await session.getOutput();
// //     final logs = await session.getLogs();

// //     // Debug logging
// //     print('FFmpeg Return Code: $returnCode');
// //     print('FFmpeg Output: $output');
    
// //     // Log any errors
// //     if (logs.isNotEmpty) {
// //       for (Log log in logs) {
// //         print('FFmpeg Log: ${log.getMessage()}');
// //       }
// //     }

// //     // Close loading dialog
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }

// //     if (ReturnCode.isSuccess(returnCode)) {
// //       // Check if output file exists
// //       final outputFile = File(outputPath);
// //       if (await outputFile.exists()) {
// //         final fileSize = await outputFile.length();
// //         print('Output file size: $fileSize bytes');
        
// //         if (fileSize > 0) {
// //           // Share the created video
// //           await Share.shareXFiles(
// //             [XFile(outputPath)],
// //             text: 'Check out my video created with Video Studio!',
// //           );
// //           _showSuccessSnackbar("Video shared successfully!");
// //         } else {
// //           _showErrorSnackbar("Created video file is empty");
// //         }
// //       } else {
// //         _showErrorSnackbar("Video file was not created");
// //       }
// //     } else {
// //       // Get failure details
// //       final failStackTrace = await session.getFailStackTrace();
// //       final allLogs = await session.getAllLogs();
      
// //       String errorMessage = "Failed to create video";
// //       if (allLogs.isNotEmpty) {
// //         errorMessage += "\nLast error: ${allLogs.last.getMessage()}";
// //       }
      
// //       print('FFmpeg failed with return code: $returnCode');
// //       print('Fail stack trace: $failStackTrace');
      
// //       _showErrorSnackbar(errorMessage);
// //     }
    
// //   } catch (e, stackTrace) {
// //     print('Exception in _shareVideo: $e');
// //     print('Stack trace: $stackTrace');
    
// //     if (mounted && Navigator.canPop(context)) {
// //       Navigator.of(context).pop();
// //     }
// //     _showErrorSnackbar("Error creating video: ${e.toString()}");
// //   }
// // }




// Future<void> _shareVideo() async {
//   if (_images.isEmpty) {
//     _showErrorSnackbar('No images to share');
//     return;
//   }

//   // Check permissions
//   bool hasPermission = await _checkAndRequestPermissions();
//   if (!hasPermission) {
//     _showErrorSnackbar('Storage permissions required');
//     return;
//   }

//   _showProcessingDialog("Creating video...");

//   try {
//     final tempDir = await getTemporaryDirectory();
//     final outputPath = '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//     final inputListPath = '${tempDir.path}/input.txt';
    
//     // Create input file for FFmpeg concat
//     String inputFileContent = '';
//     for (File imageFile in _processedImages) {
//       inputFileContent += "file '${imageFile.path}'\n";
//       inputFileContent += "duration ${_durationPerImageMs / 1000}\n";
//     }
//     // Add the last image without duration for proper ending
//     if (_processedImages.isNotEmpty) {
//       inputFileContent += "file '${_processedImages.last.path}'\n";
//     }
    
//     await File(inputListPath).writeAsString(inputFileContent);

//     // Build FFmpeg command - simplified for better compatibility
//     String ffmpegCommand = '-f concat -safe 0 -i "$inputListPath" -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p -r 30 -y "$outputPath"';

//     print('FFmpeg command: $ffmpegCommand');

//     // Execute FFmpeg command using the correct method
//     await FFmpegKit.execute(ffmpegCommand).then((session) async {
//       final returnCode = await session.getReturnCode();
      
//       print('FFmpeg Return Code: $returnCode');

//       // Close loading dialog
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }

//       if (ReturnCode.isSuccess(returnCode)) {
//         // Check if output file exists and has content
//         final outputFile = File(outputPath);
//         if (await outputFile.exists()) {
//           final fileSize = await outputFile.length();
//           print('Output file size: $fileSize bytes');
          
//           if (fileSize > 0) {
//             // Share the created video
//             await Share.shareXFiles(
//               [XFile(outputPath)],
//               text: 'Check out my video created with Video Studio!',
//             );
//             _showSuccessSnackbar("Video shared successfully!");
//           } else {
//             _showErrorSnackbar("Created video file is empty");
//           }
//         } else {
//           _showErrorSnackbar("Video file was not created");
//         }
//       } else {
//         // Get failure details
//         final failStackTrace = await session.getFailStackTrace();
//         print('FFmpeg failed with return code: $returnCode');
//         print('Fail stack trace: $failStackTrace');
        
//         _showErrorSnackbar("Failed to create video. Please try again.");
//       }
//     }).catchError((error) {
//       print('FFmpeg execution error: $error');
      
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//       }
//       _showErrorSnackbar("Error creating video: ${error.toString()}");
//     });
    
//   } catch (e, stackTrace) {
//     print('Exception in _shareVideo: $e');
//     print('Stack trace: $stackTrace');
    
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//     _showErrorSnackbar("Error creating video: ${e.toString()}");
//   }
// }




// // Alternative simpler share function if FFmpeg continues to have issues
// Future<void> _shareVideoSimple() async {
//   if (_images.isEmpty) {
//     _showErrorSnackbar('No images to share');
//     return;
//   }

//   _showProcessingDialog("Preparing images...");

//   try {
//     // Instead of creating a video, share the images as a zip or individually
//     final tempDir = await getTemporaryDirectory();
//     final List<XFile> filesToShare = [];

//     // Copy processed images to temp directory for sharing
//     for (int i = 0; i < _processedImages.length; i++) {
//       final tempPath = '${tempDir.path}/image_$i.jpg';
//       await _processedImages[i].copy(tempPath);
//       filesToShare.add(XFile(tempPath));
//     }

//     if (mounted && Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }

//     // Share all images
//     await Share.shareXFiles(
//       filesToShare,
//       text: 'Check out my images from Video Studio!',
//     );
    
//     _showSuccessSnackbar("Images shared successfully!");
    
//   } catch (e) {
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//     _showErrorSnackbar("Error sharing images: ${e.toString()}");
//   }
// }




// Future<void> _initializeFFmpeg() async {
//   try {
//     // Initialize FFmpeg Kit
//     await FFmpegKitConfig.init();
//     print('FFmpeg Kit initialized successfully');
//   } catch (e) {
//     print('Failed to initialize FFmpeg Kit: $e');
//   }
// }

// // // You can also add this initialization method to call in initState
// // Future<void> _initializeFFmpeg() async {
// //   try {
// //     // Initialize FFmpeg Kit configuration (this is the most important part)
// //     print('Initializing FFmpeg Kit...');
    
// //     // Simple initialization without log level setting
// //     // The init() method should resolve the MissingPluginException
    
// //     print('FFmpeg Kit initialized successfully');
// //   } catch (e) {
// //     print('Failed to initialize FFmpeg Kit: $e');
// //   }
// // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//       body: _images.isEmpty ? _buildWelcomeScreen() : _buildVideoEditor(),
//     );
//   }

//   Widget _buildWelcomeScreen() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             const Color(0xFF1A1A2E),
//             const Color(0xFF16213E),
//             const Color(0xFF0F0F23),
//           ],
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.purple.shade400, Colors.blue.shade400],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.video_camera_back, color: Colors.white, size: 24),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Video Studio',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Create stunning videos from images',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Main content
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.purple.shade400.withOpacity(0.3), Colors.blue.shade400.withOpacity(0.3)],
//                         ),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.photo_library_outlined,
//                         size: 60,
//                         color: Colors.white70,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     const Text(
//                       'Create Your Video',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Select multiple images to create a professional video with filters, animations, and background music.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 16,
//                         height: 1.5,
//                       ),
//                     ),
//                     const SizedBox(height: 48),
                    
//                     // Features
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildFeatureItem(Icons.filter_vintage, 'Filters'),
//                         _buildFeatureItem(Icons.animation, 'Animations'),
//                         // _buildFeatureItem(Icons.music_note, 'Music'),
//                       ],
//                     ),
//                     const SizedBox(height: 48),
                    
//                     // Start button
//                     Container(
//                       width: double.infinity,
//                       height: 56,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.purple.shade500, Colors.blue.shade500],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.purple.shade500.withOpacity(0.3),
//                             blurRadius: 12,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(16),
//                           onTap: _pickInitialImages,
//                           child: const Center(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_photo_alternate, color: Colors.white, size: 24),
//                                 SizedBox(width: 12),
//                                 Text(
//                                   'Select Images',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureItem(IconData icon, String label) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.white.withOpacity(0.2)),
//           ),
//           child: Icon(icon, color: Colors.white70, size: 28),
//         ),
//         const SizedBox(height: 12),
// Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildVideoEditor() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             const Color(0xFF1A1A2E),
//             const Color(0xFF0A0A0A),
//           ],
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header with controls
//             _buildHeader(),
            
//             // Main video display
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Stack(
//                     children: [
//                       // Video container
//                       Container(
//                         width: double.infinity,
//                         height: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.black,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: RepaintBoundary(
//                           key: _posterKey,
//                           child: _buildImageDisplay(),
//                         ),
//                       ),
                      
//                       // Play/Pause overlay
//                       if (_showControls)
//                         Positioned.fill(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.transparent,
//                                   Colors.black.withOpacity(0.1),
//                                   Colors.black.withOpacity(0.3),
//                                 ],
//                                 stops: const [0.0, 0.7, 1.0],
//                               ),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Center(
//                               child: ScaleTransition(
//                                 scale: _fabAnimation,
//                                 child: Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.9),
//                                     shape: BoxShape.circle,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.3),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 6),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       borderRadius: BorderRadius.circular(40),
//                                       onTap: _togglePlayback,
//                                       child: Icon(
//                                         _isPlaying ? Icons.pause : Icons.play_arrow,
//                                         color: Colors.black87,
//                                         size: 20,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
            
//             // Progress and time
//             // _buildProgressSection(),
            
//             // Control buttons
//             SlideTransition(
//               position: _slideAnimation,
//               child: _buildControlButtons(),
//             ),
            
//             // Filter and Animation panels
//             if (_showFilters) _buildFilterPanel(),
//             if (_showAnimations) _buildAnimationPanel(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(12),
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Video Editor',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${_images.length} images selected',
//                   style: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.green.withOpacity(0.3)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.timer, color: Colors.green[300], size: 16),
//                 const SizedBox(width: 4),
//                 Text(
//                   '${_elapsedSeconds}s',
//                   style: TextStyle(
//                     color: Colors.green[300],
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageDisplay() {
//     if (_processedImages.isEmpty) {
//       return Container(
//         width: double.infinity,
//         height: 400,
//         color: Colors.grey[900],
//         child: const Center(
//           child: CircularProgressIndicator(color: Colors.white),
//         ),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: 16 / 9,
//       child: _applyAnimation(
//         _applyFilter(
//           Image.file(
//             _processedImages[_currentIndex],
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _applyFilter(Widget child) {
//     switch (_selectedFilter) {
//       case FilterType.blackWhite:
//         return ColorFiltered(
//           colorFilter: const ColorFilter.matrix(<double>[
//             0.2126, 0.7152, 0.0722, 0, 0,
//             0.2126, 0.7152, 0.0722, 0, 0,
//             0.2126, 0.7152, 0.0722, 0, 0,
//             0, 0, 0, 1, 0,
//           ]),
//           child: child,
//         );
//       case FilterType.watercolor:
//         return ColorFiltered(
//           colorFilter: ColorFilter.matrix(<double>[
//             1.2, 0, 0, 0, 0,
//             0, 1.1, 0, 0, 0,
//             0, 0, 1.3, 0, 0,
//             0, 0, 0, 1, 0,
//           ]),
//           child: child,
//         );
//       case FilterType.snow:
//         return ColorFiltered(
//           colorFilter: ColorFilter.matrix(<double>[
//             1.2, 0, 0, 0, 20,
//             0, 1.2, 0, 0, 20,
//             0, 0, 1.4, 0, 30,
//             0, 0, 0, 1, 0,
//           ]),
//           child: child,
//         );
//       case FilterType.waterDrops:
//         return ColorFiltered(
//           colorFilter: ColorFilter.matrix(<double>[
//             1.0, 0, 0, 0, 0,
//             0, 1.0, 0, 0, 0,
//             0, 0, 1.2, 0, 10,
//             0, 0, 0, 1, 0,
//           ]),
//           child: child,
//         );
//       default:
//         return child;
//     }
//   }

//   Widget _buildProgressSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Progress bar
//           Container(
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[800],
//               borderRadius: BorderRadius.circular(2),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(2),
//               child: LinearProgressIndicator(
//                 value: _images.isNotEmpty ? (_currentIndex + 1) / _images.length : 0,
//                 backgroundColor: Colors.transparent,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   Theme.of(context).primaryColor,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           // Image counter
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Image ${_currentIndex + 1} of ${_images.length}',
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 '${(_images.length * _durationPerImageMs / 1000).round()}s total',
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButtons() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Primary controls
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildControlButton(
//                 icon: Icons.add_photo_alternate,
//                 label: 'Add Images',
//                 onTap: _pickInitialImages,
//                 color: Colors.blue,
//               ),
//               // _buildControlButton(
//               //   icon: Icons.music_note,
//               //   label: 'Music',
//               //   onTap: _selectAudio,
//               //   color: Colors.green,
//               //   badge: _selectedAudio != null,
//               // ),
//               _buildControlButton(
//                 icon: Icons.filter_vintage,
//                 label: 'Filters',
//                 onTap: () => setState(() => _showFilters = !_showFilters),
//                 color: Colors.purple,
//                 isActive: _showFilters,
//               ),
//               _buildControlButton(
//                 icon: Icons.animation,
//                 label: 'Effects',
//                 onTap: () => setState(() => _showAnimations = !_showAnimations),
//                 color: Colors.orange,
//                 isActive: _showAnimations,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
          
//           // Export buttons
//           // Row(
//           //   children: [
//           //     Expanded(
//           //       child: Container(
//           //         height: 48,
//           //         decoration: BoxDecoration(
//           //           gradient: LinearGradient(
//           //             colors: [Colors.purple.shade600, Colors.blue.shade600],
//           //           ),
//           //           borderRadius: BorderRadius.circular(12),
//           //         ),
//           //         child: Material(
//           //           color: Colors.transparent,
//           //           child: InkWell(
//           //             borderRadius: BorderRadius.circular(12),
//           //             onTap: _exportVideo,
//           //             child: const Center(
//           //               child: Row(
//           //                 mainAxisAlignment: MainAxisAlignment.center,
//           //                 children: [
//           //                   Icon(Icons.download, color: Colors.white, size: 20),
//           //                   SizedBox(width: 8),
//           //                   Text(
//           //                     'Export',
//           //                     style: TextStyle(
//           //                       color: Colors.white,
//           //                       fontWeight: FontWeight.w600,
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //     const SizedBox(width: 12),
//           //     Expanded(
//           //       child: Container(
//           //         height: 48,
//           //         decoration: BoxDecoration(
//           //           border: Border.all(color: Colors.white.withOpacity(0.3)),
//           //           borderRadius: BorderRadius.circular(12),
//           //         ),
//           //         child: Material(
//           //           color: Colors.transparent,
//           //           child: InkWell(
//           //             borderRadius: BorderRadius.circular(12),
//           //             onTap: _shareVideo,
//           //             child: const Center(
//           //               child: Row(
//           //                 mainAxisAlignment: MainAxisAlignment.center,
//           //                 children: [
//           //                   Icon(Icons.share, color: Colors.white, size: 20),
//           //                   SizedBox(width: 8),
//           //                   Text(
//           //                     'Share',
//           //                     style: TextStyle(
//           //                       color: Colors.white,
//           //                       fontWeight: FontWeight.w600,
//           //                     ),
//           //                   ),
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required Color color,
//     bool isActive = false,
//     bool badge = false,
//   }) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: isActive ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isActive ? color.withOpacity(0.5) : Colors.white.withOpacity(0.2),
//             ),
//           ),
//           child: Stack(
//             children: [
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(16),
//                   onTap: onTap,
//                   child: Center(
//                     child: Icon(
//                       icon,
//                       color: isActive ? color : Colors.white70,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ),
//               if (badge)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterPanel() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Filters',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => setState(() => _showFilters = false),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 100,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: FilterType.values.length,
//               separatorBuilder: (context, index) => const SizedBox(width: 12),
//               itemBuilder: (context, index) {
//                 final filter = FilterType.values[index];
//                 final isSelected = _selectedFilter == filter;
                
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() => _selectedFilter = filter);
//                     if (filter != FilterType.none) {
//                       _applySelectedFilter();
//                     } else {
//                       setState(() => _processedImages = List.from(_images));
//                     }
//                   },
//                   child: Container(
//                     width: 80,
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.purple.withOpacity(0.3) : Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected ? Colors.purple : Colors.white.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           _getFilterIcon(filter),
//                           color: isSelected ? Colors.purple : Colors.white70,
//                           size: 24,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _getFilterName(filter),
//                           style: TextStyle(
//                             color: isSelected ? Colors.purple : Colors.white70,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimationPanel() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Animations',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => setState(() => _showAnimations = false),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 20),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 100,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: AnimationType.values.length,
//               separatorBuilder: (context, index) => const SizedBox(width: 12),
//               itemBuilder: (context, index) {
//                 final animation = AnimationType.values[index];
//                 final isSelected = _selectedAnimation == animation;
                
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() => _selectedAnimation = animation);
//                     if (animation != AnimationType.none && _isPlaying) {
//                       _startAnimationTimer();
//                     } else if (animation == AnimationType.none) {
//                       _animationTimer?.cancel();
//                     }
//                   },
//                   child: Container(
//                     width: 80,
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected ? Colors.orange : Colors.white.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           _getAnimationIcon(animation),
//                           color: isSelected ? Colors.orange : Colors.white70,
//                           size: 24,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _getAnimationName(animation),
//                           style: TextStyle(
//                             color: isSelected ? Colors.orange : Colors.white70,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getFilterIcon(FilterType filter) {
//     switch (filter) {
//       case FilterType.none:
//         return Icons.filter_none;
//       case FilterType.blackWhite:
//         return Icons.filter_b_and_w;
//       case FilterType.watercolor:
//         return Icons.palette;
//       case FilterType.snow:
//         return Icons.ac_unit;
//       case FilterType.waterDrops:
//         return Icons.water_drop;
//     }
//   }

//   String _getFilterName(FilterType filter) {
//     switch (filter) {
//       case FilterType.none:
//         return 'None';
//       case FilterType.blackWhite:
//         return 'B&W';
//       case FilterType.watercolor:
//         return 'Watercolor';
//       case FilterType.snow:
//         return 'Snow';
//       case FilterType.waterDrops:
//         return 'Drops';
//     }
//   }

//   IconData _getAnimationIcon(AnimationType animation) {
//     switch (animation) {
//       case AnimationType.none:
//         return Icons.pause;
//       case AnimationType.leftRight:
//         return Icons.swap_horiz;
//       case AnimationType.upDown:
//         return Icons.swap_vert;
//       case AnimationType.window:
//         return Icons.zoom_out_map;
//       case AnimationType.gradient:
//         return Icons.gradient;
//       case AnimationType.transition:
//         return Icons.face;
//       case AnimationType.thaw:
//         return Icons.blur_circular;
//       case AnimationType.scale:
//         return Icons.zoom_in;
//     }
//   }

//   String _getAnimationName(AnimationType animation) {
//     switch (animation) {
//       case AnimationType.none:
//         return 'None';
//       case AnimationType.leftRight:
//         return 'Pan H';
//       case AnimationType.upDown:
//         return 'Pan V';
//       case AnimationType.window:
//         return 'Zoom';
//       case AnimationType.gradient:
//         return 'Color';
//       case AnimationType.transition:
//         return 'Fade';
//       case AnimationType.thaw:
//         return 'Reveal';
//       case AnimationType.scale:
//         return 'Pulse';
//     }
//   }

//   void _selectAudio() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AudioSelectionScreen(
//           onAudioSelected: (audio) {
//             setState(() => _selectedAudio = audio);
//             // _showSuccessSnackbar('Audio selected: ${audio.name}');
//           },
//         ),
//       ),
//     );
//   }
// }