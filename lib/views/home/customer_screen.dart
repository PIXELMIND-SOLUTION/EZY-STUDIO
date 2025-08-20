// // import 'dart:ui';
// // import 'package:edit_ezy_project/helper/storage_helper.dart';
// // import 'package:edit_ezy_project/providers/customer/customer_provider.dart';
// // import 'package:edit_ezy_project/providers/language/language_provider.dart';
// // import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
// // import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
// // import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
// // import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class CustomerScreen extends StatefulWidget {
// //   const CustomerScreen({super.key});

// //   @override
// //   State<CustomerScreen> createState() => _AddCustomersState();
// // }

// // class _AddCustomersState extends State<CustomerScreen> with TickerProviderStateMixin {
// //   String? userId;
// //   bool _isLoading = true;
// //   bool _isSearching = false;
// //   String _searchQuery = '';
// //   TextEditingController _searchController = TextEditingController();
// //   late AnimationController _animationController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       duration: const Duration(milliseconds: 800),
// //       vsync: this,
// //     );
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
// //     );
// //     _loadUserData();
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _loadUserData() async {
// //     final userData = await AuthPreferences.getUserData();
// //     print(userData);
// //     if (userData != null && userData.user != null) {
// //       setState(() {
// //         userId = userData.user.id;
// //       });
// //       await _loadData();
// //       _animationController.forward();
// //       print('User ID: $userId');
// //     } else {
// //       print("No User ID");
// //     }
// //   }

// //   Future<void> _loadData() async {
// //     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       await provider.fetchUser(userId.toString());
// //     } catch (e) {
// //       print('Error fetching customers: $e');
// //       if (mounted) {
// //         _showErrorSnackBar('Failed to load customers: $e');
// //       }
// //     }

// //     if (mounted) {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<void> _refreshData() async {
// //     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);
// //     await provider.fetchUser(userId.toString());
// //   }

// //   void _showErrorSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(Icons.error_outline, color: Colors.white, size: 20),
// //             const SizedBox(width: 12),
// //             Expanded(child: Text(message)),
// //           ],
// //         ),
// //         backgroundColor: const Color(0xFFE53E3E),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         margin: const EdgeInsets.all(16),
// //       ),
// //     );
// //   }

// //   void _showSuccessSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
// //             const SizedBox(width: 12),
// //             Expanded(child: Text(message)),
// //           ],
// //         ),
// //         backgroundColor: const Color(0xFF38A169),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         margin: const EdgeInsets.all(16),
// //       ),
// //     );
// //   }

// //   void _showDeleteConfirmation(Map<String, dynamic> customer) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //         title: Row(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(8),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFE53E3E).withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Icon(Icons.warning_amber_rounded, 
// //                 color: Color(0xFFE53E3E), size: 24),
// //             ),
// //             const SizedBox(width: 12),
// //             const Text('Delete Customer', 
// //               style: TextStyle(fontWeight: FontWeight.w600)),
// //           ],
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('Are you sure you want to delete "${customer['name']}"?'),
// //             const SizedBox(height: 8),
// //             const Text(
// //               'This action cannot be undone.',
// //               style: TextStyle(color: Colors.grey, fontSize: 12),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             style: TextButton.styleFrom(
// //               foregroundColor: Colors.grey[600],
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //             ),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               Navigator.pop(context);
// //               await _deleteCustomer(customer);
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: const Color(0xFFE53E3E),
// //               foregroundColor: Colors.white,
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //             ),
// //             child: const Text('Delete'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
// //     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

// //     final success = await provider.deleteCustomer(
// //       userId: userId.toString(),
// //       customerId: customer['_id'] ?? '',
// //     );

// //     if (mounted) {
// //       if (success) {
// //         _showSuccessSnackBar('Customer deleted successfully');
// //       } else {
// //         _showErrorSnackBar('Failed to delete customer');
// //       }
// //     }
// //   }

// //   List<Map<String, dynamic>> _getFilteredCustomers(List<Map<String, dynamic>> customers) {
// //     if (_searchQuery.isEmpty) return customers;
// //     return customers.where((customer) {
// //       final name = customer['name']?.toString().toLowerCase() ?? '';
// //       final email = customer['email']?.toString().toLowerCase() ?? '';
// //       final mobile = customer['mobile']?.toString().toLowerCase() ?? '';
// //       final query = _searchQuery.toLowerCase();
// //       return name.contains(query) || email.contains(query) || mobile.contains(query);
// //     }).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8FAFC),
// //       appBar: PreferredSize(
// //         preferredSize: const Size.fromHeight(120),
// //         child: Container(
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //             ),
// //           ),
// //           child: SafeArea(
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
// //                   child: Row(
// //                     children: [
// //                       // Container(
// //                       //   padding: const EdgeInsets.all(8),
// //                       //   decoration: BoxDecoration(
// //                       //     color: Colors.white.withOpacity(0.2),
// //                       //     borderRadius: BorderRadius.circular(12),
// //                       //   ),
// //                       //   // child: const Icon(Icons.people, color: Colors.white, size: 24),
// //                       // ),
// //                       const SizedBox(width: 12),
// //                       const Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             // AppText(
// //                             //   'customer_management',
// //                             //   style: TextStyle(
// //                             //     color: Colors.white,
// //                             //     fontSize: 20,
// //                             //     fontWeight: FontWeight.bold,
// //                             //   ),
// //                             // ),
// //                             SizedBox(height: 2),
// //                             Text(
// //                               'Add Your Customer',
// //                               textAlign: TextAlign.center,
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 19,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       // IconButton(
// //                       //   onPressed: () {
// //                       //     setState(() {
// //                       //       _isSearching = !_isSearching;
// //                       //       if (!_isSearching) {
// //                       //         _searchController.clear();
// //                       //         _searchQuery = '';
// //                       //       }
// //                       //     });
// //                       //   },
// //                       //   icon: Icon(
// //                       //     _isSearching ? Icons.close : Icons.search,
// //                       //     color: Colors.white,
// //                       //   ),
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (_isSearching)
// //                   Container(
// //                     margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(15),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.1),
// //                           blurRadius: 8,
// //                           offset: const Offset(0, 2),
// //                         ),
// //                       ],
// //                     ),
// //                     child: TextField(
// //                       controller: _searchController,
// //                       onChanged: (value) {
// //                         setState(() {
// //                           _searchQuery = value;
// //                         });
// //                       },
// //                       decoration: InputDecoration(
// //                         hintText: 'Search customers...',
// //                         prefixIcon: const Icon(Icons.search, color: Colors.grey),
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(15),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         filled: true,
// //                         fillColor: Colors.white,
// //                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //       body: Consumer<CreateCustomerProvider>(
// //         builder: (context, customerProvider, child) {
// //           if (_isLoading) {
// //             return const Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CircularProgressIndicator(
// //                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
// //                     strokeWidth: 3,
// //                   ),
// //                   SizedBox(height: 16),
// //                   Text(
// //                     'Loading customers...',
// //                     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           }

// //           final filteredCustomers = _getFilteredCustomers(customerProvider.customers);

// //           return Column(
// //             children: [
// //               // Stats Card
// //               if (customerProvider.customers.isNotEmpty)
// //                 FadeTransition(
// //                   opacity: _fadeAnimation,
// //                   child: Container(
// //                     margin: const EdgeInsets.all(16),
// //                     padding: const EdgeInsets.all(20),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(16),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 10,
// //                           offset: const Offset(0, 5),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             color: const Color(0xFF6366F1).withOpacity(0.1),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: const Icon(
// //                             Icons.group,
// //                             color: Color(0xFF6366F1),
// //                             size: 24,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 16),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 '${customerProvider.customers.length} Total Customers',
// //                                 style: const TextStyle(
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF1F2937),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 _searchQuery.isNotEmpty 
// //                                     ? '${filteredCustomers.length} matching search'
// //                                     : 'Manage and organize your customer base',
// //                                 style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontSize: 14,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),

