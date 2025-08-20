
// import 'package:edit_ezy_project/models/poster_size_model.dart';
// import 'package:edit_ezy_project/providers/language/language_provider.dart';
// import 'package:edit_ezy_project/views/auth/navbar_screen.dart';
// import 'package:edit_ezy_project/views/poster/poster_creation.dart';
// import 'package:flutter/material.dart';

// class CreatePost extends StatefulWidget {
//   const CreatePost({super.key});

//   @override
//   State<CreatePost> createState() => _CreatePostState();
// }

// class _CreatePostState extends State<CreatePost> {
//   final List<Map<String, String>> postTypes = const [
//     {"title": "square_post", "size": "2400*2400"},
//     {"title": "story_post", "size": "750*1334"},
//     {"title": "cover_picture", "size": "812*312"},
//     {"title": "display_picture", "size": "1200*1200"},
//     {"title": "instagram_post", "size": "1080*1350"},
//     {"title": "youtube_thumbnail", "size": "1280*720"},
//     {"title": "a4_size", "size": "2480*3507"},
//     {"title": "certificate", "size": "850*1100"},
//   ];

//   String search = '';
//   String selectedFilter = 'All';
//   // final List<String> filters = ['All', 'Social', 'Print', 'Profile', 'Cover'];

//   List<Map<String, String>> get filteredList {
//     final q = search.trim().toLowerCase();
//     return postTypes.where((p) {
//       final title = p['title']!.toLowerCase();
//       final fitsSearch = q.isEmpty || title.contains(q);
//       final fitsFilter = (selectedFilter == 'All') ||
//           (selectedFilter == 'Social' && (title.contains('post') || title.contains('story') || title.contains('instagram')) ) ||
//           (selectedFilter == 'Print' && (title.contains('a4') || title.contains('certificate')) ) ||
//           (selectedFilter == 'Profile' && (title.contains('display') || title.contains('display_picture')) ) ||
//           (selectedFilter == 'Cover' && title.contains('cover'));
//       return fitsSearch && fitsFilter;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leadingWidth: 70,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: IconButton(
//             onPressed: () => Navigator.pushReplacement(
//                 context, MaterialPageRoute(builder: (_) => const NavbarScreen())),
//             icon: const Icon(Icons.arrow_back_ios),
//           ),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             AppText('custom_post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             SizedBox(height: 2),
//             Text('Choose a canvas size or create custom', style: TextStyle(fontSize: 12))
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.help_outline),
//             tooltip: 'Help',
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//         child: Column(
//           children: [
//             // Search + Sort Row
           

//             const SizedBox(height: 14),

            
//             const SizedBox(height: 12),

//             // Grid
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.95,
//                 ),
//                 itemCount: filteredList.length,
//                 itemBuilder: (context, index) {
//                   final post = filteredList[index];
//                   final posterSize = PosterSize.fromMap(post);

//                   return Material(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(14),
//                     elevation: 2,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(14),
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PosterMaker(posterSize: posterSize),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
                          

//                             const SizedBox(height: 10),

                   
//                             Row(
//                               children: [
//                                 SizedBox(height: 50,),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(' ${post['size']} ', style: const TextStyle(fontSize: 12)),
//                                 ),
//                                 const Spacer(),
                               
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }


















import 'package:edit_ezy_project/models/poster_size_model.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/views/auth/navbar_screen.dart';
import 'package:edit_ezy_project/views/poster/poster_creation.dart';
import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final List<Map<String, String>> postTypes = const [
    {"title": "square_post", "size": "2400*2400"},
    {"title": "story_post", "size": "750*1334"},
    {"title": "cover_picture", "size": "812*312"},
    {"title": "display_picture", "size": "1200*1200"},
    {"title": "instagram_post", "size": "1080*1350"},
    {"title": "youtube_thumbnail", "size": "1280*720"},
    {"title": "a4_size", "size": "2480*3507"},
    {"title": "certificate", "size": "850*1100"},
  ];

  String search = '';
  String selectedFilter = 'All';

  List<Map<String, String>> get filteredList {
    final q = search.trim().toLowerCase();
    return postTypes.where((p) {
      final title = p['title']!.toLowerCase();
      final fitsSearch = q.isEmpty || title.contains(q);
      final fitsFilter = (selectedFilter == 'All') ||
          (selectedFilter == 'Social' &&
              (title.contains('post') ||
                  title.contains('story') ||
                  title.contains('instagram'))) ||
          (selectedFilter == 'Print' &&
              (title.contains('a4') || title.contains('certificate'))) ||
          (selectedFilter == 'Profile' &&
              (title.contains('display') || title.contains('display_picture'))) ||
          (selectedFilter == 'Cover' && title.contains('cover'));
      return fitsSearch && fitsFilter;
    }).toList();
  }

  String humanizeTitle(String raw) {
    // e.g., "square_post" -> "Square Post"
    final parts = raw.split(RegExp(r'[_\s]+'));
    final capitalized = parts.map((p) {
      if (p.isEmpty) return '';
      return p[0].toUpperCase() + p.substring(1);
    }).join(' ');
    return capitalized.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const NavbarScreen())),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppText('custom_post',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 2),
            Text('Choose a size to  create custom poster',
                style: TextStyle(fontSize: 12))
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          children: [
            // (Optional) Search field if you want - not required for alignment fix
            // TextField(
            //   decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search'),
            //   onChanged: (v) => setState(() => search = v),
            // ),

            const SizedBox(height: 14),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final post = filteredList[index];
                  final posterSize = PosterSize.fromMap(post);
                  final title = humanizeTitle(post['title'] ?? '');

                  return Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PosterMaker(posterSize: posterSize),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title (left aligned)
                            // Text(
                            //   title,
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w700,
                            //     fontSize: 14,
                            //     color: Theme.of(context).textTheme.bodyLarge?.color,
                            //   ),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),

                            const SizedBox(height: 50),

                            // Size chip (left aligned)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                // color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                post['size'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                              ),
                            ),

                            const Spacer(),

                            // Bottom row with optional icon aligned to right
                            Row(
                              children: [
                                // you can add a small subtitle or empty space here if needed
                                const SizedBox.shrink(),
                                const Spacer(),
                                // Material(
                                //   color: Colors.transparent,
                                //   child: Icon(
                                //     Icons.arrow_forward_ios,
                                //     size: 16,
                                //     color: Theme.of(context).iconTheme.color,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
