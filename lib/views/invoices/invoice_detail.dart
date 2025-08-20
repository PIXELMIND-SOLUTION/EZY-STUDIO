// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:edit_ezy_project/models/invoice_model.dart';
// import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:ui' as ui;
// import 'package:shared_preferences/shared_preferences.dart';

// class InvoiceDetailScreen extends StatefulWidget {
//   final Invoice invoice;

//   const InvoiceDetailScreen({
//     super.key,
//     required this.invoice,
//   });

//   @override
//   State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
// }

// class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
//   final GlobalKey _printableKey = GlobalKey();
//   bool _isGeneratingPdf = false;
//   bool _isLoading = true;
//   String? _logoImageBase64;

//   // Variables to store user data
//   String businessName = 'Design Studio';
//   String mobile = '(123) 456-7890';
//   String email = 'designstudio@email.com';
//   String bankAccount = '1234-5678-9012-3456';
//   String gst = 'Not Available';
//   String wastage = 'Wastage';
//   String offerprice = 'offerprice';
//   String description = 'description';
//   String hsn = 'hsn';

//   // Client data
//   String name = 'Narasimhavarma';
//   String clientAddress = '123 Elm Street Green Valley';
//   String clientPhone = '';
//   String clientEmail = 'varma@email.com';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadSubscriptions();
//     _loadLogoImage();
//   }

//   Future<void> _loadLogoImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final logoBase64 = prefs.getString('logo_image');

//     if (logoBase64 != null && logoBase64.isNotEmpty) {
//       setState(() {
//         _logoImageBase64 = logoBase64;
//       });
//     }
//   }

//   Future<void> _loadSubscriptions() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final userId = authProvider.user?.user.id;
//       // await Provider.of<SubscriptionProvider>(context, listen: false)
//       //     .fetchSubscriptions(userId.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       businessName = prefs.getString('businessName') ?? 'Design Studio';
//       clientPhone = prefs.getString('user_mobile') ?? '12345678';
//       clientEmail = prefs.getString('email') ?? 'designstudio@email.com';
//       gst = prefs.getString('gst') ?? 'Not Available';
//       name = prefs.getString('user_name') ?? 'Melvin';
//       clientAddress = prefs.getString('user_address') ?? "No address added";
//       offerprice = prefs.getString('Offer Price') ?? 'No offerprice';
//       description = prefs.getString('Description') ?? 'No description';
//       wastage = prefs.getString('Wastage') ?? 'No wastage';
//       hsn = prefs.getString('HSN') ?? 'No hsn number';
//     });
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('MMM dd, yyyy').format(date);
//   }

//   String _generateInvoiceNumber(String id) {
//     return "INV-${DateTime.now().year}-${id.substring(0, 6).toUpperCase()}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final invoice = widget.invoice;
//     final golditem = invoice.products[0].isGoldItem;
//     final dueDate = invoice.createdAt.add(const Duration(days: 20));
    
//     final totalAmount = invoice.products.fold<double>(0, (total, product) {
//       final wastageAmount = product.offerPrice * (product.wastage / 100);
//       final productTotal = (product.offerPrice + wastageAmount) * product.quantity;
//       return total + productTotal;
//     });

//     double gstRate = 0.0;
//     if (gst != 'Not Available') {
//       String gstValue = gst.replaceAll('%', '').trim();
//       try {
//         gstRate = double.parse(gstValue) / 100;
//       } catch (e) {
//         debugPrint('Error parsing GST rate: $e');
//       }
//     }

//     final tax = totalAmount * gstRate;
//     final totalWithTax = totalAmount + tax;

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text(
//           'Invoice Details',
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.grey.shade800,
//         actions: [
//           if (_isGeneratingPdf)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             )
//           else
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: _sharePdf,
//                   icon: const Icon(Icons.share_outlined),
//                   tooltip: 'Share Invoice',
//                 ),
//                 IconButton(
//                   onPressed: _downloadPdf,
//                   icon: const Icon(Icons.download_outlined),
//                   tooltip: 'Download Invoice',
//                 ),
//                 const SizedBox(width: 8),
//               ],
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // White container for the invoice
//             Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade300,
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: RepaintBoundary(
//                 key: _printableKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Section
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.blue.shade600, Colors.blue.shade700],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               // Business Info
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       businessName,
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Phone: $mobile',
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Email: $email',
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                     if (gst != 'Not Available')
//                                       Text(
//                                         'GST: $gst',
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white70,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
                              
//                               // Logo
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black26,
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 padding: const EdgeInsets.all(12),
//                                 height: 80,
//                                 width: 80,
//                                 child: _logoImageBase64 != null && _logoImageBase64!.isNotEmpty
//                                     ? ClipRRect(
//                                         borderRadius: BorderRadius.circular(4),
//                                         child: Image.memory(
//                                           base64Decode(_logoImageBase64!),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       )
//                                     : Icon(
//                                         Icons.business,
//                                         size: 40,
//                                         color: Colors.blue.shade600,
//                                       ),
//                               ),
//                             ],
//                           ),
                          
//                           const SizedBox(height: 24),
                          
//                           // Invoice Title and Number
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'INVOICE',
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   letterSpacing: 2,
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     _generateInvoiceNumber(invoice.id),
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     _formatDate(invoice.createdAt),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Bill To Section
//                     Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade50,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: Colors.grey.shade200),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.person_outline,
//                                             size: 20,
//                                             color: Colors.blue.shade600,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             'BILL TO',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.blue.shade600,
//                                               letterSpacing: 1,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Text(
//                                         name,
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         clientAddress,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade600,
//                                           height: 1.4,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       if (clientPhone.isNotEmpty)
//                                         Row(
//                                           children: [
//                                             Icon(
//                                               Icons.phone_outlined,
//                                               size: 16,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                             const SizedBox(width: 6),
//                                             Text(
//                                               clientPhone,
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey.shade600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.email_outlined,
//                                             size: 16,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                           const SizedBox(width: 6),
//                                           Text(
//                                             clientEmail,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
                              
//                               const SizedBox(width: 16),
                              
//                               // Invoice Info
//                               Container(
//                                 width: 200,
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.grey.shade200),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.receipt_long_outlined,
//                                           size: 20,
//                                           color: Colors.blue.shade600,
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           'INVOICE INFO',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blue.shade600,
//                                             letterSpacing: 1,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildInfoRow('Invoice #', _generateInvoiceNumber(invoice.id)),
//                                     const SizedBox(height: 8),
//                                     _buildInfoRow('Date', _formatDate(invoice.createdAt)),
//                                     const SizedBox(height: 8),
//                                     _buildInfoRow('Due Date', _formatDate(dueDate)),
//                                     const SizedBox(height: 8),
//                                     _buildInfoRow('Status', 'Generated', isStatus: true),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 32),