// //               // Customer List or Empty State
// //               filteredCustomers.isEmpty
// //                   ? Expanded(
// //                       child: FadeTransition(
// //                         opacity: _fadeAnimation,
// //                         child: Center(
// //                           child: Column(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Container(
// //                                 padding: const EdgeInsets.all(24),
// //                                 decoration: BoxDecoration(
// //                                   color: const Color(0xFF6366F1).withOpacity(0.1),
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                                 child: const Icon(
// //                                   Icons.people_outline,
// //                                   size: 64,
// //                                   color: Color(0xFF6366F1),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 24),
// //                               const AppText(
// //                                 'no_customers_found',
// //                                 style: TextStyle(
// //                                   fontSize: 20,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: Color(0xFF374151),
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 8),
// //                               Text(
// //                                 _searchQuery.isNotEmpty
// //                                     ? 'No customers match your search'
// //                                     : 'Start building your customer database',
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                               ),
// //                               if (_searchQuery.isNotEmpty)
// //                                 Padding(
// //                                   padding: const EdgeInsets.only(top: 16),
// //                                   child: TextButton.icon(
// //                                     onPressed: () {
// //                                       setState(() {
// //                                         _searchController.clear();
// //                                         _searchQuery = '';
// //                                       });
// //                                     },
// //                                     icon: const Icon(Icons.clear),
// //                                     label: const Text('Clear Search'),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     )
// //                   : Expanded(
// //                       child: RefreshIndicator(
// //                         onRefresh: _refreshData,
// //                         color: const Color(0xFF6366F1),
// //                         child: ListView.builder(
// //                           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                           itemCount: filteredCustomers.length,
// //                           itemBuilder: (context, index) {
// //                             final customer = filteredCustomers[index];
// //                             return FadeTransition(
// //                               opacity: _fadeAnimation,
// //                               child: Container(
// //                                 margin: const EdgeInsets.only(bottom: 12),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(16),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withOpacity(0.05),
// //                                       blurRadius: 8,
// //                                       offset: const Offset(0, 2),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: ListTile(
// //                                   contentPadding: const EdgeInsets.all(16),
// //                                   leading: Container(
// //                                     width: 56,
// //                                     height: 56,
// //                                     decoration: BoxDecoration(
// //                                       gradient: const LinearGradient(
// //                                         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                                       ),
// //                                       borderRadius: BorderRadius.circular(16),
// //                                     ),
// //                                     child: Center(
// //                                       child: Text(
// //                                         (customer['name'] ?? 'U')[0].toUpperCase(),
// //                                         style: const TextStyle(
// //                                           color: Colors.white,
// //                                           fontSize: 20,
// //                                           fontWeight: FontWeight.bold,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   title: Text(
// //                                     customer['name'] ?? 'Unknown',
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.w600,
// //                                       fontSize: 16,
// //                                       color: Color(0xFF1F2937),
// //                                     ),
// //                                   ),
// //                                   subtitle: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       const SizedBox(height: 8),
// //                                       Row(
// //                                         children: [
// //                                           const Icon(Icons.email_outlined, 
// //                                             size: 16, color: Colors.grey),
// //                                           const SizedBox(width: 6),
// //                                           Expanded(
// //                                             child: Text(
// //                                               customer['email'] ?? 'Not provided',
// //                                               style: TextStyle(
// //                                                 color: Colors.grey[600],
// //                                                 fontSize: 14,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                       const SizedBox(height: 4),
// //                                       Row(
// //                                         children: [
// //                                           const Icon(Icons.phone_outlined, 
// //                                             size: 16, color: Colors.grey),
// //                                           const SizedBox(width: 6),
// //                                           Text(
// //                                             customer['mobile'] ?? 'Not provided',
// //                                             style: TextStyle(
// //                                               color: Colors.grey[600],
// //                                               fontSize: 14,
// //                                             ),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   trailing: Row(
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     children: [
// //                                       Container(
// //                                         decoration: BoxDecoration(
// //                                           color: const Color(0xFF059669).withOpacity(0.1),
// //                                           borderRadius: BorderRadius.circular(10),
// //                                         ),
// //                                         child: IconButton(
// //                                           icon: const Icon(Icons.edit_outlined,
// //                                               size: 20, color: Color(0xFF059669)),
// //                                           onPressed: () async {
// //                                             // final result = await Navigator.push(
// //                                             //   context,
// //                                             //   MaterialPageRoute(
// //                                             //     builder: (context) =>
// //                                             //         EditCustomerScreen(customer: customer),
// //                                             //   ),
// //                                             // );
// //                                             // if (result == true) {
// //                                             //   _refreshData();
// //                                             // }
// //                                           },
// //                                         ),
// //                                       ),
// //                                       const SizedBox(width: 8),
// //                                       Container(
// //                                         decoration: BoxDecoration(
// //                                           color: const Color(0xFFE53E3E).withOpacity(0.1),
// //                                           borderRadius: BorderRadius.circular(10),
// //                                         ),
// //                                         child: IconButton(
// //                                           icon: const Icon(Icons.delete_outline,
// //                                               size: 20, color: Color(0xFFE53E3E)),
// //                                           onPressed: () => _showDeleteConfirmation(customer),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   isThreeLine: true,
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     ),

