// File: logo_making_screen.dart
// Professional redesigned LogoMakingScreen
import 'package:edit_ezy_project/models/logo_model.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/logo/logo_provider.dart';
import 'package:edit_ezy_project/views/logo/customize_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LogoMakingScreen extends StatefulWidget {
  const LogoMakingScreen({super.key});

  @override
  State<LogoMakingScreen> createState() => _LogoMakingScreenState();
}

class _LogoMakingScreenState extends State<LogoMakingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // fetch logos after first build
    Future.microtask(() =>
        Provider.of<LogoProvider>(context, listen: false).fetchLogos());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.06),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // const Icon(Icons.brush, size: 22, color: Colors.deepPurple),
            const SizedBox(width: 50),
            const AppText(
              "Logo Maker",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // clear search
              _searchController.clear();
            },
            icon: const Icon(Icons.clear, color: Colors.black54),
            tooltip: 'Clear',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildSearchField(context),
          ),
        ),
      ),
      body: Consumer<LogoProvider>(
        builder: (context, logoProvider, _) {
          if (logoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (logoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${logoProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => logoProvider.fetchLogos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredLogos = logoProvider.logos.where((logo) {
            return logo.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredLogos.isEmpty) {
            return _emptyState(context);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredLogos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                return _ProfessionalLogoCard(logo: filteredLogos[index]);
              },
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     // action for adding/uploading new logo
      //     // you can navigate to your add screen here
      //   },
      //   icon: const Icon(Icons.add),
      //   label: const Text('Add Logo'),
      //   backgroundColor: Colors.deepPurple,
      // ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search your logos here',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 18),
            const Text(
              'No logos found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different name or add a new logo to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     // navigate to add screen
            //   },
            //   icon: const Icon(Icons.add),
            //   label: const Text(''),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.deepPurple,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalLogoCard extends StatelessWidget {
  final LogoItem logo;
  const _ProfessionalLogoCard({required this.logo, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditLogo(image: logo.image)));
      },
      // onTap: () => _openOptions(context, logo),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (logo.image.isNotEmpty)
                      Hero(
                        tag: 'logo_${logo.id}',
                        child: Image.network(
                          logo.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => _placeholderBox(),
                        ),
                      )
                    else
                      _placeholderBox(),
                    // top-right badge
                    // Positioned(
                    //   top: 8,
                    //   right: 8,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.black45,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: const [
                    //         Icon(Icons.layers, size: 14, color: Colors.white),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(width: 50,),
                  Text(
                    logo.name,
                    // textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Expanded(
                      //   child: Text(
                      //     logo.name ?? 'Logo',
                      //     style: const TextStyle(fontSize: 12, color: Colors.grey),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                      // IconButton(
                      //   onPressed: () {
                      //     // favorite toggle can be implemented via provider
                      //   },
                      //   icon: const Icon(Icons.favorite_border, size: 18),
                      //   tooltip: 'Favorite',
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 42, color: Colors.grey),
      ),
    );
  }

  void _openOptions(BuildContext context, LogoItem logo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.36,
          minChildSize: 0.22,
          maxChildSize: 0.8,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          logo.image,
                          height: 74,
                          width: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 74,
                            width: 74,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(logo.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              logo.description ?? 'High quality logo template',
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditLogo(image: logo.image),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit,color: Colors.white,),
                                  label: const Text('Edit Your Logo',style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Expanded(
                              //   child: OutlinedButton.icon(
                              //     onPressed: () {
                              //       // implement download/save
                              //     },
                              //     icon: const Icon(Icons.download),
                              //     label: const Text('Download'),
                              //     style: OutlinedButton.styleFrom(
                              //       padding: const EdgeInsets.symmetric(vertical: 14),
                              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          const SizedBox(height: 16),
                    
                          const SizedBox(height: 8),
                          // Wrap(
                
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}