//                           // Products Section
//                           Text(
//                             'ITEMS & SERVICES',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey.shade800,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Modern Table
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 // Table Header
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(8),
//                                       topRight: Radius.circular(8),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const SizedBox(
//                                         width: 40,
//                                         child: Text(
//                                           '#',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                       ),
//                                       const Expanded(
//                                         flex: 3,
//                                         child: Text(
//                                           'PRODUCT',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                       ),
//                                       const Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'QTY',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                             color: Colors.black87,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       const Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'PRICE',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                             color: Colors.black87,
//                                           ),
//                                           textAlign: TextAlign.right,
//                                         ),
//                                       ),
//                                       if (golditem)
//                                         const Expanded(
//                                           flex: 2,
//                                           child: Text(
//                                             'WASTAGE',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 12,
//                                               color: Colors.black87,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       const Expanded(
//                                         flex: 2,
//                                         child: Text(
//                                           'TOTAL',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                             color: Colors.black87,
//                                           ),
//                                           textAlign: TextAlign.right,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 // Product Rows
//                                 ...List.generate(invoice.products.length, (index) {
//                                   final product = invoice.products[index];
//                                   final wastageAmount = product.offerPrice * (product.wastage / 100);
//                                   final lineTotal = (product.offerPrice + wastageAmount) * product.quantity;

//                                   return Container(
//                                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                     decoration: BoxDecoration(
//                                       border: Border(
//                                         bottom: BorderSide(
//                                           color: Colors.grey.shade200,
//                                           width: 1,
//                                         ),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: 40,
//                                           child: Text(
//                                             '${index + 1}',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey.shade600,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 3,
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 product.productName,
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               if (product.description.isNotEmpty)
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(top: 4),
//                                                   child: Text(
//                                                     product.description,
//                                                     style: TextStyle(
//                                                       fontSize: 12,
//                                                       color: Colors.grey.shade600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               if (product.hsn != null)
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(top: 4),
//                                                   child: Text(
//                                                     'HSN: ${product.hsn}',
//                                                     style: TextStyle(
//                                                       fontSize: 11,
//                                                       color: Colors.grey.shade500,
//                                                       fontStyle: FontStyle.italic,
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: Text(
//                                             '${product.quantity}${product.unit.isNotEmpty ? ' ${product.unit}' : ''}',
//                                             style: const TextStyle(fontSize: 14),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: Text(
//                                             '₹${product.offerPrice.toStringAsFixed(2)}',
//                                             style: const TextStyle(fontSize: 14),
//                                             textAlign: TextAlign.right,
//                                           ),
//                                         ),
//                                         if (golditem)
//                                           Expanded(
//                                             flex: 2,
//                                             child: Text(
//                                               '${product.wastage ?? 0}%',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.orange.shade600,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                               textAlign: TextAlign.center,
//                                             ),
//                                           ),
//                                         Expanded(
//                                           flex: 2,
//                                           child: Text(
//                                             '₹${lineTotal.toStringAsFixed(2)}',
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                             textAlign: TextAlign.right,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }),
//                               ],
//                             ),
//                           ),

//                           const SizedBox(height: 32),

//                           // Summary Section
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Terms Section
//                               Expanded(
//                                 flex: 3,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade50,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: Colors.grey.shade200),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.info_outline,
//                                             size: 18,
//                                             color: Colors.blue.shade600,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             'TERMS & CONDITIONS',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.blue.shade600,
//                                               letterSpacing: 0.5,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       _buildTermItem('Payment due within 30 days of invoice date'),
//                                       _buildTermItem('Late payments subject to 1.5% monthly fee'),
//                                       _buildTermItem('All prices are in Indian Rupees (INR)'),
//                                       _buildTermItem('Goods once sold cannot be returned'),
//                                     ],
//                                   ),
//                                 ),
//                               ),
                              
//                               const SizedBox(width: 24),
                              
//                               // Summary Section
//                               Container(
//                                 width: 280,
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.grey.shade300),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     _buildSummaryRow('Subtotal', '₹${totalAmount.toStringAsFixed(2)}'),
//                                     const SizedBox(height: 12),
//                                     _buildSummaryRow(
//                                       'Tax (${gst != 'Not Available' ? gst : '0%'})',
//                                       '₹${tax.toStringAsFixed(2)}',
//                                     ),
//                                     const SizedBox(height: 16),
//                                     const Divider(thickness: 2),
//                                     const SizedBox(height: 16),
//                                     _buildSummaryRow(
//                                       'TOTAL AMOUNT',
//                                       '₹${totalWithTax.toStringAsFixed(2)}',
//                                       isTotal: true,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 32),

