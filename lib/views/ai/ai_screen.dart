// // import 'package:edit_ezy_project/providers/language/language_provider.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:speech_to_text/speech_to_text.dart' as stt;

// // class AiScreen extends StatefulWidget {
// //   const AiScreen({super.key});

// //   @override
// //   State<AiScreen> createState() => _ChatScreenState();
// // }

// // class _ChatScreenState extends State<AiScreen> {
// //   final TextEditingController _messageController = TextEditingController();
// //   final List<Map<String, String>> _messages = [];
// //   bool _isLoading = false;
// //   final ScrollController _scrollController = ScrollController();

// //   late stt.SpeechToText _speech;
// //   bool _isListening = false;

// //   static const String apiKey = 'AIzaSyA8Sp_taG6U6AXoUMvp3TvS2KvmWVUlWWE';
// //   static const String apiUrl =
// //       "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _speech = stt.SpeechToText();
// //     // Add welcome message
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       setState(() {
// //         // _messages.add({
// //         //   'role': 'bot', 
// //         //   'text': AppText.translate(context, 'ai_welcome_message')
// //         // });
// //       });
// //     });
// //   }

// //   Future<void> _sendMessage() async {
// //     final userMessage = _messageController.text.trim();
// //     if (userMessage.isEmpty) return;

// //     setState(() {
// //       _messages.add({'role': 'user', 'text': userMessage});
// //       _isLoading = true;
// //       _messageController.clear();
// //     });

// //     // Scroll to bottom when new message is added
// //     _scrollToBottom();

// //     try {
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode({
// //           "contents": [
// //             {
// //               "parts": [
// //                 {"text": userMessage}
// //               ]
// //             }
// //           ]
// //         }),
// //       );

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         final botReply = data['candidates'][0]['content']['parts'][0]['text'];

// //         setState(() {
// //           _messages.add({'role': 'bot', 'text': botReply});
// //         });
// //       } else {
// //         setState(() {
// //           _messages.add({'role': 'bot', 'text': 'Sorry, I encountered an error. Please try again.'});
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _messages.add({'role': 'bot', 'text': 'Connection issue. Please check your internet and try again.'});
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //       _scrollToBottom();
// //     }
// //   }

// //   void _scrollToBottom() {
// //     if (_scrollController.hasClients) {
// //       _scrollController.animateTo(
// //         _scrollController.position.maxScrollExtent,
// //         duration: const Duration(milliseconds: 300),
// //         curve: Curves.easeOut,
// //       );
// //     }
// //   }

// //   void _listen() async {
// //     if (!_isListening) {
// //       bool available = await _speech.initialize(
// //         onStatus: (status) {
// //           if (status == 'done') {
// //             setState(() => _isListening = false);
// //           }
// //         },
// //         onError: (error) => setState(() => _isListening = false),
// //       );
// //       if (available) {
// //         setState(() => _isListening = true);
// //         _speech.listen(
// //           onResult: (result) {
// //             setState(() {
// //               _messageController.text = result.recognizedWords;
// //             });
// //           },
// //         );
// //       }
// //     } else {
// //       setState(() => _isListening = false);
// //       _speech.stop();
// //     }
// //   }

// //   Widget _buildMessage(Map<String, String> message) {
// //     final isUser = message['role'] == 'user';
// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
// //         crossAxisAlignment: CrossAxisAlignment.end,
// //         children: [
// //           if (!isUser)
// //             Container(
// //               width: 30,
// //               height: 30,
// //               decoration: BoxDecoration(
// //                 color: Colors.blue[700],
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
// //             ),
// //           const SizedBox(width: 8),
// //           Flexible(
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //               decoration: BoxDecoration(
// //                 color: isUser ? Colors.blue[700] : Colors.grey[100],
// //                 borderRadius: BorderRadius.only(
// //                   topLeft: const Radius.circular(16),
// //                   topRight: const Radius.circular(16),
// //                   bottomLeft: Radius.circular(isUser ? 16 : 4),
// //                   bottomRight: Radius.circular(isUser ? 4 : 16),
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.1),
// //                     blurRadius: 2,
// //                     offset: const Offset(0, 1),
// //                   )
// //                 ],
// //               ),
// //               child: Text(
// //                 message['text'] ?? '',
// //                 style: TextStyle(
// //                   color: isUser ? Colors.white : Colors.grey[800],
// //                   fontSize: 15,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           if (isUser)
// //             const SizedBox(width: 8),
// //           if (isUser)
// //             Container(
// //               width: 30,
// //               height: 30,
// //               decoration: const BoxDecoration(
// //                 color: Colors.blueAccent,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(Icons.person, color: Colors.white, size: 16),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           onPressed: () {
// //             Navigator.of(context).pop();
// //           }, 
// //           icon: const Icon(Icons.arrow_back_ios, size: 20),
// //         ),
// //         title: Text(
// //           AppText.translate(context, 'chat_with_ai'),
// //           style: const TextStyle(fontWeight: FontWeight.w600),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: Colors.blue[700],
// //         foregroundColor: Colors.white,
// //         elevation: 2,
// //         shadowColor: Colors.black.withOpacity(0.1),
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.blue[50],
// //               border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 16),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     AppText.translate(context, 'ai_assistant_tip'),
// //                     style: TextStyle(
// //                       color: Colors.grey[700],
// //                       fontSize: 13,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: Container(
// //               color: Colors.grey[50],
// //               child: _messages.isEmpty
// //                   ? Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(Icons.chat_bubble_outline, 
// //                               size: 64, color: Colors.grey[300]),
// //                           const SizedBox(height: 16),
// //                           Text(
// //                             AppText.translate(context, 'start_conversation'),
// //                             style: TextStyle(
// //                               color: Colors.grey[500],
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     )
// //                   : ListView.builder(
// //                       controller: _scrollController,
// //                       padding: const EdgeInsets.all(16),
// //                       itemCount: _messages.length,
// //                       itemBuilder: (context, index) {
// //                         return _buildMessage(_messages[index]);
// //                       },
// //                     ),
// //             ),
// //           ),
// //           if (_isLoading)
// //             Padding(
// //               padding: const EdgeInsets.symmetric(vertical: 16),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   SizedBox(
// //                     width: 20,
// //                     height: 20,
// //                     child: CircularProgressIndicator(
// //                       strokeWidth: 2,
// //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Text(
// //                     AppText.translate(context, 'ai_thinking'),
// //                     style: TextStyle(
// //                       color: Colors.grey[600],
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           Container(
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               border: Border(top: BorderSide(color: Colors.grey[200]!)),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 8,
// //                   offset: const Offset(0, -2),
// //                 )
// //               ],
// //             ),
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey[100],
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: IconButton(
// //                     icon: Icon(_isListening ? Icons.mic_off : Icons.mic, size: 22),
// //                     color: _isListening ? Colors.red : Colors.blue[700],
// //                     onPressed: _listen,
// //                     splashRadius: 20,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[100],
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: TextField(
// //                       controller: _messageController,
// //                       textInputAction: TextInputAction.send,
// //                       onSubmitted: (_) => _sendMessage(),
// //                       decoration: InputDecoration(
// //                         hintText: AppText.translate(context, 'ask_me_anything'),
// //                         border: InputBorder.none,
// //                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //                         hintStyle: TextStyle(color: Colors.grey[600]),
// //                       ),
// //                       minLines: 1,
// //                       maxLines: 3,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.blue[700],
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: IconButton(
// //                     onPressed: _sendMessage,
// //                     icon: const Icon(Icons.send, size: 22),
// //                     color: Colors.white,
// //                     splashRadius: 20,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _messageController.dispose();
// //     _scrollController.dispose();
// //     _speech.stop();
// //     super.dispose();
// //   }
// // }

















// import 'package:edit_ezy_project/providers/language/language_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class AiScreen extends StatefulWidget {
//   const AiScreen({super.key});

//   @override
//   State<AiScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<AiScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//   bool _isLoading = false;
//   final ScrollController _scrollController = ScrollController();

//   stt.SpeechToText? _speech;
//   bool _isListening = false;
//   bool _speechAvailable = false;
//   String _lastError = '';

//   static const String apiKey = 'AIzaSyA8Sp_taG6U6AXoUMvp3TvS2KvmWVUlWWE';
//   static const String apiUrl =
//       "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";
  
//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//     _speech = stt.SpeechToText();
//     // Add welcome message
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _messages.add({
//           'role': 'bot', 
//           'text': AppText.translate(context, 'ai_welcome_message')
//         });
//       });
//     });
//   }

//   // Initialize speech-to-text
//   // void _initSpeech() async {
//   //   _speech = stt.SpeechToText();
    
//   //   try {
//   //     var available = await _speech.initialize(
//   //       onStatus: (status) {
//   //         print('Speech status: $status');
//   //         if (status == 'done') {
//   //           setState(() => _isListening = false);
//   //         }
//   //       },
//   //       onError: (errorNotification) {
//   //         print('Speech error: ${errorNotification.errorMsg}');
//   //         setState(() {
//   //           _lastError = '${errorNotification.errorMsg}';
//   //           _isListening = false;
//   //         });
//   //       },
//   //     );
      
//   //     setState(() => _speechAvailable = available);
      
//   //     if (!available) {
//   //       setState(() => _lastError = 'Speech recognition not available');
//   //     }
//   //   } catch (e) {
//   //     setState(() => _lastError = 'Failed to initialize speech: $e');
//   //   }
//   // }



//   void _initSpeech() async {
//   try {
//     if (_speech == null) {
//       setState(() => _lastError = 'Speech instance not created');
//       return;
//     }

//     final available = await _speech!.initialize(
//       onStatus: (status) {
//         debugPrint('Speech status: $status');
//         // speech_to_text uses 'notListening' or 'done' etc depending on version
//         if (status == 'done' || status == 'notListening') {
//           setState(() => _isListening = false);
//         }
//       },
//       onError: (errorNotification) {
//         debugPrint('Speech error: ${errorNotification.errorMsg}');
//         setState(() {
//           _lastError = errorNotification.errorMsg ?? 'Unknown speech error';
//           _isListening = false;
//         });
//       },
//     );

//     setState(() {
//       _speechAvailable = available;
//       if (!available) _lastError = 'Speech recognition not available or permissions denied';
//     });
//   } catch (e, st) {
//     debugPrint('Failed to initialize speech: $e\n$st');
//     setState(() => _lastError = 'Failed to initialize speech: $e');
//   }
// }

//   // void _listen() async {
//   //   if (!_isListening) {
//   //     bool available = await _speech.initialize();
//   //     if (available) {
//   //       setState(() => _isListening = true);
//   //       _speech.listen(
//   //         onResult: (result) {
//   //           setState(() {
//   //             _messageController.text = result.recognizedWords;
//   //           });
//   //         },
//   //       );
//   //     }
//   //   } else {
//   //     setState(() => _isListening = false);
//   //     _speech.stop();
//   //   }
//   // }


// void _listen() async {
//   if (_speech == null) {
//     setState(() => _lastError = 'Speech instance not ready');
//     return;
//   }

//   if (!_speechAvailable) {
//     setState(() => _lastError = 'Microphone not available / permission denied');
//     return;
//   }

//   if (_isListening) {
//     try {
//       await _speech!.stop();
//     } catch (e) {
//       debugPrint('Error stopping speech: $e');
//     }
//     setState(() => _isListening = false);
//     return;
//   }

//   setState(() {
//     _lastError = '';
//     _isListening = true;
//   });

//   try {
//     await _speech!.listen(
//       onResult: (result) {
//         setState(() {
//           _messageController.text = result.recognizedWords;
//         });
//       },
//       listenFor: const Duration(seconds: 60),
//       pauseFor: const Duration(seconds: 3),
//       partialResults: true,
//       localeId: null,
//     );
//   } catch (e) {
//     debugPrint('Error starting listen: $e');
//     setState(() {
//       _isListening = false;
//       _lastError = 'Error starting listen: $e';
//     });
//   }
// }

//   Future<void> _sendMessage() async {
//     final userMessage = _messageController.text.trim();
//     if (userMessage.isEmpty) return;

//     setState(() {
//       _messages.add({'role': 'user', 'text': userMessage});
//       _isLoading = true;
//       _messageController.clear();
//     });

//     // Scroll to bottom when new message is added
//     _scrollToBottom();

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": userMessage}
//               ]
//             }
//           ]
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final botReply = data['candidates'][0]['content']['parts'][0]['text'];

//         setState(() {
//           _messages.add({'role': 'bot', 'text': botReply});
//         });
//       } else {
//         setState(() {
//           _messages.add({'role': 'bot', 'text': 'Sorry, I encountered an error. Please try again.'});
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add({'role': 'bot', 'text': 'Connection issue. Please check your internet and try again.'});
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // void _listen() async {
//   //   if (!_speechAvailable) {
//   //     setState(() {
//   //       _lastError = 'Speech not available';
//   //     });
//   //     return;
//   //   }
    
//   //   if (_isListening) {
//   //     // Stop listening
//   //     try {
//   //       await _speech.stop();
//   //       setState(() => _isListening = false);
//   //     } catch (e) {
//   //       setState(() => _lastError = 'Error stopping speech: $e');
//   //     }
//   //   } else {
//   //     // Start listening
//   //     try {
//   //       setState(() {
//   //         _isListening = true;
//   //         _lastError = '';
//   //       });
        
//   //       await _speech.listen(
//   //         onResult: (result) {
//   //           setState(() {
//   //             if (result.finalResult) {
//   //               _messageController.text = result.recognizedWords;
//   //             }
//   //           });
//   //         },
//   //         listenFor: const Duration(seconds: 30),
//   //         pauseFor: const Duration(seconds: 5),
//   //         partialResults: true,
//   //         localeId: 'en_US', // You can change this based on user preference
//   //       );
//   //     } catch (e) {
//   //       setState(() {
//   //         _isListening = false;
//   //         _lastError = 'Error starting speech: $e';
//   //       });
//   //     }
//   //   }
//   // }

//   Widget _buildMessage(Map<String, String> message) {
//     final isUser = message['role'] == 'user';
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser)
//             Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Colors.blue[700],
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
//             ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isUser ? Colors.blue[700] : Colors.grey[100],
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(16),
//                   topRight: const Radius.circular(16),
//                   bottomLeft: Radius.circular(isUser ? 16 : 4),
//                   bottomRight: Radius.circular(isUser ? 4 : 16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   )
//                 ],
//               ),
//               child: Text(
//                 message['text'] ?? '',
//                 style: TextStyle(
//                   color: isUser ? Colors.white : Colors.grey[800],
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ),
//           if (isUser)
//             const SizedBox(width: 8),
//           if (isUser)
//             Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 color: Colors.blueAccent,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.person, color: Colors.white, size: 16),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           }, 
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         title: Text(
//           AppText.translate(context, 'chat_with_ai'),
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue[700],
//         foregroundColor: Colors.white,
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 16),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     AppText.translate(context, 'ai_assistant_tip'),
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_lastError.isNotEmpty)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               color: Colors.orange[50],
//               child: Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.orange[700], size: 16),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       _lastError,
//                       style: TextStyle(
//                         color: Colors.orange[700],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Expanded(
//             child: Container(
//               color: Colors.grey[50],
//               child: _messages.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.chat_bubble_outline, 
//                               size: 64, color: Colors.grey[300]),
//                           const SizedBox(height: 16),
//                           Text(
//                             AppText.translate(context, 'start_conversation'),
//                             style: TextStyle(
//                               color: Colors.grey[500],
//                               fontSize: 16,
//                             ),
//                           ),
//                           if (!_speechAvailable)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 16),
//                               child: Text(
//                                 'Microphone access not available',
//                                 style: TextStyle(
//                                   color: Colors.red[300],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _messages.length,
//                       itemBuilder: (context, index) {
//                         return _buildMessage(_messages[index]);
//                       },
//                     ),
//             ),
//           ),
//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     AppText.translate(context, 'ai_thinking'),
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Colors.grey[200]!)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, -2),
//                 )
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: _speechAvailable ? Colors.grey[100] : Colors.grey[200],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       _isListening ? Icons.mic_off : Icons.mic, 
//                       size: 22,
//                       color: _speechAvailable 
//                         ? (_isListening ? Colors.red : Colors.blue[700])
//                         : Colors.grey,
//                     ),
//                     onPressed: _speechAvailable ? _listen : null,
//                     splashRadius: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: TextField(
//                       controller: _messageController,
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: (_) => _sendMessage(),
//                       decoration: InputDecoration(
//                         hintText: AppText.translate(context, 'ask_me_anything'),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         hintStyle: TextStyle(color: Colors.grey[600]),
//                       ),
//                       minLines: 1,
//                       maxLines: 3,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.blue[700],
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     onPressed: _sendMessage,
//                     icon: const Icon(Icons.send, size: 22),
//                     color: Colors.white,
//                     splashRadius: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _speech?.stop();
//     super.dispose();
//   }
// }




























import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  stt.SpeechToText? _speech; // nullable to avoid LateInitializationError
  bool _isListening = false;
  bool _speechAvailable = false;
  String _lastError = '';

  static const String apiKey = 'AIzaSyA8Sp_taG6U6AXoUMvp3TvS2KvmWVUlWWE';
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

  @override
  void initState() {
    super.initState();
    // Ensure we request permission first and only initialize if granted.
    _prepareSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        // _messages.add({
        //   'role': 'bot',
        //   'text': AppText.translate(context, 'ai_welcome_message')
        // });
      });
    });
  }

  // Request microphone permission, then create & initialize speech instance.
  Future<void> _prepareSpeech() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          setState(() {
            // _lastError = 'Microphone permission denied. Enable in settings.';
            _speechAvailable = false;
          });
          return;
        }
      }

      // Create instance (only once)
      _speech ??= stt.SpeechToText();
      await _initSpeech();
    } catch (e, st) {
      debugPrint('Error preparing speech: $e\n$st');
      setState(() {
        _lastError = 'Error preparing speech: $e';
        _speechAvailable = false;
      });
    }
  }

  Future<void> _initSpeech() async {
    if (_speech == null) {
      setState(() {
        _lastError = 'Speech instance not created';
        _speechAvailable = false;
      });
      return;
    }

    try {
      final available = await _speech!.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech error: ${errorNotification.errorMsg}');
          if (mounted) {
            setState(() {
              _lastError = errorNotification.errorMsg ?? 'Unknown speech error';
              _isListening = false;
            });
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
        if (!available) _lastError = 'Speech recognition not available';
      });
    } catch (e, st) {
      debugPrint('Failed to initialize speech: $e\n$st');
      if (mounted) {
        setState(() {
          _lastError = 'Failed to initialize speech: $e';
          _speechAvailable = false;
        });
      }
    }
  }

  void _listen() async {
    // Guard: ensure instance exists and availability is true
    if (_speech == null) {
      setState(() => _lastError = 'Speech instance not ready. Try again.');
      return;
    }
    if (!_speechAvailable) {
      setState(() => _lastError = 'Microphone not available or permission not granted.');
      return;
    }

    if (_isListening) {
      try {
        await _speech!.stop();
      } catch (e) {
        debugPrint('Error stopping speech: $e');
      }
      if (mounted) setState(() => _isListening = false);
      return;
    }

    // Start listening
    if (mounted) setState(() {
      _lastError = '';
      _isListening = true;
    });

    try {
      await _speech!.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: null,
      );
    } catch (e) {
      debugPrint('Error starting listen: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _lastError = 'Error starting listen: $e';
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add({'role': 'bot', 'text': botReply});
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'text': 'Sorry, I encountered an error. Please try again.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Connection issue. Please check your internet and try again.'});
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[700] : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ],
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.grey[800],
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser)
            const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          AppText.translate(context, 'chat_with_ai'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppText.translate(context, 'ai_assistant_tip'),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_lastError.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastError,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, 
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            AppText.translate(context, 'start_conversation'),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          if (!_speechAvailable)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              // child: Text(
                              //   'Microphone access not available',
                              //   style: TextStyle(
                              //     color: Colors.red[300],
                              //     fontSize: 14,
                              //   ),
                              // ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppText.translate(context, 'ai_thinking'),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     color: _speechAvailable ? Colors.grey[100] : Colors.grey[200],
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: IconButton(
                //     icon: Icon(
                //       _isListening ? Icons.mic_off : Icons.mic, 
                //       size: 22,
                //       color: _speechAvailable 
                //         ? (_isListening ? Colors.red : Colors.blue[700])
                //         : Colors.grey,
                //     ),
                //     onPressed: _speechAvailable ? _listen : () async {
                //       // Try re-preparing speech if user taps mic while unavailable
                //       await _prepareSpeech();
                //     },
                //     splashRadius: 20,
                //   ),
                // ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: AppText.translate(context, 'ask_me_anything'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, size: 22),
                    color: Colors.white,
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech?.stop();
    super.dispose();
  }
}