// //               // Add Customer Button
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: const BoxDecoration(
// //                   color: Colors.white,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black12,
// //                       blurRadius: 10,
// //                       offset: Offset(0, -5),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Consumer<MyPlanProvider>(
// //                   builder: (context, myPlanProvider, _) {
// //                     return Container(
// //                       decoration: BoxDecoration(
// //                         gradient: const LinearGradient(
// //                           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                         ),
// //                         borderRadius: BorderRadius.circular(16),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: const Color(0xFF6366F1).withOpacity(0.3),
// //                             blurRadius: 12,
// //                             offset: const Offset(0, 6),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Material(
// //                         color: Colors.transparent,
// //                         child: InkWell(
// //                           borderRadius: BorderRadius.circular(16),
// //                           onTap: () {
// //                             // if (myPlanProvider.isPurchase == true) {
// //                             //   Navigator.push(
// //                             //     context,
// //                             //     MaterialPageRoute(
// //                             //       builder: (context) => const AddCustomers(),
// //                             //     ),
// //                             //   ).then((_) {
// //                             //     _refreshData();
// //                             //   });
// //                             // } else {
// //                             //   _showPremiumModal();
// //                             // }
// //                           },
// //                           child: Container(
// //                             padding: const EdgeInsets.symmetric(vertical: 18),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Container(
// //                                   padding: const EdgeInsets.all(6),
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white.withOpacity(0.2),
// //                                     borderRadius: BorderRadius.circular(8),
// //                                   ),
// //                                   child: const Icon(
// //                                     Icons.add,
// //                                     color: Colors.white,
// //                                     size: 20,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 12),
// //                                 const AppText(
// //                                   'add_new_customer',
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   void _showPremiumModal() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (context) => Dialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //         child: Container(
// //           padding: const EdgeInsets.all(24),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
// //                   ),
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: const Icon(Icons.workspace_premium, 
// //                   color: Colors.white, size: 32),
// //               ),
// //               const SizedBox(height: 20),
// //               const Text(
// //                 'Premium Customer Management',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF1F2937),
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 12),
// //               const Text(
// //                 'Add and manage unlimited customers with contact details, purchase history, and advanced organization tools.',
// //                 style: TextStyle(
// //                   color: Colors.grey,
// //                   fontSize: 14,
// //                   height: 1.5,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 24),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: TextButton(
// //                       onPressed: () => Navigator.pop(context),
// //                       child: const Text('Maybe Later'),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         showSubscriptionModal(context);
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF6366F1),
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       child: const Text('Upgrade Now'),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void showSubscriptionModal(BuildContext context) async {
// //     final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

// //     if (myPlanProvider.isPurchase == true) {
// //       return;
// //     }
// //     final planProvider = Provider.of<GetAllPlanProvider>(context, listen: false);
// //     if (planProvider.plans.isEmpty && !planProvider.isLoading) {
// //       planProvider.fetchAllPlans();
// //     }

// //     showGeneralDialog(
// //       context: context,
// //       barrierDismissible: true,
// //       barrierLabel: 'Subscription Modal',
// //       barrierColor: Colors.black.withOpacity(0.6),
// //       transitionDuration: const Duration(milliseconds: 600),
// //       pageBuilder: (context, animation, secondaryAnimation) {
// //         return const SizedBox.shrink();
// //       },
// //       transitionBuilder: (context, animation, secondaryAnimation, child) {
// //         final curvedAnimation = CurvedAnimation(
// //           parent: animation,
// //           curve: Curves.easeOutBack,
// //         );

// //         return BackdropFilter(
// //           filter: ImageFilter.blur(
// //             sigmaX: 4 * animation.value,
// //             sigmaY: 4 * animation.value,
// //           ),
// //           child: SlideTransition(
// //             position: Tween<Offset>(
// //               begin: const Offset(0, 0.2),
// //               end: Offset.zero,
// //             ).animate(curvedAnimation),
// //             child: ScaleTransition(
// //               scale: Tween<double>(
// //                 begin: 0.8,
// //                 end: 1.0,
// //               ).animate(curvedAnimation),
// //               child: FadeTransition(
// //                 opacity: Tween<double>(
// //                   begin: 0.0,
// //                   end: 1.0,
// //                 ).animate(curvedAnimation),
// //                 child: Center(
// //                   child: Container(
// //                     margin: const EdgeInsets.symmetric(horizontal: 16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(20),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.2),
// //                           blurRadius: 20,
// //                           offset: const Offset(0, 10),
// //                         ),
// //                       ],
// //                     ),
// //                     constraints: BoxConstraints(
// //                       maxHeight: MediaQuery.of(context).size.height * 0.85,
// //                       maxWidth: 500,
// //                     ),
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(20),
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Container(
// //                             decoration: const BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: const EdgeInsets.symmetric(
// //                                 vertical: 16.0,
// //                                 horizontal: 20.0,
// //                               ),
// //                               child: Row(
// //                                 children: [
// //                                   const Icon(
// //                                     Icons.workspace_premium,
// //                                     color: Colors.white,
// //                                     size: 28,
// //                                   ),
// //                                   const SizedBox(width: 12),
// //                                   const Expanded(
// //                                     child: AppText(
// //                                       'choose_plan',
// //                                       style: TextStyle(
// //                                         fontSize: 22,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Colors.white,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   Material(
// //                                     color: Colors.transparent,
// //                                     child: InkWell(
// //                                       borderRadius: BorderRadius.circular(30),
// //                                       onTap: () => Navigator.pop(context),
// //                                       child: Container(
// //                                         padding: const EdgeInsets.all(8),
// //                                         decoration: BoxDecoration(
// //                                           color: Colors.white.withOpacity(0.2),
// //                                           shape: BoxShape.circle,
// //                                         ),
// //                                         child: const Icon(
// //                                           Icons.close,
// //                                           color: Colors.white,
// //                                           size: 20,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           Flexible(
// //                             child: Consumer<GetAllPlanProvider>(
// //                               builder: (context, provider, child) {
// //                                 if (provider.isLoading) {
// //                                   return Center(
// //                                     child: Column(
// //                                       mainAxisAlignment: MainAxisAlignment.center,
// //                                       children: [
// //                                         const SizedBox(
// //                                           width: 40,
// //                                           height: 40,
// //                                           child: CircularProgressIndicator(
// //                                             valueColor: AlwaysStoppedAnimation<Color>(
// //                                               Color(0xFF6366F1),
// //                                             ),
// //                                             strokeWidth: 3,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(height: 16),
// //                                         Text(
// //                                           'Loading plans...',
// //                                           style: TextStyle(
// //                                             color: Colors.grey.shade600,
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   );
// //                                 }

// //                                 if (provider.error != null) {
// //                                   return Center(
// //                                     child: Padding(
// //                                       padding: const EdgeInsets.all(20.0),
// //                                       child: Column(
// //                                         mainAxisAlignment: MainAxisAlignment.center,
// //                                         children: [
// //                                           Container(
// //                                             padding: const EdgeInsets.all(16),
// //                                             decoration: BoxDecoration(
// //                                               color: const Color(0xFFE53E3E).withOpacity(0.1),
// //                                               borderRadius: BorderRadius.circular(16),
// //                                             ),
// //                                             child: const Icon(
// //                                               Icons.error_outline,
// //                                               color: Color(0xFFE53E3E),
// //                                               size: 48,
// //                                             ),
// //                                           ),
// //                                           const SizedBox(height: 16),
// //                                           const Text(
// //                                             'Failed to load plans',
// //                                             style: TextStyle(
// //                                               fontSize: 18,
// //                                               fontWeight: FontWeight.bold,
// //                                               color: Color(0xFF1F2937),
// //                                             ),
// //                                           ),
// //                                           const SizedBox(height: 8),
// //                                           Text(
// //                                             'Please check your connection and try again',
// //                                             style: TextStyle(
// //                                               color: Colors.grey.shade600,
// //                                             ),
// //                                             textAlign: TextAlign.center,
// //                                           ),
// //                                           const SizedBox(height: 20),
// //                                           ElevatedButton.icon(
// //                                             onPressed: () => provider.fetchAllPlans(),
// //                                             style: ElevatedButton.styleFrom(
// //                                               backgroundColor: const Color(0xFF6366F1),
// //                                               foregroundColor: Colors.white,
// //                                               padding: const EdgeInsets.symmetric(
// //                                                 horizontal: 24,
// //                                                 vertical: 12,
// //                                               ),
// //                                               shape: RoundedRectangleBorder(
// //                                                 borderRadius: BorderRadius.circular(12),
// //                                               ),
// //                                             ),
// //                                             icon: const Icon(Icons.refresh),
// //                                             label: const Text('Retry'),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   );
// //                                 }

// //                                 if (provider.plans.isNotEmpty) {
// //                                   return AnimatedPlanList(
// //                                     plans: provider.plans,
// //                                     onPlanSelected: (plan) {
// //                                       Navigator.of(context).pop();
// //                                       Navigator.push(
// //                                         context,
// //                                         PageRouteBuilder(
// //                                           pageBuilder: (context, animation, secondaryAnimation) =>
// //                                               PlanDetailsAndPaymentScreen(plan: plan),
// //                                           transitionsBuilder: (context, animation, 
// //                                               secondaryAnimation, child) {
// //                                             const begin = Offset(1.0, 0.0);
// //                                             const end = Offset.zero;
// //                                             const curve = Curves.easeOutCubic;

// //                                             var tween = Tween(begin: begin, end: end)
// //                                                 .chain(CurveTween(curve: curve));
// //                                             var offsetAnimation = animation.drive(tween);

// //                                             return SlideTransition(
// //                                               position: offsetAnimation,
// //                                               child: FadeTransition(
// //                                                 opacity: animation,
// //                                                 child: child,
// //                                               ),
// //                                             );
// //                                           },
// //                                           transitionDuration: const Duration(milliseconds: 500),
// //                                         ),
// //                                       );
// //                                     },
// //                                   );
// //                                 }

// //                                 return Center(
// //                                   child: Column(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     children: [
// //                                       Container(
// //                                         padding: const EdgeInsets.all(16),
// //                                         decoration: BoxDecoration(
// //                                           color: Colors.grey.withOpacity(0.1),
// //                                           borderRadius: BorderRadius.circular(16),
// //                                         ),
// //                                         child: const Icon(
// //                                           Icons.subscriptions_outlined,
// //                                           size: 48,
// //                                           color: Colors.grey,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(height: 16),
// //                                       Text(
// //                                         'No subscription plans available',
// //                                         style: TextStyle(
// //                                           fontSize: 16,
// //                                           color: Colors.grey.shade600,
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                         textAlign: TextAlign.center,
// //                                       ),
// //                                       const SizedBox(height: 8),
// //                                       Text(
// //                                         'Please contact support for assistance',
// //                                         style: TextStyle(
// //                                           fontSize: 14,
// //                                           color: Colors.grey.shade500,
// //                                         ),
// //                                         textAlign: TextAlign.center,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }























// import 'dart:ui';

// import 'package:edit_ezy_project/helper/storage_helper.dart';
// import 'package:edit_ezy_project/providers/customer/customer_provider.dart';
// import 'package:edit_ezy_project/providers/language/language_provider.dart';
// import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
// import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
// import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
// import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CustomerScreen extends StatefulWidget {
//   const CustomerScreen({super.key});

//   @override
//   State<CustomerScreen> createState() => _AddCustomersState();
// }

// class _AddCustomersState extends State<CustomerScreen> with TickerProviderStateMixin {
//   String? userId;
//   bool _isLoading = true;
//   bool _isSearching = false;
//   String _searchQuery = '';
//   TextEditingController _searchController = TextEditingController();
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final userData = await AuthPreferences.getUserData();
//     print(userData);
//     if (userData != null && userData.user != null) {
//       setState(() {
//         userId = userData.user.id;
//       });
//       await _loadData();
//       _animationController.forward();
//       print('User ID: $userId');
//     } else {
//       print("No User ID");
//     }
//   }

//   Future<void> _loadData() async {
//     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await provider.fetchUser(userId.toString());
//     } catch (e) {
//       print('Error fetching customers: $e');
//       if (mounted) {
//         _showErrorSnackBar('Failed to load customers: $e');
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshData() async {
//     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);
//     await provider.fetchUser(userId.toString());
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE53E3E),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF38A169),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(Map<String, dynamic> customer) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE53E3E).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.warning_amber_rounded, 
//                 color: Color(0xFFE53E3E), size: 24),
//             ),
//             const SizedBox(width: 12),
//             const Text('Delete Customer', 
//               style: TextStyle(fontWeight: FontWeight.w600)),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Are you sure you want to delete "${customer['name']}"?'),
//             const SizedBox(height: 8),
//             const Text(
//               'This action cannot be undone.',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.grey[600],
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _deleteCustomer(customer);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53E3E),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
//     final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