//                           // Footer Section
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.check_circle_outline,
//                                       color: Colors.green.shade600,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Thank you for your business!',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.green.shade600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   'For any questions regarding this invoice, please contact us at $email or $mobile',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
      
//       // Action Buttons
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade300,
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: _sharePdf,
//                   icon: const Icon(Icons.share_outlined),
//                   label: const Text(
//                     'Share Invoice',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.blue.shade600,
//                     side: BorderSide(color: Colors.blue.shade600),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Container(
//           padding: isStatus ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2) : null,
//           decoration: isStatus
//               ? BoxDecoration(
//                   color: Colors.green.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 )
//               : null,
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: isStatus ? Colors.green.shade700 : Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//             color: isTotal ? Colors.black87 : Colors.grey.shade700,
//           ),
//         ),
//         Text(
//           amount,
//           style: TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
//             color: isTotal ? Colors.blue.shade600 : Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTermItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 6),
//             width: 4,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade600,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade700,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // IMPROVED PDF GENERATION METHOD
//   Future<Uint8List> _generatePdf() async {
//     setState(() {
//       _isGeneratingPdf = true;
//     });

//     try {
//       final invoice = widget.invoice;
//       final invoiceId = _generateInvoiceNumber(invoice.id);
//       final dueDate = invoice.createdAt.add(const Duration(days: 20));
//       final golditem = invoice.products[0].isGoldItem;

//       // Calculate total amount with wastage
//       final totalAmount = invoice.products.fold<double>(0, (total, product) {
//         final wastageAmount = product.offerPrice * (product.wastage / 100);
//         final productTotal = (product.offerPrice + wastageAmount) * product.quantity;
//         return total + productTotal;
//       });

//       double gstRate = 0.0;
//       if (gst != 'Not Available') {
//         String gstValue = gst.replaceAll('%', '').trim();
//         try {
//           gstRate = double.parse(gstValue) / 100;
//         } catch (e) {
//           debugPrint('Error parsing GST rate: $e');
//         }
//       }

//       final tax = totalAmount * gstRate;
//       final totalWithTax = totalAmount + tax;

//       final pdf = pw.Document();

//       // Logo widget for PDF
//       pw.Widget logoWidget;
//       if (_logoImageBase64 != null && _logoImageBase64!.isNotEmpty) {
//         try {
//           final logoImageData = base64Decode(_logoImageBase64!);
//           final logoImage = pw.MemoryImage(logoImageData);
//           logoWidget = pw.Container(
//             decoration: pw.BoxDecoration(
//               color: PdfColors.white,
//               borderRadius: pw.BorderRadius.circular(8),
//             ),
//             padding: const pw.EdgeInsets.all(12),
//             height: 80,
//             width: 80,
//             child: pw.ClipRRect(
//               horizontalRadius: 4,
//               verticalRadius: 4,
//               child: pw.Image(logoImage, fit: pw.BoxFit.cover),
//             ),
//           );
//         } catch (e) {
//           logoWidget = pw.Container(
//             decoration: pw.BoxDecoration(
//               color: PdfColors.white,
//               borderRadius: pw.BorderRadius.circular(8),
//             ),
//             padding: const pw.EdgeInsets.all(12),
//             height: 80,
//             width: 80,
//             child: pw.Center(
//               child: pw.Icon(
//                 pw.IconData(0xe0af), // business icon
//                 size: 40,
//                 color: PdfColor.fromHex('1976D2'),
//               ),
//             ),
//           );
//         }
//       } else {
//         logoWidget = pw.Container(
//           decoration: pw.BoxDecoration(
//             color: PdfColors.white,
//             borderRadius: pw.BorderRadius.circular(8),
//           ),
//           padding: const pw.EdgeInsets.all(12),
//           height: 80,
//           width: 80,
//           child: pw.Center(
//             child: pw.Icon(
//               pw.IconData(0xe0af), // business icon
//               size: 40,
//               color: PdfColor.fromHex('1976D2'),
//             ),
//           ),
//         );
//       }

