
import 'package:edit_ezy_project/views/poster/image_to_video_screen.dart';
import 'package:flutter/material.dart';

class AddImage extends StatelessWidget {
  const AddImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a light background to feel modern and professional
      backgroundColor: const Color(0xFFF7F8FB),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0.8,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: const AppText(
      //     'add_image',
      //     style: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             
              const SizedBox(height: 18),

              // Big image placeholder card
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ],
                        border: Border.all(
                          color: const Color(0xFFE6E9F2),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Placeholder icon
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadImage()));
                            },
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFDDE3F7), width: 1.6),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 48,
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Add Your Video Here",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // const SizedBox(height: 18),

              // // Primary actions row
              

              // const SizedBox(height: 14),

              // // Helpful tips / small actions
              
              // const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      // Modern, subtle bottom navigation
     
    );
  }
}