//     final success = await provider.deleteCustomer(
//       userId: userId.toString(),
//       customerId: customer['_id'] ?? '',
//     );

//     if (mounted) {
//       if (success) {
//         _showSuccessSnackBar('Customer deleted successfully');
//       } else {
//         _showErrorSnackBar('Failed to delete customer');
//       }
//     }
//   }

//   List<Map<String, dynamic>> _getFilteredCustomers(List<Map<String, dynamic>> customers) {
//     if (_searchQuery.isEmpty) return customers;
//     return customers.where((customer) {
//       final name = customer['name']?.toString().toLowerCase() ?? '';
//       final email = customer['email']?.toString().toLowerCase() ?? '';
//       final mobile = customer['mobile']?.toString().toLowerCase() ?? '';
//       final query = _searchQuery.toLowerCase();
//       return name.contains(query) || email.contains(query) || mobile.contains(query);
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(120),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(Icons.people, color: Colors.white, size: 24),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AppText(
//                               'customer_management',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 2),
//                             Text(
//                               'Manage your customer database',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _isSearching = !_isSearching;
//                             if (!_isSearching) {
//                               _searchController.clear();
//                               _searchQuery = '';
//                             }
//                           });
//                         },
//                         icon: Icon(
//                           _isSearching ? Icons.close : Icons.search,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_isSearching)
//                   Container(
//                     margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {
//                           _searchQuery = value;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Search customers...',
//                         prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Consumer<CreateCustomerProvider>(
//         builder: (context, customerProvider, child) {
//           if (_isLoading) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
//                     strokeWidth: 3,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Loading customers...',
//                     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final filteredCustomers = _getFilteredCustomers(customerProvider.customers);

//           return Column(
//             children: [
//               // Stats Card
//               if (customerProvider.customers.isNotEmpty)
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: Container(
//                     margin: const EdgeInsets.all(16),
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.group,
//                             color: Color(0xFF6366F1),
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '${customerProvider.customers.length} Total Customers',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF1F2937),
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _searchQuery.isNotEmpty 
//                                     ? '${filteredCustomers.length} matching search'
//                                     : 'Manage and organize your customer base',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               // Customer List or Empty State
//               filteredCustomers.isEmpty
//                   ? Expanded(
//                       child: FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF6366F1).withOpacity(0.1),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.people_outline,
//                                   size: 64,
//                                   color: Color(0xFF6366F1),
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               const AppText(
//                                 'no_customers_found',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF374151),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 _searchQuery.isNotEmpty
//                                     ? 'No customers match your search'
//                                     : 'Start building your customer database',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               if (_searchQuery.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 16),
//                                   child: TextButton.icon(
//                                     onPressed: () {
//                                       setState(() {
//                                         _searchController.clear();
//                                         _searchQuery = '';
//                                       });
//                                     },
//                                     icon: const Icon(Icons.clear),
//                                     label: const Text('Clear Search'),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                   : Expanded(
//                       child: RefreshIndicator(
//                         onRefresh: _refreshData,
//                         color: const Color(0xFF6366F1),
//                         child: ListView.builder(
//                           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                           itemCount: filteredCustomers.length,
//                           itemBuilder: (context, index) {
//                             final customer = filteredCustomers[index];
//                             return FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.05),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: ListTile(
//                                   contentPadding: const EdgeInsets.all(16),
//                                   leading: Container(
//                                     width: 56,
//                                     height: 56,
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                                       ),
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         (customer['name'] ?? 'U')[0].toUpperCase(),
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   title: Text(
//                                     customer['name'] ?? 'Unknown',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16,
//                                       color: Color(0xFF1F2937),
//                                     ),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const SizedBox(height: 8),
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.email_outlined, 
//                                             size: 16, color: Colors.grey),
//                                           const SizedBox(width: 6),
//                                           Expanded(
//                                             child: Text(
//                                               customer['email'] ?? 'Not provided',
//                                               style: TextStyle(
//                                                 color: Colors.grey[600],
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.phone_outlined, 
//                                             size: 16, color: Colors.grey),
//                                           const SizedBox(width: 6),
//                                           Text(
//                                             customer['mobile'] ?? 'Not provided',
//                                             style: TextStyle(
//                                               color: Colors.grey[600],
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFF059669).withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                         child: IconButton(
//                                           icon: const Icon(Icons.edit_outlined,
//                                               size: 20, color: Color(0xFF059669)),
//                                           onPressed: () async {
//                                             // final result = await Navigator.push(
//                                             //   context,
//                                             //   MaterialPageRoute(
//                                             //     builder: (context) =>
//                                             //         EditCustomerScreen(customer: customer),
//                                             //   ),
//                                             // );
//                                             // if (result == true) {
//                                             //   _refreshData();
//                                             // }
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFFE53E3E).withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(10),
//                                         ),
//                                         child: IconButton(
//                                           icon: const Icon(Icons.delete_outline,
//                                               size: 20, color: Color(0xFFE53E3E)),
//                                           onPressed: () => _showDeleteConfirmation(customer),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   isThreeLine: true,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),

//               // Add Customer Button
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 10,
//                       offset: Offset(0, -5),
//                     ),
//                   ],
//                 ),
//                 child: Consumer<MyPlanProvider>(
//                   builder: (context, myPlanProvider, _) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF6366F1).withOpacity(0.3),
//                             blurRadius: 12,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(16),
//                           onTap: () {
//                             // if (myPlanProvider.isPurchase == true) {
//                             //   Navigator.push(
//                             //     context,
//                             //     MaterialPageRoute(
//                             //       builder: (context) => const AddCustomers(),
//                             //     ),
//                             //   ).then((_) {
//                             //     _refreshData();
//                             //   });
//                             // } else {
//                             //   _showPremiumModal();
//                             // }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 18),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: const Icon(
//                                     Icons.add,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 const AppText(
//                                   'add_new_customer',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _showPremiumModal() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Icon(Icons.workspace_premium, 
//                   color: Colors.white, size: 32),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Premium Customer Management',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Add and manage unlimited customers with contact details, purchase history, and advanced organization tools.',
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Maybe Later'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         showSubscriptionModal(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF6366F1),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Upgrade Now'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void showSubscriptionModal(BuildContext context) async {
//     final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

//     if (myPlanProvider.isPurchase == true) {
//       return;
//     }
//     final planProvider = Provider.of<GetAllPlanProvider>(context, listen: false);
//     if (planProvider.plans.isEmpty && !planProvider.isLoading) {
//       planProvider.fetchAllPlans();
//     }

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Subscription Modal',
//       barrierColor: Colors.black.withOpacity(0.6),
//       transitionDuration: const Duration(milliseconds: 600),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         final curvedAnimation = CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutBack,
//         );

//         return BackdropFilter(
//           filter: ImageFilter.blur(
//             sigmaX: 4 * animation.value,
//             sigmaY: 4 * animation.value,
//           ),
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.2),
//               end: Offset.zero,
//             ).animate(curvedAnimation),
//             child: ScaleTransition(
//               scale: Tween<double>(
//                 begin: 0.8,
//                 end: 1.0,
//               ).animate(curvedAnimation),
//               child: FadeTransition(
//                 opacity: Tween<double>(
//                   begin: 0.0,
//                   end: 1.0,
//                 ).animate(curvedAnimation),
//                 child: Center(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     constraints: BoxConstraints(
//                       maxHeight: MediaQuery.of(context).size.height * 0.85,
//                       maxWidth: 500,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             decoration: const BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 16.0,
//                                 horizontal: 20.0,
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.workspace_premium,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                   const SizedBox(width: 12),
//                                   const Expanded(
//                                     child: AppText(
//                                       'choose_plan',
//                                       style: TextStyle(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       borderRadius: BorderRadius.circular(30),
//                                       onTap: () => Navigator.pop(context),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.2),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.close,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Flexible(
//                             child: Consumer<GetAllPlanProvider>(
//                               builder: (context, provider, child) {
//                                 if (provider.isLoading) {
//                                   return Center(
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         const SizedBox(
//                                           width: 40,
//                                           height: 40,
//                                           child: CircularProgressIndicator(
//                                             valueColor: AlwaysStoppedAnimation<Color>(
//                                               Color(0xFF6366F1),
//                                             ),
//                                             strokeWidth: 3,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         Text(
//                                           'Loading plans...',
//                                           style: TextStyle(
//                                             color: Colors.grey.shade600,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }

//                                 if (provider.error != null) {
//                                   return Center(
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(20.0),
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.all(16),
//                                             decoration: BoxDecoration(
//                                               color: const Color(0xFFE53E3E).withOpacity(0.1),
//                                               borderRadius: BorderRadius.circular(16),
//                                             ),
//                                             child: const Icon(
//                                               Icons.error_outline,
//                                               color: Color(0xFFE53E3E),
//                                               size: 48,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 16),
//                                           const Text(
//                                             'Failed to load plans',
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                               color: Color(0xFF1F2937),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             'Please check your connection and try again',
//                                             style: TextStyle(
//                                               color: Colors.grey.shade600,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           const SizedBox(height: 20),
//                                           ElevatedButton.icon(
//                                             onPressed: () => provider.fetchAllPlans(),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: const Color(0xFF6366F1),
//                                               foregroundColor: Colors.white,
//                                               padding: const EdgeInsets.symmetric(
//                                                 horizontal: 24,
//                                                 vertical: 12,
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                             icon: const Icon(Icons.refresh),
//                                             label: const Text('Retry'),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }

//                                 if (provider.plans.isNotEmpty) {
//                                   return AnimatedPlanList(
//                                     plans: provider.plans,
//                                     onPlanSelected: (plan) {
//                                       Navigator.of(context).pop();
//                                       Navigator.push(
//                                         context,
//                                         PageRouteBuilder(
//                                           pageBuilder: (context, animation, secondaryAnimation) =>
//                                               PlanDetailsAndPaymentScreen(plan: plan),
//                                           transitionsBuilder: (context, animation, 
//                                               secondaryAnimation, child) {
//                                             const begin = Offset(1.0, 0.0);
//                                             const end = Offset.zero;
//                                             const curve = Curves.easeOutCubic;

//                                             var tween = Tween(begin: begin, end: end)
//                                                 .chain(CurveTween(curve: curve));
//                                             var offsetAnimation = animation.drive(tween);

//                                             return SlideTransition(
//                                               position: offsetAnimation,
//                                               child: FadeTransition(
//                                                 opacity: animation,
//                                                 child: child,
//                                               ),
//                                             );
//                                           },
//                                           transitionDuration: const Duration(milliseconds: 500),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 }

//                                 return Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey.withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: const Icon(
//                                           Icons.subscriptions_outlined,
//                                           size: 48,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         'No subscription plans available',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.grey.shade600,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Please contact support for assistance',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade500,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }































import 'dart:ui';

import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:edit_ezy_project/providers/customer/customer_provider.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
import 'package:edit_ezy_project/providers/plans/my_plan_provider.dart';
import 'package:edit_ezy_project/views/customer/add_customer.dart';
import 'package:edit_ezy_project/views/customer/edit_customer.dart';
import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _AddCustomersState();
}

class _AddCustomersState extends State<CustomerScreen> with TickerProviderStateMixin {
  String? userId;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthPreferences.getUserData();
    print(userData);
    if (userData != null && userData.user != null) {
      setState(() {
        userId = userData.user.id;
      });
      await _loadData();
      _animationController.forward();
      print('User ID: $userId');
    } else {
      print("No User ID");
    }
  }

  Future<void> _loadData() async {
    final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      await provider.fetchUser(userId.toString());
    } catch (e) {
      print('Error fetching customers: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to load customers: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<CreateCustomerProvider>(context, listen: false);
    await provider.fetchUser(userId.toString());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF38A169),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, 
                color: Color(0xFFE53E3E), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Customer', 
              style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${customer['name']}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCustomer(customer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final provider = Provider.of<CreateCustomerProvider>(context, listen: false);

    final success = await provider.deleteCustomer(
      userId: userId.toString(),
      customerId: customer['_id'] ?? '',
    );

    if (mounted) {
      if (success) {
        _showSuccessSnackBar('Customer deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete customer');
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredCustomers(List<Map<String, dynamic>> customers) {
    if (_searchQuery.isEmpty) return customers;
    return customers.where((customer) {
      final name = customer['name']?.toString().toLowerCase() ?? '';
      final email = customer['email']?.toString().toLowerCase() ?? '';
      final mobile = customer['mobile']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query) || mobile.contains(query);
    }).toList();
  }

  void _handleAddCustomer() {
    final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);
    if (myPlanProvider.isPurchase == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddCustomer(),
        ),
      ).then((_) {
        _refreshData();
      });
    } else {
      _showPremiumModal();
    }
    
    // For now, just show the premium modal as a placeholder
    // _showPremiumModal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Add Your Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // SizedBox(height: 2),
                            // Text(
                            //   'Manage your customer database',
                            //   style: TextStyle(
                            //     color: Colors.white70,
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      // Add Customer Button
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _handleAddCustomer,
                          icon: const Icon(Icons.add, color: Colors.white, size: 24),
                          tooltip: 'Add New Customer',
                        ),
                      ),
                      // Search Button
                      // IconButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       _isSearching = !_isSearching;
                      //       if (!_isSearching) {
                      //         _searchController.clear();
                      //         _searchQuery = '';
                      //       }
                      //     });
                      //   },
                      //   icon: Icon(
                      //     _isSearching ? Icons.close : Icons.search,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                if (_isSearching)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search customers...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<CreateCustomerProvider>(
        builder: (context, customerProvider, child) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading customers...',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final filteredCustomers = _getFilteredCustomers(customerProvider.customers);

          return Column(
            children: [
              // Stats Card
              if (customerProvider.customers.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${customerProvider.customers.length} Total Customers',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _searchQuery.isNotEmpty 
                                    ? '${filteredCustomers.length} matching search'
                                    : 'Manage and organize your customer base',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Customer List or Empty State
              Expanded(
                child: filteredCustomers.isEmpty
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const AppText(
                                'no_customers_found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No customers match your search'
                                    : 'Start building your customer database',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear Search'),
                                  ),
                                ),
                              const SizedBox(height: 32),
                              // Add Customer CTA Button in Empty State
                              ElevatedButton.icon(
                                onPressed: _handleAddCustomer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                icon: const Icon(Icons.add),
                                label: const AppText(
                                  'add_new_customer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: const Color(0xFF6366F1),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Added bottom padding for navigation bar
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (customer['name'] ?? 'U')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    customer['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.email_outlined, 
                                            size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              customer['email'] ?? 'Not provided',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_outlined, 
                                            size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(
                                            customer['mobile'] ?? 'Not provided',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF059669).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 20, color: Color(0xFF059669)),
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCustomerScreen(customer: customer),
                                              ),
                                            );
                                            if (result == true) {
                                              _refreshData();
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53E3E).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 20, color: Color(0xFFE53E3E)),
                                          onPressed: () => _showDeleteConfirmation(customer),
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPremiumModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.workspace_premium, 
                  color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Premium Customer Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Add and manage unlimited customers with contact details, purchase history, and advanced organization tools.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showSubscriptionModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Upgrade Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSubscriptionModal(BuildContext context) async {
    final myPlanProvider = Provider.of<MyPlanProvider>(context, listen: false);

    if (myPlanProvider.isPurchase == true) {
      return;
    }
    final planProvider = Provider.of<GetAllPlanProvider>(context, listen: false);
    if (planProvider.plans.isEmpty && !planProvider.isLoading) {
      planProvider.fetchAllPlans();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription Modal',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4 * animation.value,
            sigmaY: 4 * animation.value,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      maxWidth: 500,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 20.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: AppText(
                                      'choose_plan',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Consumer<GetAllPlanProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF6366F1),
                                            ),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading plans...',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (provider.error != null) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE53E3E).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Color(0xFFE53E3E),
                                              size: 48,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Failed to load plans',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Please check your connection and try again',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed: () => provider.fetchAllPlans(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6366F1),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (provider.plans.isNotEmpty) {
                                  return AnimatedPlanList(
                                    plans: provider.plans,
                                    onPlanSelected: (plan) {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              PlanDetailsAndPaymentScreen(plan: plan),
                                          transitionsBuilder: (context, animation, 
                                              secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;

                                            var tween = Tween(begin: begin, end: end)
                                                .chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration: const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.subscriptions_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No subscription plans available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Please contact support for assistance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}