//       pdf.addPage(
//         pw.MultiPage(
//           pageTheme: pw.PageTheme(
//             margin: const pw.EdgeInsets.all(40),
//             theme: pw.ThemeData.withFont(
//               base: pw.Font.helvetica(),
//               bold: pw.Font.helveticaBold(),
//             ),
//           ),
//           build: (pw.Context context) => [
//             // Header Section with Gradient Effect (simulated with color)
//             pw.Container(
//               padding: const pw.EdgeInsets.all(24),
//               decoration: pw.BoxDecoration(
//                 gradient: pw.LinearGradient(
//                   colors: [
//                     PdfColor.fromHex('1976D2'),
//                     PdfColor.fromHex('1565C0'),
//                   ],
//                 ),
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 children: [
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Business Info
//                       pw.Expanded(
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               businessName,
//                               style: pw.TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.white,
//                               ),
//                             ),
//                             pw.SizedBox(height: 8),
//                             pw.Text(
//                               'Phone: $mobile',
//                               style: pw.TextStyle(
//                                 fontSize: 14,
//                                 color: PdfColor.fromHex('E3F2FD'),
//                               ),
//                             ),
//                             pw.Text(
//                               'Email: $email',
//                               style: pw.TextStyle(
//                                 fontSize: 14,
//                                 color: PdfColor.fromHex('E3F2FD'),
//                               ),
//                             ),
//                             if (gst != 'Not Available')
//                               pw.Text(
//                                 'GST: $gst',
//                                 style: pw.TextStyle(
//                                   fontSize: 14,
//                                   color: PdfColor.fromHex('E3F2FD'),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       logoWidget,
//                     ],
//                   ),
//                   pw.SizedBox(height: 24),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         'INVOICE',
//                         style: pw.TextStyle(
//                           fontSize: 28,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.white,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text(
//                             invoiceId,
//                             style: pw.TextStyle(
//                               fontSize: 18,
//                               fontWeight: pw.FontWeight.bold,
//                               color: PdfColors.white,
//                             ),
//                           ),
//                           pw.Text(
//                             _formatDate(invoice.createdAt),
//                             style: pw.TextStyle(
//                               fontSize: 14,
//                               color: PdfColor.fromHex('E3F2FD'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 24),

//             // Bill To and Invoice Info Section
//             pw.Row(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Expanded(
//                   child: pw.Container(
//                     padding: const pw.EdgeInsets.all(16),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromHex('F5F5F5'),
//                       borderRadius: pw.BorderRadius.circular(8),
//                       border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'BILL TO',
//                           style: pw.TextStyle(
//                             fontSize: 12,
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColor.fromHex('1976D2'),
//                             letterSpacing: 1,
//                           ),
//                         ),
//                         pw.SizedBox(height: 12),
//                         pw.Text(
//                           name,
//                           style: pw.TextStyle(
//                             fontSize: 16,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 8),
//                         pw.Text(
//                           clientAddress,
//                           style: pw.TextStyle(
//                             fontSize: 14,
//                             color: PdfColor.fromHex('616161'),
//                           ),
//                         ),
//                         pw.SizedBox(height: 8),
//                         if (clientPhone.isNotEmpty)
//                           pw.Text(
//                             'Phone: $clientPhone',
//                             style: pw.TextStyle(
//                               fontSize: 14,
//                               color: PdfColor.fromHex('616161'),
//                             ),
//                           ),
//                         pw.Text(
//                           'Email: $clientEmail',
//                           style: pw.TextStyle(
//                             fontSize: 14,
//                             color: PdfColor.fromHex('616161'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(width: 16),
//                 pw.Container(
//                   width: 200,
//                   padding: const pw.EdgeInsets.all(16),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.white,
//                     borderRadius: pw.BorderRadius.circular(8),
//                     border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'INVOICE INFO',
//                         style: pw.TextStyle(
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColor.fromHex('1976D2'),
//                           letterSpacing: 1,
//                         ),
//                       ),
//                       pw.SizedBox(height: 16),
//                       _buildPdfInfoRow('Invoice #', invoiceId),
//                       pw.SizedBox(height: 8),
//                       _buildPdfInfoRow('Date', _formatDate(invoice.createdAt)),
//                       pw.SizedBox(height: 8),
//                       _buildPdfInfoRow('Due Date', _formatDate(dueDate)),
//                       pw.SizedBox(height: 8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text(
//                             'Status',
//                             style: pw.TextStyle(
//                               fontSize: 12,
//                               color: PdfColor.fromHex('616161'),
//                               fontWeight: pw.FontWeight.normal,
//                             ),
//                           ),
//                           pw.Container(
//                             padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: pw.BoxDecoration(
//                               color: PdfColor.fromHex('E8F5E8'),
//                               borderRadius: pw.BorderRadius.circular(12),
//                             ),
//                             child: pw.Text(
//                               'Generated',
//                               style: pw.TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColor.fromHex('2E7D32'),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             pw.SizedBox(height: 32),

//             // Items Section
//             pw.Text(
//               'ITEMS & SERVICES',
//               style: pw.TextStyle(
//                 fontSize: 16,
//                 fontWeight: pw.FontWeight.bold,
//                 color: PdfColor.fromHex('424242'),
//                 letterSpacing: 1,
//               ),
//             ),
//             pw.SizedBox(height: 16),

//             // Products Table
//             pw.Container(
//               decoration: pw.BoxDecoration(
//                 borderRadius: pw.BorderRadius.circular(8),
//                 border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
//               ),
//               child: pw.Column(
//                 children: [
//                   // Table Header
//                   pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromHex('F5F5F5'),
//                       borderRadius: const pw.BorderRadius.only(
//                         topLeft: pw.Radius.circular(8),
//                         topRight: pw.Radius.circular(8),
//                       ),
//                     ),
//                     child: pw.Row(
//                       children: [
//                         pw.SizedBox(
//                           width: 40,
//                           child: pw.Text(
//                             '#',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 3,
//                           child: pw.Text(
//                             'PRODUCT',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Text(
//                             'QTY',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                             textAlign: pw.TextAlign.center,
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Text(
//                             'PRICE',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                             textAlign: pw.TextAlign.right,
//                           ),
//                         ),
//                         if (golditem)
//                           pw.Expanded(
//                             flex: 2,
//                             child: pw.Text(
//                               'WASTAGE',
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                               textAlign: pw.TextAlign.center,
//                             ),
//                           ),
//                         pw.Expanded(
//                           flex: 2,
//                           child: pw.Text(
//                             'TOTAL',
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                             textAlign: pw.TextAlign.right,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Product Rows
//                   ...List.generate(invoice.products.length, (index) {
//                     final product = invoice.products[index];
//                     final wastageAmount = product.offerPrice * (product.wastage / 100);
//                     final lineTotal = (product.offerPrice + wastageAmount) * product.quantity;

//                     return pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border(
//                           bottom: pw.BorderSide(
//                             color: PdfColor.fromHex('E0E0E0'),
//                             width: 1,
//                           ),
//                         ),
//                       ),
//                       child: pw.Row(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.SizedBox(
//                             width: 40,
//                             child: pw.Text(
//                               '${index + 1}',
//                               style: pw.TextStyle(
//                                 fontSize: 14,
//                                 color: PdfColor.fromHex('616161'),
//                                 fontWeight: pw.FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                           pw.Expanded(
//                             flex: 3,
//                             child: pw.Column(
//                               crossAxisAlignment: pw.CrossAxisAlignment.start,
//                               children: [
//                                 pw.Text(
//                                   product.productName,
//                                   style: pw.TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: pw.FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (product.description.isNotEmpty)
//                                   pw.Padding(
//                                     padding: const pw.EdgeInsets.only(top: 4),
//                                     child: pw.Text(
//                                       product.description,
//                                       style: pw.TextStyle(
//                                         fontSize: 12,
//                                         color: PdfColor.fromHex('616161'),
//                                       ),
//                                     ),
//                                   ),
//                                 if (product.hsn != null )
//                                   pw.Padding(
//                                     padding: const pw.EdgeInsets.only(top: 4),
//                                     child: pw.Text(
//                                       'HSN: ${product.hsn}',
//                                       style: pw.TextStyle(
//                                         fontSize: 11,
//                                         color: PdfColor.fromHex('9E9E9E'),
//                                         fontStyle: pw.FontStyle.italic,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                           pw.Expanded(
//                             flex: 2,
//                             child: pw.Text(
//                               '${product.quantity}${product.unit.isNotEmpty ? ' ${product.unit}' : ''}',
//                               style: const pw.TextStyle(fontSize: 14),
//                               textAlign: pw.TextAlign.center,
//                             ),
//                           ),
//                           pw.Expanded(
//                             flex: 2,
//                             child: pw.Text(
//                               '₹${product.offerPrice.toStringAsFixed(2)}',
//                               style: const pw.TextStyle(fontSize: 14),
//                               textAlign: pw.TextAlign.right,
//                             ),
//                           ),
//                           if (golditem)
//                             pw.Expanded(
//                               flex: 2,
//                               child: pw.Text(
//                                 '${product.wastage ?? 0}%',
//                                 style: pw.TextStyle(
//                                   fontSize: 14,
//                                   color: PdfColor.fromHex('FF9800'),
//                                   fontWeight: pw.FontWeight.bold,
//                                 ),
//                                 textAlign: pw.TextAlign.center,
//                               ),
//                             ),
//                           pw.Expanded(
//                             flex: 2,
//                             child: pw.Text(
//                               '₹${lineTotal.toStringAsFixed(2)}',
//                               style: pw.TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                               textAlign: pw.TextAlign.right,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 32),

//             // Summary and Terms Section
//             pw.Row(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Terms Section
//                 pw.Expanded(
//                   flex: 3,
//                   child: pw.Container(
//                     padding: const pw.EdgeInsets.all(16),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColor.fromHex('F5F5F5'),
//                       borderRadius: pw.BorderRadius.circular(8),
//                       border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'TERMS & CONDITIONS',
//                           style: pw.TextStyle(
//                             fontSize: 12,
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColor.fromHex('1976D2'),
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         pw.SizedBox(height: 12),
//                         _buildPdfTermItem('Payment due within 30 days of invoice date'),
//                         _buildPdfTermItem('Late payments subject to 1.5% monthly fee'),
//                         _buildPdfTermItem('All prices are in Indian Rupees (INR)'),
//                         _buildPdfTermItem('Goods once sold cannot be returned'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 pw.SizedBox(width: 24),
//                 // Summary Section
//                 pw.Container(
//                   width: 280,
//                   padding: const pw.EdgeInsets.all(20),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.white,
//                     borderRadius: pw.BorderRadius.circular(8),
//                     border: pw.Border.all(color: PdfColor.fromHex('BDBDBD')),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       _buildPdfSummaryRow('Subtotal', '₹${totalAmount.toStringAsFixed(2)}'),
//                       pw.SizedBox(height: 12),
//                       _buildPdfSummaryRow(
//                         'Tax (${gst != 'Not Available' ? gst : '0%'})',
//                         '₹${tax.toStringAsFixed(2)}',
//                       ),
//                       pw.SizedBox(height: 16),
//                       pw.Divider(thickness: 2),
//                       pw.SizedBox(height: 16),
//                       _buildPdfSummaryRow(
//                         'TOTAL AMOUNT',
//                         '₹${totalWithTax.toStringAsFixed(2)}',
//                         isTotal: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             pw.SizedBox(height: 32),

//             // Footer Section
//             pw.Container(
//               padding: const pw.EdgeInsets.all(20),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor.fromHex('F5F5F5'),
//                 borderRadius: pw.BorderRadius.circular(8),
//                 border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
//               ),
//               child: pw.Column(
//                 children: [
//                   pw.Text(
//                     'Thank you for your business!',
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColor.fromHex('2E7D32'),
//                     ),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                   pw.SizedBox(height: 12),
//                   pw.Text(
//                     'For any questions regarding this invoice, please contact us at $email or $mobile',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       color: PdfColor.fromHex('616161'),
//                     ),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//       return await pdf.save();
//     } catch (e) {
//       debugPrint('Error generating PDF: $e');
//       rethrow;
//     } finally {
//       setState(() {
//         _isGeneratingPdf = false;
//       });
//     }
//   }

//   pw.Widget _buildPdfInfoRow(String label, String value) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 12,
//             color: PdfColor.fromHex('616161'),
//             fontWeight: pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 12,
//             fontWeight: pw.FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildPdfSummaryRow(String label, String amount, {bool isTotal = false}) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
//             color: isTotal ? PdfColors.black : PdfColor.fromHex('424242'),
//           ),
//         ),
//         pw.Text(
//           amount,
//           style: pw.TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.bold,
//             color: isTotal ? PdfColor.fromHex('1976D2') : PdfColors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildPdfTermItem(String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.only(bottom: 6),
//       child: pw.Row(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Container(
//             margin: const pw.EdgeInsets.only(top: 6),
//             width: 4,
//             height: 4,
//             decoration: pw.BoxDecoration(
//               color: PdfColor.fromHex('1976D2'),
//               shape: pw.BoxShape.circle,
//             ),
//           ),
//           pw.SizedBox(width: 8),
//           pw.Expanded(
//             child: pw.Text(
//               text,
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 color: PdfColor.fromHex('424242'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final pdfBytes = await _generatePdf();
//       final tempDir = await getTemporaryDirectory();
//       final invoice = widget.invoice;
//       final invoiceFileName = 'Invoice_${_generateInvoiceNumber(invoice.id)}.pdf';
//       final file = File('${tempDir.path}/$invoiceFileName');
//       await file.writeAsBytes(pdfBytes);

//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'Please find attached invoice ${_generateInvoiceNumber(invoice.id)}',
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error sharing PDF: $e'),
//           backgroundColor: Colors.red.shade600,
//         ),
//       );
//     }
//   }

//   Future<void> _downloadPdf() async {
//     try {
//       final pdfBytes = await _generatePdf();
//       final directory = await getApplicationDocumentsDirectory();
//       final invoice = widget.invoice;
//       final invoiceFileName = 'Invoice_${_generateInvoiceNumber(invoice.id)}.pdf';
//       final file = File('${directory.path}/$invoiceFileName');
//       await file.writeAsBytes(pdfBytes);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invoice saved successfully'),
//           backgroundColor: Colors.green.shade600,
//           action: SnackBarAction(
//             label: 'View',
//             textColor: Colors.white,
//             onPressed: () {
//               // Open file functionality
//             },
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error downloading PDF: $e'),
//           backgroundColor: Colors.red.shade600,
//         ),
//       );
//     }
//   }
// }






import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:edit_ezy_project/models/invoice_model.dart';
import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final GlobalKey _printableKey = GlobalKey();
  bool _isGeneratingPdf = false;
  bool _isLoading = true;
  String? _logoImageBase64;

  // Variables to store user data
  String businessName = 'Design Studio';
  String mobile = '(123) 456-7890';
  String email = 'designstudio@email.com';
  String bankAccount = '1234-5678-9012-3456';
  // String bankName = 'Bank Transfer';
  String gst = 'Not Available';
  String wastage = 'Wastage';
  String offerprice = 'offerprice';
  String description = 'description';
  String hsn = 'hsn';

  // Client data - in a real app this would be part of the invoice model
  String name = 'Narasimhavarma';

  String clientAddress = '123 Elm Street Green Valley';
  String clientPhone = '';
  String clientEmail = 'varma@email.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSubscriptions();
    _loadLogoImage();
  }

  Future<void> _loadLogoImage() async {
    final prefs = await SharedPreferences.getInstance();
    final logoBase64 = prefs.getString('logo_image');

    if (logoBase64 != null && logoBase64.isNotEmpty) {
      setState(() {
        _logoImageBase64 = logoBase64;
      });
    }
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.user.id;
 
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      businessName = prefs.getString('businessName') ?? 'Design Studio';
      clientPhone = prefs.getString('user_mobile') ?? '12345678';
      clientEmail = prefs.getString('email') ?? 'designstudio@email.com';
      // bankAccount = prefs.getString('bankAccount') ?? '1234-5678-9012-3456';
      // bankName = prefs.getString('bankName') ?? 'Bank Transfer';
      gst = prefs.getString('gst') ?? 'Not Available';
      name = prefs.getString('user_name') ?? 'Melvin';
      clientAddress = prefs.getString('user_address') ?? "No address added";
      offerprice = prefs.getString('Offer Price') ?? 'No offerprice';
      description = prefs.getString('Description') ?? 'No description';
      wastage = prefs.getString('Wastage') ?? 'No wastage';
      hsn = prefs.getString('HSN') ?? 'No hsn number';
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _generateInvoiceNumber(String id) {
    return "SI${DateTime.now().year}${id.substring(0, 3)}";
  }

  @override
  Widget build(BuildContext context) {
    
    final invoice = widget.invoice;
    final golditem=invoice.products[0].isGoldItem;
    final dueDate = invoice.createdAt.add(const Duration(days: 20));
    final totalAmount = invoice.products.fold<double>(0, (total, product) {
       final wastageAmount = product.offerPrice * (product.wastage / 100);
      
      final productTotal = (product.offerPrice + wastageAmount)*product.quantity;
      
     
      
      return  productTotal;
    });



    double gstRate = 0.0;
    if (gst != 'Not Available') {
      // Try to parse the GST value (handle formats like "18%" or "18")
      String gstValue = gst.replaceAll('%', '').trim();
      try {
        gstRate = double.parse(gstValue) / 100; // Convert percentage to decimal
      } catch (e) {
        debugPrint('Error parsing GST rate: $e');
        // Keep default 0.0 if parsing fails
      }
    }

    final tax = totalAmount * gstRate;

    final totalWithTax = totalAmount + tax;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice',
          // 'Invoice ${_generateInvoiceNumber(invoice.id)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // actions: [
        //   if (_isGeneratingPdf)
        //     const Center(
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(horizontal: 16.0),
        //         child: SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         ),
        //       ),
        //     )
        //   else
        //     Row(
        //       children: [
        //         IconButton(
        //           onPressed: _sharePdf,
        //           icon: const Icon(Icons.share),
        //           tooltip: 'Share Invoice',
        //         ),
        //         IconButton(
        //           onPressed: _downloadPdf,
        //           icon: const Icon(Icons.download),
        //           tooltip: 'Download Invoice',
        //         ),
        //       ],
        //     ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _printableKey,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your existing invoice UI code here
                  // ... (all the UI elements)

                  // Top teal accent
                  Container(
                    height: 15,
                    color: const Color(0xFF4ACBBC),
                  ),

                  // Navy header
                  Container(
                    color: const Color(0xFF0E2945),
                    width: double.infinity,
                    height: 8,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with logo and invoice title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Invoice title
                            const Text(
                              'INVOICE BILL',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.5,
                              ),
                            ),

                            // Logo
                            Container(
                              decoration: BoxDecoration(
                                // color: const Color(0xFFFFC84D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(10),
                              height: 80,
                              width: 80,
                              child: _logoImageBase64 != null &&
                                      _logoImageBase64!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.memory(
                                        base64Decode(_logoImageBase64!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'd',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bill To Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bill To:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Client Name: $name',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  // Text(
                                  //   'Company Name: $clientCompany',
                                  //   style: const TextStyle(fontSize: 14),
                                  // ),
                                  Text(
                                    'Billing Address: $clientAddress',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Phone: $clientPhone',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Email: $clientEmail',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),

                            // Invoice Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(width: 1,),
                                      const Text(
                                        'Invoice Number: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _generateInvoiceNumber(invoice.id),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                       SizedBox(width: 1,),
                                      const Text(
                                        'Invoice Date: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(invoice.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Service Details
                        const Text(
                          'Service Details:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Table header with gold background
                        // Header section
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC84D),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child:  Row(
                            children: [
                              // No.
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              // Product
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              // Description
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              // Quantity
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(width: 5),
                              // Offer Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Offer Price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              // Wastage
                              if(golditem)
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Wastage',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              // HSN
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'HSN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),

// Product list section
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: invoice.products.length,
                          itemBuilder: (context, index) {
                            final product = invoice.products[index];
                            final isEven = index % 2 == 0;

                            return Container(
                              color:
                                  isEven ? Colors.grey.shade200 : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // No.
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  // Product Name
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      product.productName,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  // Description
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '${product.description}',
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Quantity with unit
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${product.quantity}${product.unit.isNotEmpty ? ' ${product.unit}' : ''}',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ),
                                  // Price
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  // Offer Price
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${product.offerPrice.toStringAsFixed(2) ?? "-"}',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if(golditem)
                                  // Wastage
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${product.wastage ?? 0}%',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                    ),
                                  ),
                                  // HSN
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${product.hsn ?? 0}',
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Terms and Conditions and Summary
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary section first
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Subtotal',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '${totalAmount.toStringAsFixed(2)}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'GST',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            'Tax (${gst != 'Not Available' ? gst : '0%'})',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Grand Total:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${totalWithTax.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Add some space between sections
                            const SizedBox(height: 24),

                            // Terms and Conditions below
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Terms and Conditions:',
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                // SizedBox(height: 8),
                                // Text(
                                //   '• Payment is due upon receipt of this invoice.',
                                //   style: TextStyle(fontSize: 14),
                                // ),
                                // Text(
                                //   '• Late payments may incur additional charges.',
                                //   style: TextStyle(fontSize: 14),
                                // ),
                                // Text(
                                //   '• Please make checks payable to Your Graphic Design Studio.',
                                //   style: TextStyle(fontSize: 14),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Payment Information - Navy background
                  Container(
                    // color: const Color(0xFF0E2945),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   'Payment Information:',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Payment Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // const Text(
                                      //   'Payment Method: ',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                      // Text(
                                      //   bankName,
                                      //   style: const TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // const Text(
                                      //   'Due Date: ',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                      // Text(
                                      //   _formatDate(dueDate),
                                      //   style: const TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // const Text(
                                      //   'Bank Account: ',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                      // Text(
                                      //   bankAccount,
                                      //   style: const TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Signature
                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.end,
                            //     children: [
                            //       const Text(
                            //         'Date: ',
                            //         style: TextStyle(
                            //           fontSize: 14,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //       Text(
                            //         _formatDate(invoice.createdAt),
                            //         style: const TextStyle(
                            //           fontSize: 14,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //       const SizedBox(height: 20),
                            //       const Text(
                            //         '- Signature -',
                            //         style: TextStyle(
                            //           fontSize: 14,
                            //           fontStyle: FontStyle.italic,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //       const SizedBox(height: 4),
                            //       const Text(
                            //         'John Smith',
                            //         style: TextStyle(
                            //           fontSize: 14,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Questions Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Text(
                        //   'Questions',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        // Text(
                        //   'Email US: $email',
                        //   style: const TextStyle(fontSize: 14),
                        // ),
                        // Text(
                        //   'Call US: $mobile',
                        //   style: const TextStyle(fontSize: 14),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _sharePdf,
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'Share',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 74, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 132, 83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMPROVED PDF GENERATION METHOD THAT MATCHES UI
  Future<Uint8List> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final invoice = widget.invoice;
      final invoiceId = _generateInvoiceNumber(invoice.id);
      final dueDate = invoice.createdAt.add(const Duration(days: 20));

      // Calculate total amount with wastage as done in the UI
      final totalAmount = invoice.products.fold<double>(0, (total, product) {
        final productTotal = product.offerPrice * product.quantity;
        final wastageAmount = product.offerPrice * (product.wastage / 100);
        return total + productTotal + wastageAmount;
      });

      double gstRate = 0.0;
      if (gst != 'Not Available') {
        String gstValue = gst.replaceAll('%', '').trim();
        try {
          gstRate = double.parse(gstValue) / 100;
        } catch (e) {
          debugPrint('Error parsing GST rate: $e');
        }
      }

      final tax = totalAmount * gstRate;
      final totalWithTax = totalAmount + tax;

      // Create a PDF document
      final pdf = pw.Document();

      // Try to load logo image for PDF if available
      pw.Widget logoWidget;
      if (_logoImageBase64 != null && _logoImageBase64!.isNotEmpty) {
        try {
          final logoImageData = base64Decode(_logoImageBase64!);
          final logoImage = pw.MemoryImage(logoImageData);
          logoWidget = pw.ClipRRect(
            horizontalRadius: 4,
            verticalRadius: 4,
            child: pw.Container(
              color: PdfColor.fromHex('FFC84D'),
              padding: const pw.EdgeInsets.all(10),
              height: 80,
              width: 80,
              child: pw.Image(logoImage, fit: pw.BoxFit.cover),
            ),
          );
        } catch (e) {
          // Fallback if image loading fails
          logoWidget = pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('FFC84D'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(10),
            height: 80,
            width: 80,
            child: pw.Center(
              child: pw.Text(
                'd',
                style: pw.TextStyle(
                  fontSize: 40,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          );
        }
      } else {
        // Default logo placeholder
        logoWidget = pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('FFC84D'),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(10),
          height: 80,
          width: 80,
          child: pw.Center(
            child: pw.Text(
              'd',
              style: pw.TextStyle(
                fontSize: 40,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        );
      }

      // Build the PDF document
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(40),
            theme: pw.ThemeData.withFont(
              base: pw.Font.helvetica(),
              bold: pw.Font.helveticaBold(),
            ),
          ),
          build: (pw.Context context) => [
            // Top teal accent and navy header
            pw.Container(
              height: 15,
              color: PdfColor.fromHex('4ACBBC'),
            ),
            pw.Container(
              color: PdfColor.fromHex('0E2945'),
              width: double.infinity,
              height: 8,
            ),
            pw.SizedBox(height: 16),

            // Header with logo and invoice title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 38,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                logoWidget,
              ],
            ),
            pw.SizedBox(height: 16),

            // Bill To and Invoice Details
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Client Name: $name',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Billing Address: $clientAddress',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Phone: $clientPhone',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Email: $clientEmail',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Invoice Number: ',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.Text(
                            invoiceId,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Invoice Date: ',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                          pw.Text(
                            _formatDate(invoice.createdAt),
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Service Details
            pw.Text(
              'Service Details:',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            // Table header
            pw.Container(
              decoration: pw.BoxDecoration(
                // color: PdfColor.fromHex('FFC84DD'),
                color: PdfColor.fromHex('#3344C4'),

              ),
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Sl.No',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Product',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Quantity',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Price',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Offer Price',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Wastage',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'HSN',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Product list rows
            ...List.generate(invoice.products.length, (index) {
              final product = invoice.products[index];
              final isEven = index % 2 == 0;

              return pw.Container(
                color: isEven ? PdfColor.fromHex('EEEEEE') : PdfColors.white,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Serial Number
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        '${index + 1}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ),
                    // Product Name
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        product.productName,
                        style: const pw.TextStyle(fontSize: 14),
                        maxLines: 1,
                      ),
                    ),
                    // Description
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        '${product.description}',
                        style: const pw.TextStyle(fontSize: 14),
                        maxLines: 1,
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    // Quantity with unit
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${product.quantity}${product.unit.isNotEmpty ? ' ${product.unit}' : ''}',
                        style: const pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    // Price
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${product.price.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    // Offer Price
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${product.offerPrice.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    // Wastage
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${product.wastage ?? 0}%',
                        style: const pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    // HSN
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${product.hsn ?? 0}',
                        style: const pw.TextStyle(fontSize: 14),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 20),

            // Terms and Conditions and Summary
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Terms and Conditions
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Terms and Conditions:',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '• Payment is due upon receipt of this invoice.',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        '• Late payments may incur additional charges.',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        '• Please make checks payable to Your Graphic',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        '  Design Studio.',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Summary
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Subtotal',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            '${totalAmount.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'GST',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text(
                            'Tax (${gst != 'Not Available' ? gst : '0%'})',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Grand Total:',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${totalWithTax.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Payment Information - Navy background
            pw.Container(
              // color: PdfColor.fromHex('0E2945'),
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // pw.Text(
                  //   'Payment Information:',
                  //   style: pw.TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: pw.FontWeight.bold,
                  //     color: PdfColors.white,
                  //   ),
                  // ),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    children: [
                      // Payment Details
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                          
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                               
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                              
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Signature
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 20),
                            pw.Text(
                              '- Signature -',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.black,
                              ),
                            ),
                            pw.SizedBox(height: 4),

                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Questions Section
            pw.Padding(
              padding: const pw.EdgeInsets.all(16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
         
                  pw.SizedBox(height: 8),

                ],
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      return pdfBytes;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      rethrow;
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  // Implementation of share PDF functionality
  Future<void> _sharePdf() async {
    try {
      final pdfBytes = await _generatePdf();
      final tempDir = await getTemporaryDirectory();
      final invoice = widget.invoice;
      final invoiceFileName =
          'Invoice_${_generateInvoiceNumber(invoice.id)}.pdf';
      final file = File('${tempDir.path}/$invoiceFileName');
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Please find attached invoice ${_generateInvoiceNumber(invoice.id)}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  // Implementation of download PDF functionality
  Future<void> _downloadPdf() async {
    try {
      final pdfBytes = await _generatePdf();
      final directory = await getApplicationDocumentsDirectory();
      final invoice = widget.invoice;
      final invoiceFileName =
          'Invoice_${_generateInvoiceNumber(invoice.id)}.pdf';
      final file = File('${directory.path}/$invoiceFileName');
      await file.writeAsBytes(pdfBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice saved to ${file.path}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () async {
              // Use a PDF viewer package or open with default app
              // This would require adding a package like open_file
              // await OpenFile.open(file.path);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }
}
