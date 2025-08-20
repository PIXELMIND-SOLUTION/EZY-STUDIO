import 'dart:convert';
import 'dart:io';
import 'package:edit_ezy_project/models/invoice_model.dart';
import 'package:edit_ezy_project/providers/invoices/invoice_provider.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/widgets/invoice_number.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

// Redesigned, professional AddInvoiceScreen
class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  bool _isListening = false;
  TextEditingController? _activeController;
  late stt.SpeechToText _speech;
  final _formKey = GlobalKey<FormState>();
  final List<ProductEntry> _productEntries = [ProductEntry()];
  bool _isLoading = false;
  bool _isGoldShop = false;

  // User profile data
  String _userName = '';
  String _userMobile = '';
  String _userAddress = '';

  // Logo image
  String? _logoImagePath;
  String? _logoImageBase64;
  final ImagePicker _picker = ImagePicker();

  final List<String> units = [
    'Kg',
    'Gram',
    'Milligram',
    'Liter',
    'Milliliter',
    'Piece',
    'Pack',
    'Dozen'
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();

    if (_productEntries.isNotEmpty) _productEntries.first.unit = units.first;
    _loadUserData();
    _checkBusinessType();
    _loadLogoImage();
  }

  Future<void> _checkBusinessType() async {
    final prefs = await SharedPreferences.getInstance();
    final businessType = prefs.getString('businessType') ?? '';
    if (mounted) {
      setState(() {
        _isGoldShop = businessType == 'Gold Shop';
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? '';
        _userMobile = prefs.getString('user_mobile') ?? '';
        _userAddress = prefs.getString('user_address') ?? '';

        for (var entry in _productEntries) {
          entry.nameController.text = _userName;
          entry.mobileController.text = _userMobile;
          entry.addressController.text = _userAddress;
        }
      });
    }
  }

  Future<void> _loadLogoImage() async {
    final prefs = await SharedPreferences.getInstance();
    final logoBase64 = prefs.getString('logo_image');
    if (logoBase64 != null && logoBase64.isNotEmpty && mounted) {
      setState(() => _logoImageBase64 = logoBase64);
    }
  }

  Future<void> _saveUserData() async {
    if (_productEntries.isNotEmpty) {
      final entry = _productEntries.first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', entry.nameController.text);
      await prefs.setString('user_mobile', entry.mobileController.text);
      await prefs.setString('user_address', entry.addressController.text);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logo_image', base64Image);
        if (mounted) {
          setState(() {
            _logoImagePath = image.path;
            _logoImageBase64 = base64Image;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo saved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
    if (!available) debugPrint('Speech recognition not available');
  }

  @override
  void dispose() {
    _speech.stop();
    for (var e in _productEntries) {
      e.dispose();
    }
    super.dispose();
  }

  void _startListening(TextEditingController controller) async {
    _activeController = controller;
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' && mounted) setState(() => _isListening = false);
        },
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          if (_activeController != null && mounted) {
            setState(() {
              _activeController!.text = result.recognizedWords;
              _syncUserInfoAcrossEntries();
            });
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _syncUserInfoAcrossEntries() {
    if (_productEntries.isEmpty) return;
    final first = _productEntries.first;
    final name = first.nameController.text;
    final mobile = first.mobileController.text;
    final address = first.addressController.text;
    for (int i = 1; i < _productEntries.length; i++) {
      _productEntries[i].nameController.text = name;
      _productEntries[i].mobileController.text = mobile;
      _productEntries[i].addressController.text = address;
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    for (var e in _productEntries) {
      if (e.unit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select units for all products'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await _saveUserData();
      final List<ProductItem> products = _productEntries.map((entry) {
        final invoiceNumberStr = generateInvoiceNumber().toString();
        return ProductItem(
          invoiceNumber: invoiceNumberStr,
          productName: entry.productNameController.text.trim(),
          quantity: double.tryParse(entry.quantityController.text) ?? 0.0,
          invoiceDate: DateTime.now(),
          unit: entry.unit ?? units.first,
          price: double.tryParse(entry.priceController.text) ?? 0.0,
          offerPrice: double.tryParse(entry.offerPriceController.text) ?? 0.0,
          name: _productEntries.first.nameController.text.trim(),
          mobilenumber: _productEntries.first.mobileController.text.trim(),
          address: _productEntries.first.addressController.text.trim(),
          hsn: _productEntries.first.hsnController.text.trim(),
          wastage: _isGoldShop ? double.tryParse(entry.wastageController.text) ?? 0.0 : 0.0,
          isGoldItem: _isGoldShop,
          description: entry.descriptionController.text.trim(),
          imagelogo: _logoImageBase64 ?? '',
        );
      }).toList();

      final success = await Provider.of<ProductInvoiceProvider>(context, listen: false).addInvoice(products);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Invoice created' : 'Failed to create invoice'), backgroundColor: success ? Colors.green : Colors.red),
        );
        if (success) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppText('create_invoice', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Choose Logo',
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header card with logo and summary
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
                          child: _logoImageBase64 != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(base64Decode(_logoImageBase64!), fit: BoxFit.cover),
                                )
                              : _logoImagePath != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(_logoImagePath!), fit: BoxFit.cover))
                                  : Center(child: Icon(Icons.storefront_outlined, size: 36, color: theme.primaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppText.translate(context, 'invoice_preview'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text('${AppText.translate(context, 'customer')}: $_userName', style: theme.textTheme.bodyMedium),
                              Text('${AppText.translate(context, 'mobile')}: $_userMobile', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       _productEntries.clear();
                        //       _productEntries.add(ProductEntry()..unit = units.first);
                        //     });
                        //   },
                        //   icon: const Icon(Icons.refresh_rounded),
                        //   tooltip: 'Reset form',
                        // )
                      ],
                    ),
                  ),
                ),
              ),

              // Flexible list of product cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ListView.builder(
                    itemCount: _productEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _productEntries[index];
                      return _productCard(entry, index);
                    },
                  ),
                ),
              ),

              // Bottom action bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            final newEntry = ProductEntry()..unit = units.first;
                            // Copy user info
                            if (_productEntries.isNotEmpty) {
                              final first = _productEntries.first;
                              newEntry.nameController.text = first.nameController.text;
                              newEntry.mobileController.text = first.mobileController.text;
                              newEntry.addressController.text = first.addressController.text;
                            }
                            _productEntries.add(newEntry);
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const AppText('add_more'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveInvoice,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const AppText('create', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(ProductEntry entry, int index) {
    final bool showUserInfo = index == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12, top: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${AppText.translate(context, 'item')} ${index + 1}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (_productEntries.length > 1)
                  IconButton(
                    onPressed: () {
                      setState(() => _productEntries.removeAt(index));
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  )
              ],
            ),
            const SizedBox(height: 8),

            if (showUserInfo) ...[
              _buildTextField(entry.nameController, 'customer_name', prefix: Icons.person, onChanged: (v) => _syncUserInfoAcrossEntries()),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildTextField(entry.mobileController, 'customer_mobile', prefix: Icons.smartphone, inputType: TextInputType.phone, onChanged: (v) => _syncUserInfoAcrossEntries())),
                const SizedBox(width: 8),
                // IconButton(onPressed: () => _startListening(entry.mobileController), icon: Icon(_isListening && _activeController == entry.mobileController ? Icons.mic : Icons.mic_none))
              ]),
              const SizedBox(height: 10),
              _buildTextField(entry.addressController, 'customer_address', prefix: Icons.location_on, maxLines: 2, onChanged: (v) => _syncUserInfoAcrossEntries()),
              const Divider(height: 18),
            ],

            _buildTextField(entry.productNameController, 'product_name', prefix: Icons.shopping_bag),
            const SizedBox(height: 10),

            Row(children: [
              Expanded(child: _buildTextField(entry.quantityController, 'quantity', inputType: TextInputType.number)),
              const SizedBox(width: 10),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: entry.unit,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => entry.unit = v),
                ),
              ),
            ]),

            const SizedBox(height: 10),
            _buildTextField(entry.descriptionController, 'description', maxLines: 2),
            const SizedBox(height: 10),

            if (_isGoldShop) ...[
              _buildTextField(entry.wastageController, 'Wastage', inputType: TextInputType.number),
              const SizedBox(height: 10),
            ],

            Row(children: [
              Expanded(child: _buildTextField(entry.priceController, 'price', inputType: TextInputType.number, prefix: Icons.currency_rupee)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(entry.offerPriceController, 'offer_price', inputType: TextInputType.number, prefix: Icons.local_offer)),
            ]),
            const SizedBox(height: 10),
            _buildTextField(entry.hsnController, 'hsn', inputType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelKey,
      {TextInputType inputType = TextInputType.text, IconData? prefix, int maxLines = 1, Function(String)? onChanged}) {
    final label = AppText.translate(context, labelKey);
    final isActive = _activeController == controller && _isListening;
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix != null ? Icon(prefix) : null,
        // suffixIcon: GestureDetector(
        //   onTap: () => _startListening(controller),
        //   child: Container(
        //     margin: const EdgeInsets.only(right: 8),
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: isActive ? Colors.redAccent : Theme.of(context).primaryColor),
        //     child: Icon(isActive ? Icons.mic : Icons.mic_none, color: Colors.white, size: 18),
        //   ),
        // ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          if (_isGoldShop || !(label == 'Taguru' || label == 'Wastage')) return 'Enter $label';
        }
        if (inputType == TextInputType.number && value != null && value.isNotEmpty) {
          try {
            double.parse(value);
          } catch (e) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
    );
  }
}

class ProductEntry {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController wastageController = TextEditingController();
  final TextEditingController hsnController = TextEditingController();
  String? unit;

  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    offerPriceController.dispose();
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    wastageController.dispose();
    hsnController.dispose();
  }
}
