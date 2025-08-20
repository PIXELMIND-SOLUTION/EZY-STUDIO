import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class EditLogo extends StatefulWidget {
  final String image;
  const EditLogo({super.key, required this.image});

  @override
  State<EditLogo> createState() => _EditLogoState();
}

class _EditLogoState extends State<EditLogo> {
  // Replace the single background image with a list of editable images
  final List<_EditableImage> _images = [];
  final List<_EditableText> _texts = [];
  final List<_EditableShape> _shapes = [];
  final List<_EditableElement> _elements = [];

  final GlobalKey _canvasKey = GlobalKey();
  bool _isLoading = false;
  bool _isSaving = false;

  // Available font families
  final List<String> _fontFamilies = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
    'Comic Sans MS',
    'Impact',
    'Trebuchet MS',
    'Lucida Grande',
  ];

  Future<void> _saveLogoToGallery() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Request permission
      final PermissionState result =
          await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        // Capture the canvas as an image
        final Uint8List? logoImage = await _captureCanvasAsImage();

        if (logoImage != null) {
          // Save to gallery
          final AssetEntity? asset = await PhotoManager.editor.saveImage(
            filename: '',
            logoImage,
            title: 'Logo_${DateTime.now().millisecondsSinceEpoch}.png',
          );

          if (asset != null) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logo saved to gallery successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('Failed to save the image');
          }
        } else {
          throw Exception('Failed to capture the canvas');
        }
      } else {
        throw Exception('Permission denied');
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text(
            'Saving posters requires an active subscription plan. Would you like to upgrade now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              showSubscriptionModal(context);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureCanvasAsImage() async {
    try {
      // Add a small delay to ensure the render tree is complete
      await Future.delayed(const Duration(milliseconds: 20));

      // Find the render object from the key
      final RenderRepaintBoundary? boundary = _canvasKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Render boundary is null');
        return null;
      }

      // Capture as image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      debugPrint('ByteData is null');
      return null;
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
      return null;
    }
  }

  void showSubscriptionModal(BuildContext context) {
    final planProvider =
        Provider.of<GetAllPlanProvider>(context, listen: false);
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
        // Create beautiful animation curves
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
                          // Header with gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8E2DE2),
                                  Color(0xFF4A00E0),
                                ],
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
                                    child: Text(
                                      'Choose Your Plan',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF8E2DE2),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade400,
                                            size: 60,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Failed to load plans',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade400,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Please try again later',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                provider.fetchAllPlans(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF8E2DE2),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Try Again'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (provider.plans.isNotEmpty) {
                                  // Use staggered animation list for plans
                                  return AnimatedPlanList(
                                    plans: provider.plans,
                                    onPlanSelected: (plan) {
                                      // Close the modal dialog with fade out animation
                                      Navigator.of(context).pop();

                                      // Navigate to the plan details with hero animation
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              PlanDetailsAndPaymentScreen(
                                                  plan: plan),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.subscriptions,
                                        size: 60,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No subscription plans available',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey.shade600,
                                        ),
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

  // Track selected items for deletion
  _EditableText? _selectedText;
  _EditableShape? _selectedShape;
  _EditableElement? _selectedElement;
  _EditableImage? _selectedImage;

  // Picking image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // Add as an editable image at the center of the canvas
        _images.add(_EditableImage(
          imageFile: File(pickedFile.path),
          offset: const Offset(100, 100), // Initial position
          size: const Size(150, 150), // Initial size
        ));
      });
    }
  }

  // Adding a shape to the editor
  void _addShape(ShapeType shapeType) {
    setState(() {
      _shapes.add(_EditableShape(
        shapeType: shapeType,
        color: Colors.orange,
        size: const Size(80, 80),
        offset: const Offset(100, 100),
      ));
    });
  }

  // Adding an element to the editor
  void _addElement(Map<String, dynamic> elementData) {
    setState(() {
      _elements.add(_EditableElement(
        icon: elementData['icon'],
        name: elementData['name'],
        color: Colors.indigo,
        size: const Size(60, 60),
        offset: const Offset(100, 100),
      ));
    });
  }

  // Delete selected item
  void _deleteSelectedItem() {
    setState(() {
      if (_selectedText != null) {
        _texts.remove(_selectedText);
        _selectedText = null;
      }

      if (_selectedShape != null) {
        _shapes.remove(_selectedShape);
        _selectedShape = null;
      }

      if (_selectedElement != null) {
        _elements.remove(_selectedElement);
        _selectedElement = null;
      }

      if (_selectedImage != null) {
        _images.remove(_selectedImage);
        _selectedImage = null;
      }
    });
  }

  // Select or deselect text
  void _selectText(_EditableText text) {
    setState(() {
      if (_selectedText == text) {
        _selectedText = null; // Deselect if tapping the same text
      } else {
        _selectedText = text;
        _selectedShape = null;
        _selectedElement = null;
        _selectedImage = null; // Deselect any selected image
      }
    });
  }

  // Select or deselect shape
  void _selectShape(_EditableShape shape) {
    setState(() {
      if (_selectedShape == shape) {
        _selectedShape = null; // Deselect if tapping the same shape
      } else {
        _selectedShape = shape;
        _selectedText = null;
        _selectedElement = null;
        _selectedImage = null; // Deselect any selected image
      }
    });
  }

  // Select or deselect element
  void _selectElement(_EditableElement element) {
    setState(() {
      if (_selectedElement == element) {
        _selectedElement = null; // Deselect if tapping the same element
      } else {
        _selectedElement = element;
        _selectedText = null;
        _selectedShape = null;
        _selectedImage = null; // Deselect any selected image
      }
    });
  }

  // Select or deselect image
  void _selectImage(_EditableImage image) {
    setState(() {
      if (_selectedImage == image) {
        _selectedImage = null; // Deselect if tapping the same image
      } else {
        _selectedImage = image;
        _selectedText = null;
        _selectedShape = null;
        _selectedElement = null;
      }
    });
  }

  // Deselect all items
  void _deselectAll() {
    setState(() {
      _selectedText = null;
      _selectedShape = null;
      _selectedElement = null;
      _selectedImage = null; // Deselect any selected image
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.user.id;
      // Get this from your auth state
   
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to handle image editing
  void _showEditImagePopup(_EditableImage editableImage) {
    double selectedSize = editableImage.size.width;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Image',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Size slider
                const Text('Size:'),
                Slider(
                  value: selectedSize,
                  min: 50,
                  max: 300,
                  divisions: 25,
                  label: selectedSize.round().toString(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedSize = value;
                    });
                  },
                ),

                // Save and Delete buttons row
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _images.remove(editableImage);
                          _selectedImage = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editableImage.size = Size(selectedSize, selectedSize);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Method to handle shape editing
  void _showEditShapePopup(_EditableShape editableShape) {
    Color selectedColor = editableShape.color;
    double selectedSize = editableShape.size.width;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Shape',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Color selection
                const Text('Color:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _colorPicker(Colors.blue, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.red, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.green, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.orange, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.purple, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                  ],
                ),

                // Size slider
                const SizedBox(height: 16),
                const Text('Size:'),
                Slider(
                  value: selectedSize,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  label: selectedSize.round().toString(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedSize = value;
                    });
                  },
                ),

                // Save and Delete buttons row
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _shapes.remove(editableShape);
                          _selectedShape = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete Shape',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editableShape.color = selectedColor;
                          editableShape.size = Size(selectedSize, selectedSize);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Method to handle element editing
  void _showEditElementPopup(_EditableElement editableElement) {
    Color selectedColor = editableElement.color;
    double selectedSize = editableElement.size.width;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit ${editableElement.name}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Color selection
                const Text('Color:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _colorPicker(Colors.blue, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.red, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.green, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.indigo, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                    _colorPicker(Colors.purple, (color) {
                      setModalState(() => selectedColor = color);
                    }),
                  ],
                ),
               
                
                // Size slider
                const SizedBox(height: 16),
                const Text('Size:'),
                Slider(
                  value: selectedSize,
                  min: 20,
                  max: 200,
                  divisions: 18,
                  label: selectedSize.round().toString(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedSize = value;
                    });
                  },
                ),

                // Save and Delete buttons row
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _elements.remove(editableElement);
                          _selectedElement = null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete Element',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editableElement.color = selectedColor;
                          editableElement.size =
                              Size(selectedSize, selectedSize);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showAddTextPopup() {
    final TextEditingController _textController = TextEditingController();
    Color selectedColor = Colors.black;
    String selectedFontFamily = _fontFamilies[0];
    double selectedFontSize = 16.0;
    bool isBold = false;
    bool isItalic = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Text'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text input
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Enter Text'),
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Font family dropdown
                  const Text('Font Family:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFontFamily,
                        isExpanded: true,
                        items: _fontFamilies.map((font) {
                          return DropdownMenuItem<String>(
                            value: font,
                            child:
                                Text(font, style: TextStyle(fontFamily: font)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFontFamily = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Font size slider
                  const Text('Font Size:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Slider(
                    value: selectedFontSize,
                    min: 10,
                    max: 48,
                    divisions: 38,
                    label: selectedFontSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFontSize = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Font style toggles
                  // Font style toggles
                  const Text('Font Style:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Bold'),
                          value: isBold,
                          onChanged: (value) {
                            setDialogState(() {
                              isBold = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Italic'),
                          value: isItalic,
                          onChanged: (value) {
                            setDialogState(() {
                              isItalic = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Color selection
                  const Text('Color:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _colorPicker(Colors.black, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.red, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.blue, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.green, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.purple, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Preview text
                  const Text('Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Text(
                      _textController.text.isEmpty
                          ? 'Sample Text'
                          : _textController.text,
                      style: TextStyle(
                        color: selectedColor,
                        fontSize: selectedFontSize,
                        fontFamily: selectedFontFamily,
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            isItalic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    setState(() {
                      _texts.add(_EditableText(
                        text: _textController.text,
                        color: selectedColor,
                        fontSize: selectedFontSize,
                        fontFamily: selectedFontFamily,
                        isBold: isBold,
                        isItalic: isItalic,
                        offset: const Offset(100, 100),
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Text'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditTextPopup(_EditableText editableText) {
    final TextEditingController _textController =
        TextEditingController(text: editableText.text);
    Color selectedColor = editableText.color;
    String selectedFontFamily = editableText.fontFamily;
    double selectedFontSize = editableText.fontSize;
    bool isBold = editableText.isBold;
    bool isItalic = editableText.isItalic;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Text'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text input
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(labelText: 'Enter Text'),
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Font family dropdown
                  const Text('Font Family:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFontFamily,
                        isExpanded: true,
                        items: _fontFamilies.map((font) {
                          return DropdownMenuItem<String>(
                            value: font,
                            child:
                                Text(font, style: TextStyle(fontFamily: font)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedFontFamily = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Font size slider
                  const Text('Font Size:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Slider(
                    value: selectedFontSize,
                    min: 10,
                    max: 48,
                    divisions: 38,
                    label: selectedFontSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFontSize = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Font style toggles
                  const Text('Font Style:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Bold'),
                          value: isBold,
                          onChanged: (value) {
                            setDialogState(() {
                              isBold = value ?? false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Italic'),
                          value: isItalic,
                          onChanged: (value) {
                            setDialogState(() {
                              isItalic = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Color selection
                  const Text('Color:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _colorPicker(Colors.black, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.red, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.blue, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.green, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                      _colorPicker(Colors.purple, (color) {
                        setDialogState(() => selectedColor = color);
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Preview text
                  const Text('Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Text(
                      _textController.text.isEmpty
                          ? 'Sample Text'
                          : _textController.text,
                      style: TextStyle(
                        color: selectedColor,
                        fontSize: selectedFontSize,
                        fontFamily: selectedFontFamily,
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            isItalic ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _texts.remove(editableText);
                    _selectedText = null;
                  });
                  Navigator.pop(context);
                },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    setState(() {
                      editableText.text = _textController.text;
                      editableText.color = selectedColor;
                      editableText.fontSize = selectedFontSize;
                      editableText.fontFamily = selectedFontFamily;
                      editableText.isBold = isBold;
                      editableText.isItalic = isItalic;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _colorPicker(Color color, Function(Color) onTap) {
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          'Edit Logo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_selectedText != null ||
              _selectedShape != null ||
              _selectedElement != null ||
              _selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelectedItem,
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt, color: Colors.black),
            onPressed: _isSaving ? null : _saveLogoToGallery,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Canvas area
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: GestureDetector(
                        onTap: _deselectAll,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Render all images
                              ..._images
                                  .map((image) => _buildEditableImage(image)),
                              // Render all texts
                              ..._texts.map((text) => _buildEditableText(text)),
                              // Render all shapes
                              ..._shapes
                                  .map((shape) => _buildEditableShape(shape)),
                              // Render all elements
                              ..._elements.map(
                                  (element) => _buildEditableElement(element)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tools section
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tool buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildToolButton(
                              icon: Icons.text_format,
                              label: 'AddText',
                              onTap: _showAddTextPopup,
                            ),
                            _buildToolButton(
                              icon: Icons.hide_image,
                              label: 'AddImage',
                              onTap: _pickImage,
                            ),
                            _buildToolButton(
                              icon: Icons.rectangle,
                              label: 'Addshapes',
                              onTap: () => _showShapesBottomSheet(),
                            ),
                            _buildToolButton(
                              icon: Icons.favorite_outline,
                              label: 'elements',
                              onTap: () => _showElementsBottomSheet(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const ui.Color.fromARGB(255, 249, 212, 144),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const ui.Color.fromARGB(255, 249, 212, 144)),
              
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          AppText(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showShapesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText('choose_shape',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShapeOption(ShapeType.circle, Icons.circle, 'circle'),
                _buildShapeOption(
                    ShapeType.rectangle, Icons.rectangle, 'rectangle'),
                _buildShapeOption(
                    ShapeType.triangle, Icons.change_history, 'triangle'),
                _buildShapeOption(ShapeType.star, Icons.star, 'star'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeOption(ShapeType shapeType, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        _addShape(shapeType);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Icon(icon, color: Colors.orange[600], size: 30),
          ),
          const SizedBox(height: 8),
          AppText(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showElementsBottomSheet() {
    final elements = [
      {'icon': Icons.favorite, 'name': 'heart'},
      {'icon': Icons.star, 'name': 'star'},
      {'icon': Icons.lightbulb, 'name': 'bulb'},
      {'icon': Icons.music_note, 'name': 'music'},
      {'icon': Icons.camera, 'name': 'camera'},
      {'icon': Icons.phone, 'name': 'phone'},
      {'icon': Icons.email, 'name': 'email'},
      {'icon': Icons.location_on, 'name': 'location'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          children: [
            const AppText('choose_element',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  final element = elements[index];
                  return GestureDetector(
                    onTap: () {
                      _addElement(element);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo[200]!),
                          ),
                          child: Icon(element['icon'] as IconData,
                              color: Colors.indigo[600], size: 24),
                        ),
                        const SizedBox(height: 4),
                        AppText(element['name'] as String,
                            style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableImage(_EditableImage editableImage) {
    return Positioned(
      left: editableImage.offset.dx,
      top: editableImage.offset.dy,
      child: GestureDetector(
        onTap: () => _selectImage(editableImage),
        onDoubleTap: () => _showEditImagePopup(editableImage),
        onPanUpdate: (details) {
          setState(() {
            editableImage.offset += details.delta;
          });
        },
        child: Container(
          width: editableImage.size.width,
          height: editableImage.size.height,
          decoration: BoxDecoration(
            border: _selectedImage == editableImage
                ? Border.all()
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              editableImage.imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildEditableText(_EditableText editableText) {
  return Positioned(
    left: editableText.offset.dx,
    top: editableText.offset.dy,
    child: GestureDetector(
      onTap: () => _selectText(editableText),
      onDoubleTap: () => _showEditTextPopup(editableText),
      onPanUpdate: (details) {
        setState(() {
          editableText.offset += details.delta;
        });
      },
      child: Text(
        editableText.text,
        style: TextStyle(
          color: editableText.color,
          fontSize: editableText.fontSize,
          fontFamily: editableText.fontFamily,
          fontWeight:
              editableText.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              editableText.isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    ),
  );
}

  Widget _buildEditableShape(_EditableShape editableShape) {
    return Positioned(
      left: editableShape.offset.dx,
      top: editableShape.offset.dy,
      child: GestureDetector(
        onTap: () => _selectShape(editableShape),
        onDoubleTap: () => _showEditShapePopup(editableShape),
        onPanUpdate: (details) {
          setState(() {
            editableShape.offset += details.delta;
          });
        },
        child: Container(
          width: editableShape.size.width,
          height: editableShape.size.height,
          decoration: BoxDecoration(
            border: _selectedShape == editableShape
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: _buildShapeWidget(editableShape),
        ),
      ),
    );
  }

  Widget _buildEditableElement(_EditableElement editableElement) {
    return Positioned(
      left: editableElement.offset.dx,
      top: editableElement.offset.dy,
      child: GestureDetector(
        onTap: () => _selectElement(editableElement),
        onDoubleTap: () => _showEditElementPopup(editableElement),
        onPanUpdate: (details) {
          setState(() {
            editableElement.offset += details.delta;
          });
        },
        child: Container(
          width: editableElement.size.width,
          height: editableElement.size.height,
          decoration: BoxDecoration(
            border: _selectedElement == editableElement
                ? Border.all()
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            editableElement.icon,
            color: editableElement.color,
            size: editableElement.size.width * 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildShapeWidget(_EditableShape shape) {
    switch (shape.shapeType) {
      case ShapeType.circle:
        return Container(
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
          ),
        );
      case ShapeType.rectangle:
        return Container(
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ShapeType.triangle:
        return CustomPaint(
          painter: TrianglePainter(shape.color),
          size: shape.size,
        );
      case ShapeType.star:
        return CustomPaint(
          painter: StarPainter(shape.color),
          size: shape.size,
        );
    }
  }
}

// Supporting classes and enums
class _EditableImage {
  File imageFile;
  Offset offset;
  Size size;

  _EditableImage({
    required this.imageFile,
    required this.offset,
    required this.size,
  });
}

class _EditableText {
  String text;
  Color color;
  double fontSize;
  String fontFamily;
  bool isBold;
  bool isItalic;
  Offset offset;

  _EditableText({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontFamily,
    required this.isBold,
    required this.isItalic,
    required this.offset,
  });
}

class _EditableShape {
  ShapeType shapeType;
  Color color;
  Size size;
  Offset offset;

  _EditableShape({
    required this.shapeType,
    required this.color,
    required this.size,
    required this.offset,
  });
}

class _EditableElement {
  IconData icon;
  String name;
  Color color;
  Size size;
  Offset offset;

  _EditableElement({
    required this.icon,
    required this.name,
    required this.color,
    required this.size,
    required this.offset,
  });
}

enum ShapeType { circle, rectangle, triangle, star }

// Custom painters for shapes
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = math.min(centerX, centerY);
    final double innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final double angle = (i * math.pi) / 5;
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double x = centerX + radius * math.cos(angle - math.pi / 2);
      final double y = centerY + radius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




























// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'package:edit_ezy_project/providers/auth/auth_provider.dart';
// import 'package:edit_ezy_project/providers/language/language_provider.dart';
// import 'package:edit_ezy_project/providers/plans/getall_plan_provider.dart';
// import 'package:edit_ezy_project/views/subscriptions/animated_plan_listscreen.dart';
// import 'package:edit_ezy_project/views/subscriptions/plandetail_payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:math' as math;
// import 'package:photo_manager/photo_manager.dart';
// import 'package:provider/provider.dart';

// class EditLogo extends StatefulWidget {
//   final String image;
//   const EditLogo({super.key, required this.image});

//   @override
//   State<EditLogo> createState() => _EditLogoState();
// }

// class _EditLogoState extends State<EditLogo> with TickerProviderStateMixin {
//   // Replace the single background image with a list of editable images
//   final List<_EditableImage> _images = [];
//   final List<_EditableText> _texts = [];
//   final List<_EditableShape> _shapes = [];
//   final List<_EditableElement> _elements = [];

//   final GlobalKey _canvasKey = GlobalKey();
//   bool _isLoading = false;
//   bool _isSaving = false;

//   late AnimationController _toolsAnimationController;
//   late Animation<double> _toolsAnimation;

//   // Professional color scheme
//   static const Color _primaryColor = Color(0xFF6366F1);
//   static const Color _secondaryColor = Color(0xFF8B5CF6);
//   static const Color _accentColor = Color(0xFF06B6D4);
//   static const Color _surfaceColor = Color(0xFFFFFFFF);
//   static const Color _backgroundColor = Color(0xFFF8FAFC);
//   static const Color _textPrimaryColor = Color(0xFF1E293B);
//   static const Color _textSecondaryColor = Color(0xFF64748B);
//   static const Color _successColor = Color(0xFF10B981);
//   static const Color _errorColor = Color(0xFFEF4444);

//   // Available font families
//   final List<String> _fontFamilies = [
//     'Roboto',
//     'Arial',
//     'Times New Roman',
//     'Courier New',
//     'Georgia',
//     'Verdana',
//     'Comic Sans MS',
//     'Impact',
//     'Trebuchet MS',
//     'Lucida Grande',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadSubscriptions();
    
//     _toolsAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _toolsAnimation = CurvedAnimation(
//       parent: _toolsAnimationController,
//       curve: Curves.easeOutBack,
//     );
    
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _toolsAnimationController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _toolsAnimationController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveLogoToGallery() async {
//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       // Request permission
//       final PermissionState result =
//           await PhotoManager.requestPermissionExtend();
//       if (result.isAuth) {
//         // Capture the canvas as an image
//         final Uint8List? logoImage = await _captureCanvasAsImage();

//         if (logoImage != null) {
//           // Save to gallery
//           final AssetEntity? asset = await PhotoManager.editor.saveImage(
//             filename: '',
//             logoImage,
//             title: 'Logo_${DateTime.now().millisecondsSinceEpoch}.png',
//           );

//           if (asset != null) {
//             // Show success message
//             _showSnackBar(
//               'Logo saved to gallery successfully!',
//               _successColor,
//               Icons.check_circle,
//             );
//           } else {
//             throw Exception('Failed to save the image');
//           }
//         } else {
//           throw Exception('Failed to capture the canvas');
//         }
//       } else {
//         throw Exception('Permission denied');
//       }
//     } catch (e) {
//       // Show error message
//       _showSnackBar(
//         'Failed to save: ${e.toString()}',
//         _errorColor,
//         Icons.error,
//       );
//     } finally {
//       setState(() {
//         _isSaving = false;
//       });
//     }
//   }

//   void _showSnackBar(String message, Color backgroundColor, IconData icon) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showUpgradeDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: _primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.workspace_premium,
//                 color: _primaryColor,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Subscription Required',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: const Text(
//           'Saving posters requires an active subscription plan. Would you like to upgrade now?',
//           style: TextStyle(
//             fontSize: 16,
//             height: 1.4,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: _textSecondaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               showSubscriptionModal(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _primaryColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               'Upgrade',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<Uint8List?> _captureCanvasAsImage() async {
//     try {
//       // Add a small delay to ensure the render tree is complete
//       await Future.delayed(const Duration(milliseconds: 20));

//       // Find the render object from the key
//       final RenderRepaintBoundary? boundary = _canvasKey.currentContext
//           ?.findRenderObject() as RenderRepaintBoundary?;

//       if (boundary == null) {
//         debugPrint('Render boundary is null');
//         return null;
//       }

//       // Capture as image
//       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       final ByteData? byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData != null) {
//         return byteData.buffer.asUint8List();
//       }
//       debugPrint('ByteData is null');
//       return null;
//     } catch (e) {
//       debugPrint('Error capturing canvas: $e');
//       return null;
//     }
//   }

//   void showSubscriptionModal(BuildContext context) {
//     final planProvider =
//         Provider.of<GetAllPlanProvider>(context, listen: false);
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
//         // Create beautiful animation curves
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
//                           // Header with gradient
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   _primaryColor,
//                                   _secondaryColor,
//                                 ],
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
//                                     child: Text(
//                                       'Choose Your Plan',
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
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: 40,
//                                           height: 40,
//                                           child: CircularProgressIndicator(
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                               _primaryColor,
//                                             ),
//                                             strokeWidth: 3,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         Text(
//                                           'Loading plans...',
//                                           style: TextStyle(
//                                             color: _textSecondaryColor,
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
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(
//                                             Icons.error_outline,
//                                             color: _errorColor,
//                                             size: 60,
//                                           ),
//                                           const SizedBox(height: 16),
//                                           Text(
//                                             'Failed to load plans',
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                               color: _errorColor,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             'Please try again later',
//                                             style: TextStyle(
//                                               color: _textSecondaryColor,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 16),
//                                           ElevatedButton.icon(
//                                             onPressed: () =>
//                                                 provider.fetchAllPlans(),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: _primaryColor,
//                                               foregroundColor: Colors.white,
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 horizontal: 20,
//                                                 vertical: 12,
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(30),
//                                               ),
//                                             ),
//                                             icon: const Icon(Icons.refresh),
//                                             label: const Text('Try Again'),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }

//                                 if (provider.plans.isNotEmpty) {
//                                   // Use staggered animation list for plans
//                                   return AnimatedPlanList(
//                                     plans: provider.plans,
//                                     onPlanSelected: (plan) {
//                                       // Close the modal dialog with fade out animation
//                                       Navigator.of(context).pop();

//                                       // Navigate to the plan details with hero animation
//                                       Navigator.push(
//                                         context,
//                                         PageRouteBuilder(
//                                           pageBuilder: (context, animation,
//                                                   secondaryAnimation) =>
//                                               PlanDetailsAndPaymentScreen(
//                                                   plan: plan),
//                                           transitionsBuilder: (context,
//                                               animation,
//                                               secondaryAnimation,
//                                               child) {
//                                             const begin = Offset(1.0, 0.0);
//                                             const end = Offset.zero;
//                                             const curve = Curves.easeOutCubic;

//                                             var tween = Tween(
//                                                     begin: begin, end: end)
//                                                 .chain(
//                                                     CurveTween(curve: curve));
//                                             var offsetAnimation =
//                                                 animation.drive(tween);

//                                             return SlideTransition(
//                                               position: offsetAnimation,
//                                               child: FadeTransition(
//                                                 opacity: animation,
//                                                 child: child,
//                                               ),
//                                             );
//                                           },
//                                           transitionDuration:
//                                               const Duration(milliseconds: 500),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 }

//                                 return Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.subscriptions,
//                                         size: 60,
//                                         color: _textSecondaryColor,
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         'No subscription plans available',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           color: _textSecondaryColor,
//                                         ),
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

//   // Track selected items for deletion
//   _EditableText? _selectedText;
//   _EditableShape? _selectedShape;
//   _EditableElement? _selectedElement;
//   _EditableImage? _selectedImage;

//   // Picking image
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         // Add as an editable image at the center of the canvas
//         _images.add(_EditableImage(
//           imageFile: File(pickedFile.path),
//           offset: const Offset(100, 100), // Initial position
//           size: const Size(150, 150), // Initial size
//         ));
//       });
//     }
//   }

//   // Adding a shape to the editor
//   void _addShape(ShapeType shapeType) {
//     setState(() {
//       _shapes.add(_EditableShape(
//         shapeType: shapeType,
//         color: _accentColor,
//         size: const Size(80, 80),
//         offset: const Offset(100, 100),
//       ));
//     });
//   }

//   // Adding an element to the editor
//   void _addElement(Map<String, dynamic> elementData) {
//     setState(() {
//       _elements.add(_EditableElement(
//         icon: elementData['icon'],
//         name: elementData['name'],
//         color: _primaryColor,
//         size: const Size(60, 60),
//         offset: const Offset(100, 100),
//       ));
//     });
//   }

//   // Delete selected item
//   void _deleteSelectedItem() {
//     setState(() {
//       if (_selectedText != null) {
//         _texts.remove(_selectedText);
//         _selectedText = null;
//       }

//       if (_selectedShape != null) {
//         _shapes.remove(_selectedShape);
//         _selectedShape = null;
//       }

//       if (_selectedElement != null) {
//         _elements.remove(_selectedElement);
//         _selectedElement = null;
//       }

//       if (_selectedImage != null) {
//         _images.remove(_selectedImage);
//         _selectedImage = null;
//       }
//     });
//   }

//   // Select or deselect text
//   void _selectText(_EditableText text) {
//     setState(() {
//       if (_selectedText == text) {
//         _selectedText = null; // Deselect if tapping the same text
//       } else {
//         _selectedText = text;
//         _selectedShape = null;
//         _selectedElement = null;
//         _selectedImage = null; // Deselect any selected image
//       }
//     });
//   }

//   // Select or deselect shape
//   void _selectShape(_EditableShape shape) {
//     setState(() {
//       if (_selectedShape == shape) {
//         _selectedShape = null; // Deselect if tapping the same shape
//       } else {
//         _selectedShape = shape;
//         _selectedText = null;
//         _selectedElement = null;
//         _selectedImage = null; // Deselect any selected image
//       }
//     });
//   }

//   // Select or deselect element
//   void _selectElement(_EditableElement element) {
//     setState(() {
//       if (_selectedElement == element) {
//         _selectedElement = null; // Deselect if tapping the same element
//       } else {
//         _selectedElement = element;
//         _selectedText = null;
//         _selectedShape = null;
//         _selectedImage = null; // Deselect any selected image
//       }
//     });
//   }

//   // Select or deselect image
//   void _selectImage(_EditableImage image) {
//     setState(() {
//       if (_selectedImage == image) {
//         _selectedImage = null; // Deselect if tapping the same image
//       } else {
//         _selectedImage = image;
//         _selectedText = null;
//         _selectedShape = null;
//         _selectedElement = null;
//       }
//     });
//   }

//   // Deselect all items
//   void _deselectAll() {
//     setState(() {
//       _selectedText = null;
//       _selectedShape = null;
//       _selectedElement = null;
//       _selectedImage = null; // Deselect any selected image
//     });
//   }

//   Future<void> _loadSubscriptions() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final userId = authProvider.user?.user.id;
//       // Get this from your auth state
   
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Method to handle image editing
//   void _showEditImagePopup(_EditableImage editableImage) {
//     double selectedSize = editableImage.size.width;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return StatefulBuilder(builder: (context, setModalState) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             padding: EdgeInsets.only(
//               left: 24,
//               right: 24,
//               top: 24,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _accentColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         Icons.image,
//                         color: _accentColor,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Edit Image',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: _textPrimaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Size slider
//                 Text(
//                   'Size: ${selectedSize.round()}px',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     activeTrackColor: _accentColor,
//                     inactiveTrackColor: _accentColor.withOpacity(0.2),
//                     thumbColor: _accentColor,
//                     overlayColor: _accentColor.withOpacity(0.2),
//                     trackHeight: 4,
//                     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
//                   ),
//                   child: Slider(
//                     value: selectedSize,
//                     min: 50,
//                     max: 300,
//                     divisions: 25,
//                     onChanged: (value) {
//                       setModalState(() {
//                         selectedSize = value;
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Action buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             _images.remove(editableImage);
//                             _selectedImage = null;
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: _errorColor,
//                           side: BorderSide(color: _errorColor),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         icon: const Icon(Icons.delete_outline, size: 20),
//                         label: const Text(
//                           'Delete',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             editableImage.size = Size(selectedSize, selectedSize);
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         icon: const Icon(Icons.check, size: 20),
//                         label: const Text(
//                           'Save',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   // Method to handle shape editing
//   void _showEditShapePopup(_EditableShape editableShape) {
//     Color selectedColor = editableShape.color;
//     double selectedSize = editableShape.size.width;

//     final colors = [
//       _primaryColor,
//       _secondaryColor,
//       _accentColor,
//       _successColor,
//       _errorColor,
//       Colors.orange,
//       Colors.pink,
//       Colors.teal,
//     ];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return StatefulBuilder(builder: (context, setModalState) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             padding: EdgeInsets.only(
//               left: 24,
//               right: 24,
//               top: 24,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _accentColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         Icons.crop_free,
//                         color: _accentColor,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Edit Shape',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: _textPrimaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Color selection
//                 const Text(
//                   'Color',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: colors.map((color) {
//                     final isSelected = selectedColor == color;
//                     return GestureDetector(
//                       onTap: () {
//                         setModalState(() => selectedColor = color);
//                       },
//                       child: Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: color,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isSelected ? Colors.white : Colors.grey.shade300,
//                             width: isSelected ? 3 : 1,
//                           ),
//                           boxShadow: isSelected ? [
//                             BoxShadow(
//                               color: color.withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ] : null,
// ),
//                         child: isSelected ? const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 24,
//                         ) : null,
//                       ),
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 24),

//                 // Size slider
//                 Text(
//                   'Size: ${selectedSize.round()}px',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     activeTrackColor: _accentColor,
//                     inactiveTrackColor: _accentColor.withOpacity(0.2),
//                     thumbColor: _accentColor,
//                     overlayColor: _accentColor.withOpacity(0.2),
//                     trackHeight: 4,
//                     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
//                   ),
//                   child: Slider(
//                     value: selectedSize,
//                     min: 30,
//                     max: 200,
//                     divisions: 17,
//                     onChanged: (value) {
//                       setModalState(() {
//                         selectedSize = value;
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Action buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             _shapes.remove(editableShape);
//                             _selectedShape = null;
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: _errorColor,
//                           side: BorderSide(color: _errorColor),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         icon: const Icon(Icons.delete_outline, size: 20),
//                         label: const Text(
//                           'Delete',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             editableShape.color = selectedColor;
//                             editableShape.size = Size(selectedSize, selectedSize);
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         icon: const Icon(Icons.check, size: 20),
//                         label: const Text(
//                           'Save',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   // Method to handle element editing
//   void _showEditElementPopup(_EditableElement editableElement) {
//     Color selectedColor = editableElement.color;
//     double selectedSize = editableElement.size.width;

//     final colors = [
//       _primaryColor,
//       _secondaryColor,
//       _accentColor,
//       _successColor,
//       _errorColor,
//       Colors.orange,
//       Colors.pink,
//       Colors.teal,
//     ];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return StatefulBuilder(builder: (context, setModalState) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             padding: EdgeInsets.only(
//               left: 24,
//               right: 24,
//               top: 24,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _accentColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         editableElement.icon,
//                         color: _accentColor,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Edit ${editableElement.name}',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: _textPrimaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Color selection
//                 const Text(
//                   'Color',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: colors.map((color) {
//                     final isSelected = selectedColor == color;
//                     return GestureDetector(
//                       onTap: () {
//                         setModalState(() => selectedColor = color);
//                       },
//                       child: Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: color,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isSelected ? Colors.white : Colors.grey.shade300,
//                             width: isSelected ? 3 : 1,
//                           ),
//                           boxShadow: isSelected ? [
//                             BoxShadow(
//                               color: color.withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ] : null,
//                         ),
//                         child: isSelected ? const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 24,
//                         ) : null,
//                       ),
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 24),

//                 // Size slider
//                 Text(
//                   'Size: ${selectedSize.round()}px',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: _textPrimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SliderTheme(
//                   data: SliderTheme.of(context).copyWith(
//                     activeTrackColor: _accentColor,
//                     inactiveTrackColor: _accentColor.withOpacity(0.2),
//                     thumbColor: _accentColor,
//                     overlayColor: _accentColor.withOpacity(0.2),
//                     trackHeight: 4,
//                     thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
//                   ),
//                   child: Slider(
//                     value: selectedSize,
//                     min: 30,
//                     max: 120,
//                     divisions: 9,
//                     onChanged: (value) {
//                       setModalState(() {
//                         selectedSize = value;
//                       });
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Action buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             _elements.remove(editableElement);
//                             _selectedElement = null;
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: _errorColor,
//                           side: BorderSide(color: _errorColor),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         icon: const Icon(Icons.delete_outline, size: 20),
//                         label: const Text(
//                           'Delete',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             editableElement.color = selectedColor;
//                             editableElement.size = Size(selectedSize, selectedSize);
//                           });
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         icon: const Icon(Icons.check, size: 20),
//                         label: const Text(
//                           'Save',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }

//   // Method to handle text editing
//   void _showEditTextPopup(_EditableText editableText) {
//     final TextEditingController textController = TextEditingController(text: editableText.text);
//     String selectedFontFamily = editableText.fontFamily;
//     Color selectedColor = editableText.color;
//     double selectedFontSize = editableText.fontSize;
//     FontWeight selectedFontWeight = editableText.fontWeight;

//     final colors = [
//       _primaryColor,
//       _secondaryColor,
//       _accentColor,
//       _successColor,
//       _errorColor,
//       Colors.orange,
//       Colors.pink,
//       Colors.teal,
//       Colors.black,
//       Colors.white,
//     ];

//     final fontWeights = [
//       {'label': 'Light', 'weight': FontWeight.w300},
//       {'label': 'Normal', 'weight': FontWeight.w400},
//       {'label': 'Medium', 'weight': FontWeight.w500},
//       {'label': 'Bold', 'weight': FontWeight.w700},
//       {'label': 'Extra Bold', 'weight': FontWeight.w800},
//     ];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return StatefulBuilder(builder: (context, setModalState) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: _surfaceColor,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             padding: EdgeInsets.only(
//               left: 24,
//               right: 24,
//               top: 24,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: _accentColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.text_fields,
//                           color: _accentColor,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Edit Text',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: _textPrimaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Text input
//                   const Text(
//                     'Text',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: textController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your text',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: _primaryColor, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     ),
//                     maxLines: null,
//                   ),

//                   const SizedBox(height: 24),

//                   // Font family
//                   const Text(
//                     'Font Family',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: selectedFontFamily,
//                         isExpanded: true,
//                         items: _fontFamilies.map((String font) {
//                           return DropdownMenuItem<String>(
//                             value: font,
//                             child: Text(
//                               font,
//                               style: TextStyle(fontFamily: font),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (String? newFont) {
//                           if (newFont != null) {
//                             setModalState(() => selectedFontFamily = newFont);
//                           }
//                         },
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Color selection
//                   const Text(
//                     'Color',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 12,
//                     runSpacing: 12,
//                     children: colors.map((color) {
//                       final isSelected = selectedColor == color;
//                       return GestureDetector(
//                         onTap: () {
//                           setModalState(() => selectedColor = color);
//                         },
//                         child: Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: isSelected ? (color == Colors.white ? Colors.grey : Colors.white) : Colors.grey.shade300,
//                               width: isSelected ? 3 : 1,
//                             ),
//                             boxShadow: isSelected ? [
//                               BoxShadow(
//                                 color: color.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ] : null,
//                           ),
//                           child: isSelected ? Icon(
//                             Icons.check,
//                             color: color == Colors.white ? Colors.black : Colors.white,
//                             size: 24,
//                           ) : null,
//                         ),
//                       );
//                     }).toList(),
//                   ),

//                   const SizedBox(height: 24),

//                   // Font size
//                   Text(
//                     'Font Size: ${selectedFontSize.round()}px',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       activeTrackColor: _accentColor,
//                       inactiveTrackColor: _accentColor.withOpacity(0.2),
//                       thumbColor: _accentColor,
//                       overlayColor: _accentColor.withOpacity(0.2),
//                       trackHeight: 4,
//                       thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
//                     ),
//                     child: Slider(
//                       value: selectedFontSize,
//                       min: 12,
//                       max: 72,
//                       divisions: 30,
//                       onChanged: (value) {
//                         setModalState(() {
//                           selectedFontSize = value;
//                         });
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Font weight
//                   const Text(
//                     'Font Weight',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: _textPrimaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: fontWeights.map((fontWeight) {
//                       final isSelected = selectedFontWeight == fontWeight['weight'];
//                       return GestureDetector(
//                         onTap: () {
//                           setModalState(() => selectedFontWeight = fontWeight['weight'] as FontWeight);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: isSelected ? _primaryColor : Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: isSelected ? _primaryColor : Colors.grey.shade300,
//                             ),
//                           ),
//                           child: Text(
//                             fontWeight['label'] as String,
//                             style: TextStyle(
//                               color: isSelected ? Colors.white : _textPrimaryColor,
//                               fontWeight: fontWeight['weight'] as FontWeight,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),

//                   const SizedBox(height: 32),

//                   // Action buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             setState(() {
//                               _texts.remove(editableText);
//                               _selectedText = null;
//                             });
//                             Navigator.pop(context);
//                           },
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: _errorColor,
//                             side: BorderSide(color: _errorColor),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           icon: const Icon(Icons.delete_outline, size: 20),
//                           label: const Text(
//                             'Delete',
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             setState(() {
//                               editableText.text = textController.text;
//                               editableText.fontFamily = selectedFontFamily;
//                               editableText.color = selectedColor;
//                               editableText.fontSize = selectedFontSize;
//                               editableText.fontWeight = selectedFontWeight;
//                             });
//                             Navigator.pop(context);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _primaryColor,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 0,
//                           ),
//                           icon: const Icon(Icons.check, size: 20),
//                           label: const Text(
//                             'Save',
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   // Method to add text to the canvas
//   void _addText() {
//     setState(() {
//       _texts.add(_EditableText(
//         text: 'Tap to edit',
//         fontSize: 24,
//         color: _textPrimaryColor,
//         fontFamily: 'Roboto',
//         fontWeight: FontWeight.w500,
//         offset: const Offset(100, 100),
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: _surfaceColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: _textPrimaryColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Logo Editor',
//           style: TextStyle(
//             color: _textPrimaryColor,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           if (_selectedText != null || _selectedShape != null || _selectedElement != null || _selectedImage != null)
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: _errorColor),
//               onPressed: _deleteSelectedItem,
//             ),
//           IconButton(
//             icon: _isSaving
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
//                     ),
//                   )
//                 : const Icon(Icons.download, color: _primaryColor),
//             onPressed: _isSaving ? null : _saveLogoToGallery,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Canvas area
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _surfaceColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: RepaintBoundary(
//                   key: _canvasKey,
//                   child: GestureDetector(
//                     onTap: _deselectAll,
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: NetworkImage(widget.image),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           // Render all images
//                           ..._images.map((editableImage) {
//                             return Positioned(
//                               left: editableImage.offset.dx,
//                               top: editableImage.offset.dy,
//                               child: GestureDetector(
//                                 onTap: () => _selectImage(editableImage),
//                                 onDoubleTap: () => _showEditImagePopup(editableImage),
//                                 onPanUpdate: (details) {
//                                   setState(() {
//                                     editableImage.offset = Offset(
//                                       editableImage.offset.dx + details.delta.dx,
//                                       editableImage.offset.dy + details.delta.dy,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   width: editableImage.size.width,
//                                   height: editableImage.size.height,
//                                   decoration: BoxDecoration(
//                                     border: _selectedImage == editableImage
//                                         ? Border.all(color: _primaryColor, width: 2)
//                                         : null,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child: Image.file(
//                                       editableImage.imageFile,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),

//                           // Render all shapes
//                           ..._shapes.map((editableShape) {
//                             return Positioned(
//                               left: editableShape.offset.dx,
//                               top: editableShape.offset.dy,
//                               child: GestureDetector(
//                                 onTap: () => _selectShape(editableShape),
//                                 onDoubleTap: () => _showEditShapePopup(editableShape),
//                                 onPanUpdate: (details) {
//                                   setState(() {
//                                     editableShape.offset = Offset(
//                                       editableShape.offset.dx + details.delta.dx,
//                                       editableShape.offset.dy + details.delta.dy,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   width: editableShape.size.width,
//                                   height: editableShape.size.height,
//                                   decoration: BoxDecoration(
//                                     color: editableShape.color,
//                                     shape: editableShape.shapeType == ShapeType.circle
//                                         ? BoxShape.circle
//                                         : BoxShape.rectangle,
//                                     borderRadius: editableShape.shapeType == ShapeType.rectangle
//                                         ? BorderRadius.circular(8)
//                                         : null,
//                                     border: _selectedShape == editableShape
//                                         ? Border.all(color: _primaryColor, width: 2)
//                                         : null,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),

//                           // Render all elements
//                           ..._elements.map((editableElement) {
//                             return Positioned(
//                               left: editableElement.offset.dx,
//                               top: editableElement.offset.dy,
//                               child: GestureDetector(
//                                 onTap: () => _selectElement(editableElement),
//                                 onDoubleTap: () => _showEditElementPopup(editableElement),
//                                 onPanUpdate: (details) {
//                                   setState(() {
//                                     editableElement.offset = Offset(
//                                       editableElement.offset.dx + details.delta.dx,
//                                       editableElement.offset.dy + details.delta.dy,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   width: editableElement.size.width,
//                                   height: editableElement.size.height,
//                                   decoration: BoxDecoration(
//                                     color: editableElement.color,
//                                     shape: BoxShape.circle,
//                                     border: _selectedElement == editableElement
//                                         ? Border.all(color: _primaryColor, width: 2)
//                                         : null,
//                                   ),
//                                   child: Icon(
//                                     editableElement.icon,
//                                     color: Colors.white,
//                                     size: editableElement.size.width * 0.6,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),

//                           // Render all texts
//                           ..._texts.map((editableText) {
//                             return Positioned(
//                               left: editableText.offset.dx,
//                               top: editableText.offset.dy,
//                               child: GestureDetector(
//                                 onTap: () => _selectText(editableText),
//                                 onDoubleTap: () => _showEditTextPopup(editableText),
//                                 onPanUpdate: (details) {
//                                   setState(() {
//                                     editableText.offset = Offset(
//                                       editableText.offset.dx + details.delta.dx,
//                                       editableText.offset.dy + details.delta.dy,
//                                     );
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     border: _selectedText == editableText
//                                         ? Border.all(color: _primaryColor, width: 2)
//                                         : null,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     editableText.text,
//                                     style: TextStyle(
//                                       fontSize: editableText.fontSize,
//                                       color: editableText.color,
//                                       fontFamily: editableText.fontFamily,
//                                       fontWeight: editableText.fontWeight,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Tool panel
//           AnimatedBuilder(
//             animation: _toolsAnimation,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(0, 100 * (1 - _toolsAnimation.value)),
//                 child: Opacity(
//                   opacity: _toolsAnimation.value,
//                   child: Container(
//                     height: 120,
//                     margin: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: _surfaceColor,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           offset: const Offset(0, -4),
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       child: Row(
//                         children: [
//                           // Add Text
//                           _buildToolButton(
//                             icon: Icons.text_fields,
//                             label: 'Text',
//                             color: _primaryColor,
//                             onTap: _addText,
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Image
//                           _buildToolButton(
//                             icon: Icons.image,
//                             label: 'Image',
//                             color: _accentColor,
//                             onTap: _pickImage,
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Circle
//                           _buildToolButton(
//                             icon: Icons.circle,
//                             label: 'Circle',
//                             color: _secondaryColor,
//                             onTap: () => _addShape(ShapeType.circle),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Rectangle
//                           _buildToolButton(
//                             icon: Icons.rectangle,
//                             label: 'Rectangle',
//                             color: _successColor,
//                             onTap: () => _addShape(ShapeType.rectangle),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Star Element
//                           _buildToolButton(
//                             icon: Icons.star,
//                             label: 'Star',
//                             color: Colors.orange,
//                             onTap: () => _addElement({
//                               'icon': Icons.star,
//                               'name': 'Star',
//                             }),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Heart Element
//                           _buildToolButton(
//                             icon: Icons.favorite,
//                             label: 'Heart',
//                             color: Colors.pink,
//                             onTap: () => _addElement({
//                               'icon': Icons.favorite,
//                               'name': 'Heart',
//                             }),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Diamond Element
//                           _buildToolButton(
//                             icon: Icons.diamond,
//                             label: 'Diamond',
//                             color: Colors.cyan,
//                             onTap: () => _addElement({
//                               'icon': Icons.diamond,
//                               'name': 'Diamond',
//                             }),
//                           ),
//                           const SizedBox(width: 16),
                          
//                           // Add Lightning Element
//                           _buildToolButton(
//                             icon: Icons.bolt,
//                             label: 'Lightning',
//                             color: Colors.yellow.shade700,
//                             onTap: () => _addElement({
//                               'icon': Icons.bolt,
//                               'name': 'Lightning',
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToolButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: color.withOpacity(0.2)),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: _textSecondaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Supporting classes
// class _EditableImage {
//   File imageFile;
//   Offset offset;
//   Size size;

//   _EditableImage({
//     required this.imageFile,
//     required this.offset,
//     required this.size,
//   });
// }

// class _EditableText {
//   String text;
//   double fontSize;
//   Color color;
//   String fontFamily;
//   FontWeight fontWeight;
//   Offset offset;

//   _EditableText({
//     required this.text,
//     required this.fontSize,
//     required this.color,
//     required this.fontFamily,
//     required this.fontWeight,
//     required this.offset,
//   });
// }

// class _EditableShape {
//   ShapeType shapeType;
//   Color color;
//   Size size;
//   Offset offset;

//   _EditableShape({
//     required this.shapeType,
//     required this.color,
//     required this.size,
//     required this.offset,
//   });
// }

// class _EditableElement {
//   IconData icon;
//   String name;
//   Color color;
//   Size size;
//   Offset offset;

//   _EditableElement({
//     required this.icon,
//     required this.name,
//     required this.color,
//     required this.size,
//     required this.offset,
//   });
// }

// enum ShapeType {
//   circle,
//   rectangle,
// }