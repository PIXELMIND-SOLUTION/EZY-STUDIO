import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';
import 'package:edit_ezy_project/helper/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

// Template Models
class PosterTemplate {
  String id;
  String name;
  String categoryName;
  String description;
  String title;
  String email;
  String mobile;
  double width;
  double height;
  String? backgroundImage;
  Color backgroundColor;
  List<TextElement> textElements;
  List<ImageElement> imageElements;
  DesignData designData;

  PosterTemplate({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.description,
    required this.title,
    required this.email,
    required this.mobile,
    required this.width,
    required this.height,
    this.backgroundImage,
    this.backgroundColor = Colors.white,
    this.textElements = const [],
    this.imageElements = const [],
    required this.designData,
  });

  void updateWithUserData(String? userEmail, String? userMobile) {
    for (var element in textElements) {
      switch (element.id) {
        case 'email':
          if (userEmail != null && userEmail.isNotEmpty) {
            element.text = userEmail;
          }
          break;
        case 'mobile':
          if (userMobile != null && userMobile.isNotEmpty) {
            element.text = userMobile;
          }
          break;
      }
    }
  }

  factory PosterTemplate.fromApiResponse(
    Map<String, dynamic> apiResponse, {
    String? userEmail,
    String? userMobile,
  }) {
    final posterData = apiResponse['poster'] as Map<String, dynamic>;
    final designData = posterData['designData'] as Map<String, dynamic>;

    // Create text elements based on visibility
    List<TextElement> textElements = [];
    final textSettings = TextSettings.fromJson(
      designData['textSettings'] ?? {},
    );
    final textStyles = TextStyles.fromJson(designData['textStyles'] ?? {});
    final textVisibility = TextVisibility.fromJson(
      designData['textVisibility'] ?? {},
    );

    if (textVisibility.isVisible('title')) {
      textElements.add(
        TextElement(
          id: 'title',
          text: posterData['title'] as String? ?? '',
          x: textSettings.titleX,
          y: textSettings.titleY,
          width: 800,
          height: 200,
          fontSize: textStyles.title.fontSize ?? 32,
          color: textStyles.title.color ?? Colors.black,
          fontWeight: textStyles.title.fontWeight ?? FontWeight.bold,
          fontFamily: textStyles.title.fontFamily ?? 'Times New Roman',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (textVisibility.isVisible('description')) {
      textElements.add(
        TextElement(
          id: 'description',
          text: posterData['description'] as String? ?? '',
          x: textSettings.descriptionX,
          y: textSettings.descriptionY,
          width: 900,
          height: 400,
          fontSize: textStyles.description.fontSize ?? 20,
          color: textStyles.description.color ?? Colors.black,
          fontWeight: textStyles.description.fontWeight ?? FontWeight.bold,
          fontFamily: textStyles.description.fontFamily ?? 'Times New Roman',
          textAlign: TextAlign.left,
        ),
      );
    }

    if (textVisibility.isVisible('email')) {
      textElements.add(
        TextElement(
          id: 'email',
          // Use user email if provided, otherwise fall back to poster data
          text: userEmail?.isNotEmpty == true
              ? userEmail!
              : (posterData['email'] as String? ?? ''),
          x: textSettings.emailX,
          y: textSettings.emailY,
          width: 600,
          height: 150,
          fontSize: textStyles.email.fontSize ?? 24,
          color: textStyles.email.color ?? Colors.black,
          fontWeight: textStyles.email.fontWeight ?? FontWeight.bold,
          fontFamily: textStyles.email.fontFamily ?? 'Times New Roman',
          textAlign: TextAlign.left,
        ),
      );
    }

    if (textVisibility.isVisible('mobile')) {
      textElements.add(
        TextElement(
          id: 'mobile',
          // Use user mobile if provided, otherwise fall back to poster data
          text: userMobile?.isNotEmpty == true
              ? userMobile!
              : (posterData['mobile'] as String? ?? ''),
          x: textSettings.mobileX,
          y: textSettings.mobileY,
          width: 500,
          height: 150,
          fontSize: textStyles.mobile.fontSize ?? 25,
          color: textStyles.mobile.color ?? Colors.black,
          fontWeight: textStyles.mobile.fontWeight ?? FontWeight.bold,
          fontFamily: textStyles.mobile.fontFamily ?? 'Times New Roman',
          textAlign: TextAlign.left,
        ),
      );
    }

    if (textVisibility.isVisible('name')) {
      textElements.add(
        TextElement(
          id: 'name',
          text: posterData['name'] as String? ?? '',
          x: textSettings.nameX,
          y: textSettings.nameY,
          width: 400,
          height: 100,
          fontSize: textStyles.name.fontSize ?? 24,
          color: textStyles.name.color ?? Colors.black,
          fontWeight: textStyles.name.fontWeight ?? FontWeight.bold,
          fontFamily: textStyles.name.fontFamily ?? 'Arial',
          textAlign: TextAlign.left,
        ),
      );
    }

    const double canvasWidth = 720;
    // Create image elements from overlay images
    List<ImageElement> imageElements = [];
    if (designData['overlayImages'] != null) {
      final overlayImages = designData['overlayImages'] as List<dynamic>;
      final overlays =
          designData['overlaySettings']?['overlays'] as List<dynamic>? ?? [];

      for (int i = 0; i < overlayImages.length; i++) {
        final img = overlayImages[i];
        // Use overlay position if available, otherwise use default
        final overlay = i < overlays.length ? overlays[i] : null;

        imageElements.add(
          ImageElement(
            id: img['_id'] ??
                'overlay_${DateTime.now().millisecondsSinceEpoch}',
            imageUrl: img['url'] ?? '',
            x: overlay != null ? _parseDouble(overlay['x'], 324) : 324,
            y: overlay != null ? _parseDouble(overlay['y'], 521) : 521,
            width: overlay != null ? _parseDouble(overlay['width'], 252) : 252,
            height:
                overlay != null ? _parseDouble(overlay['height'], 252) : 252,
          ),
        );
      }
    }

    return PosterTemplate(
      id: posterData['_id'] ??
          'template_${DateTime.now().millisecondsSinceEpoch}',
      name: posterData['name'] ?? 'Untitled',
      categoryName: posterData['categoryName'] ?? '',
      description: posterData['description'] ?? '',
      title: posterData['title'] ?? '',
      email: posterData['email'] ?? '',
      mobile: posterData['mobile'] ?? '',
      width: 900, // Standard poster width
      height: 1200, // Standard poster height
      backgroundImage: designData['bgImage']?['url'],
      backgroundColor: Colors.white,
      textElements: textElements,
      imageElements: imageElements,
      designData: DesignData.fromJson(designData),
    );
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryName': categoryName,
      'description': description,
      'title': title,
      'email': email,
      'mobile': mobile,
      'width': width,
      'height': height,
      'backgroundImage': backgroundImage,
      'backgroundColor': backgroundColor.value,
      'textElements': textElements.map((e) => e.toJson()).toList(),
      'imageElements': imageElements.map((e) => e.toJson()).toList(),
      'designData': designData.toJson(),
    };
  }
}

class DesignData {
  BgImageSettings bgImageSettings;
  OverlaySettings overlaySettings;
  TextSettings textSettings;
  TextStyles textStyles;
  TextVisibility textVisibility;
  List<OverlayImageFilter> overlayImageFilters;

  DesignData({
    required this.bgImageSettings,
    required this.overlaySettings,
    required this.textSettings,
    required this.textStyles,
    required this.textVisibility,
    required this.overlayImageFilters,
  });

  factory DesignData.fromJson(Map<String, dynamic> json) {
    return DesignData(
      bgImageSettings: BgImageSettings.fromJson(json['bgImageSettings'] ?? {}),
      overlaySettings: OverlaySettings.fromJson(json['overlaySettings'] ?? {}),
      textSettings: TextSettings.fromJson(json['textSettings'] ?? {}),
      textStyles: TextStyles.fromJson(json['textStyles'] ?? {}),
      textVisibility: TextVisibility.fromJson(json['textVisibility'] ?? {}),
      overlayImageFilters: (json['overlayImageFilters'] as List<dynamic>?)
              ?.map((e) => OverlayImageFilter.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bgImageSettings': bgImageSettings.toJson(),
      'overlaySettings': overlaySettings.toJson(),
      'textSettings': textSettings.toJson(),
      'textStyles': textStyles.toJson(),
      'textVisibility': textVisibility.toJson(),
      'overlayImageFilters':
          overlayImageFilters.map((e) => e.toJson()).toList(),
    };
  }
}

class BgImageSettings {
  ImageFilters filters;

  BgImageSettings({required this.filters});

  factory BgImageSettings.fromJson(Map<String, dynamic> json) {
    return BgImageSettings(
      filters: ImageFilters.fromJson(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'filters': filters.toJson()};
  }
}

class ImageFilters {
  double brightness;
  double contrast;
  double saturation;
  double grayscale;
  double blur;

  ImageFilters({
    this.brightness = 100,
    this.contrast = 100,
    this.saturation = 100,
    this.grayscale = 0,
    this.blur = 0,
  });

  factory ImageFilters.fromJson(Map<String, dynamic> json) {
    return ImageFilters(
      brightness: _parseDouble(json['brightness'], 100),
      contrast: _parseDouble(json['contrast'], 100),
      saturation: _parseDouble(json['saturation'], 100),
      grayscale: _parseDouble(json['grayscale'], 0),
      blur: _parseDouble(json['blur'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'grayscale': grayscale,
      'blur': blur,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class OverlaySettings {
  List<Overlay> overlays;

  OverlaySettings({required this.overlays});

  factory OverlaySettings.fromJson(Map<String, dynamic> json) {
    return OverlaySettings(
      overlays: (json['overlays'] as List<dynamic>?)
              ?.map((e) => Overlay.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'overlays': overlays.map((e) => e.toJson()).toList()};
  }
}

class Overlay {
  double x;
  double y;
  double width;
  double height;
  String shape;
  double borderRadius;

  Overlay({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.shape,
    required this.borderRadius,
  });

  factory Overlay.fromJson(Map<String, dynamic> json) {
    return Overlay(
      x: _parseDouble(json['x'], 0),
      y: _parseDouble(json['y'], 0),
      width: _parseDouble(json['width'], 100),
      height: _parseDouble(json['height'], 100),
      shape: json['shape'] ?? 'rectangle',
      borderRadius: _parseDouble(json['borderRadius'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'shape': shape,
      'borderRadius': borderRadius,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class TextSettings {
  double nameX;
  double nameY;
  double emailX;
  double emailY;
  double mobileX;
  double mobileY;
  double titleX;
  double titleY;
  double descriptionX;
  double descriptionY;
  double tagsX;
  double tagsY;

  TextSettings({
    required this.nameX,
    required this.nameY,
    required this.emailX,
    required this.emailY,
    required this.mobileX,
    required this.mobileY,
    required this.titleX,
    required this.titleY,
    required this.descriptionX,
    required this.descriptionY,
    required this.tagsX,
    required this.tagsY,
  });

  factory TextSettings.fromJson(Map<String, dynamic> json) {
    return TextSettings(
      nameX: _parseDouble(json['nameX'], 0),
      nameY: _parseDouble(json['nameY'], 0),
      emailX: _parseDouble(json['emailX'], 0),
      emailY: _parseDouble(json['emailY'], 0),
      mobileX: _parseDouble(json['mobileX'], 0),
      mobileY: _parseDouble(json['mobileY'], 0),
      titleX: _parseDouble(json['titleX'], 0),
      titleY: _parseDouble(json['titleY'], 0),
      descriptionX: _parseDouble(json['descriptionX'], 0),
      descriptionY: _parseDouble(json['descriptionY'], 0),
      tagsX: _parseDouble(json['tagsX'], 0),
      tagsY: _parseDouble(json['tagsY'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameX': nameX,
      'nameY': nameY,
      'emailX': emailX,
      'emailY': emailY,
      'mobileX': mobileX,
      'mobileY': mobileY,
      'titleX': titleX,
      'titleY': titleY,
      'descriptionX': descriptionX,
      'descriptionY': descriptionY,
      'tagsX': tagsX,
      'tagsY': tagsY,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class TextStyles {
  TextStyle name;
  TextStyle email;
  TextStyle mobile;
  TextStyle title;
  TextStyle description;
  TextStyle tags;

  TextStyles({
    required this.name,
    required this.email,
    required this.mobile,
    required this.title,
    required this.description,
    required this.tags,
  });

  factory TextStyles.fromJson(Map<String, dynamic> json) {
    return TextStyles(
      name: _textStyleFromJson(json['name'] ?? {}),
      email: _textStyleFromJson(json['email'] ?? {}),
      mobile: _textStyleFromJson(json['mobile'] ?? {}),
      title: _textStyleFromJson(json['title'] ?? {}),
      description: _textStyleFromJson(json['description'] ?? {}),
      tags: _textStyleFromJson(json['tags'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _textStyleToJson(name),
      'email': _textStyleToJson(email),
      'mobile': _textStyleToJson(mobile),
      'title': _textStyleToJson(title),
      'description': _textStyleToJson(description),
      'tags': _textStyleToJson(tags),
    };
  }

  static TextStyle _textStyleFromJson(Map<String, dynamic> json) {
    return TextStyle(
      fontSize: _parseDouble(json['fontSize'], 16),
      color: _parseColor(json['color']),
      fontFamily: json['fontFamily'] ?? 'Arial',
      fontWeight: _fontWeightFromString(json['fontWeight'] ?? 'normal'),
      fontStyle: _fontStyleFromString(json['fontStyle'] ?? 'normal'),
    );
  }

  static Map<String, dynamic> _textStyleToJson(TextStyle style) {
    return {
      'fontSize': style.fontSize,
      'color': style.color?.value ?? 0xFF000000,
      'fontFamily': style.fontFamily,
      'fontWeight': _fontWeightToString(style.fontWeight),
      'fontStyle': _fontStyleToString(style.fontStyle),
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Colors.black;

    if (colorValue is int) {
      return Color(colorValue);
    }

    if (colorValue is String) {
      String hexColor = colorValue.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      int? colorInt = int.tryParse(hexColor, radix: 16);
      if (colorInt != null) {
        return Color(colorInt);
      }
    }

    return Colors.black;
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static FontWeight _fontWeightFromString(String weight) {
    switch (weight.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w300':
        return FontWeight.w300;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      default:
        return FontWeight.normal;
    }
  }

  static String _fontWeightToString(FontWeight? weight) {
    if (weight == FontWeight.bold) return 'bold';
    if (weight == FontWeight.w300) return 'w300';
    if (weight == FontWeight.w600) return 'w600';
    if (weight == FontWeight.w700) return 'w700';
    return 'normal';
  }

  static FontStyle _fontStyleFromString(String style) {
    return style.toLowerCase() == 'italic'
        ? FontStyle.italic
        : FontStyle.normal;
  }

  static String _fontStyleToString(FontStyle? style) {
    return style == FontStyle.italic ? 'italic' : 'normal';
  }
}

class TextVisibility {
  String name;
  String email;
  String mobile;
  String title;
  String description;
  String tags;

  TextVisibility({
    required this.name,
    required this.email,
    required this.mobile,
    required this.title,
    required this.description,
    required this.tags,
  });

  factory TextVisibility.fromJson(Map<String, dynamic> json) {
    return TextVisibility(
      name: json['name'] ?? 'visible',
      email: json['email'] ?? 'visible',
      mobile: json['mobile'] ?? 'visible',
      title: json['title'] ?? 'visible',
      description: json['description'] ?? 'visible',
      tags: json['tags'] ?? 'visible',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'title': title,
      'description': description,
      'tags': tags,
    };
  }

  bool isVisible(String field) {
    switch (field) {
      case 'name':
        return name == 'visible';
      case 'email':
        return email == 'visible';
      case 'mobile':
        return mobile == 'visible';
      case 'title':
        return title == 'visible';
      case 'description':
        return description == 'visible';
      case 'tags':
        return tags == 'visible';
      default:
        return true;
    }
  }
}

class OverlayImageFilter {
  double brightness;
  double contrast;
  double saturation;
  double grayscale;
  double blur;

  OverlayImageFilter({
    this.brightness = 100,
    this.contrast = 100,
    this.saturation = 100,
    this.grayscale = 0,
    this.blur = 0,
  });

  factory OverlayImageFilter.fromJson(Map<String, dynamic> json) {
    return OverlayImageFilter(
      brightness: _parseDouble(json['brightness'], 100),
      contrast: _parseDouble(json['contrast'], 100),
      saturation: _parseDouble(json['saturation'], 100),
      grayscale: _parseDouble(json['grayscale'], 0),
      blur: _parseDouble(json['blur'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'grayscale': grayscale,
      'blur': blur,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class TextElement {
  String id;
  String text;
  double x;
  double y;
  double width;
  double height;
  double fontSize;
  Color color;
  FontWeight fontWeight;
  String fontFamily;
  TextAlign textAlign;
  bool isSelected;
  double rotation;

  TextElement({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    this.width = 200,
    this.height = 50,
    this.fontSize = 16,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Roboto',
    this.textAlign = TextAlign.left,
    this.isSelected = false,
    this.rotation = 0,
  });

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      x: _parseDouble(json['x'], 0),
      y: _parseDouble(json['y'], 0),
      width: _parseDouble(json['width'], 200),
      height: _parseDouble(json['height'], 50),
      fontSize: _parseDouble(json['fontSize'], 16),
      color: _parseColor(json['color']),
      fontWeight: _fontWeightFromString(json['fontWeight'] ?? 'normal'),
      fontFamily: json['fontFamily'] ?? 'Roboto',
      textAlign: _textAlignFromString(json['textAlign'] ?? 'left'),
      rotation: _parseDouble(json['rotation'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'fontSize': fontSize,
      'color': color.value,
      'fontWeight': _fontWeightToString(fontWeight),
      'fontFamily': fontFamily,
      'textAlign': _textAlignToString(textAlign),
      'rotation': rotation,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return Colors.black;

    if (colorValue is int) {
      return Color(colorValue);
    }

    if (colorValue is String) {
      String hexColor = colorValue.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      int? colorInt = int.tryParse(hexColor, radix: 16);
      if (colorInt != null) {
        return Color(colorInt);
      }
    }

    return Colors.black;
  }

  static FontWeight _fontWeightFromString(String weight) {
    switch (weight.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w300':
        return FontWeight.w300;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      default:
        return FontWeight.normal;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.bold) return 'bold';
    if (weight == FontWeight.w300) return 'w300';
    if (weight == FontWeight.w600) return 'w600';
    if (weight == FontWeight.w700) return 'w700';
    return 'normal';
  }

  static TextAlign _textAlignFromString(String align) {
    switch (align.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  static String _textAlignToString(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      default:
        return 'left';
    }
  }
}

class ImageElement {
  String id;
  String imageUrl;
  double x;
  double y;
  double width;
  double height;
  bool isSelected;
  double rotation;

  ImageElement({
    required this.id,
    required this.imageUrl,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 100,
    this.isSelected = false,
    this.rotation = 0,
  });

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      x: _parseDouble(json['x'], 0),
      y: _parseDouble(json['y'], 0),
      width: _parseDouble(json['width'], 100),
      height: _parseDouble(json['height'], 100),
      rotation: _parseDouble(json['rotation'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class ProfileElement {
  String id;
  String imageUrl;
  double x;
  double y;
  double width;
  double height;
  bool isSelected;
  double rotation;

  ProfileElement({
    required this.id,
    required this.imageUrl,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 100,
    this.isSelected = false,
    this.rotation = 0,
  });

  factory ProfileElement.fromJson(Map<String, dynamic> json) {
    return ProfileElement(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      x: _parseDouble(0, 0),
      y: _parseDouble(0, 0),
      width: _parseDouble(300, 100),
      height: _parseDouble(json['height'], 100),
      rotation: _parseDouble(json['rotation'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
    };
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class SamplePosterScreen extends StatefulWidget {
  final String posterId;

  const SamplePosterScreen({super.key, required this.posterId});

  @override
  State<SamplePosterScreen> createState() => _ApiPosterEditorState();
}

class _ApiPosterEditorState extends State<SamplePosterScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  PosterTemplate? _template;
  bool _isLoading = true;
  TextElement? _selectedTextElement;
  ImageElement? _selectedImageElement;
  ProfileElement? _selectedProfileImageElement;
  bool _showToolbar = false;
  String? _errorMessage;
  double _scaleFactor = 1.0;
  Size _canvasSize = Size.zero;
  String? phoneNumber;
  String? email;
  String? profileImage;
  Uint8List? _logoImage;
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();
  double _currentScale = 1.0;
  Offset _currentOffset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _normalizedOffset = Offset.zero;

  Offset _focusPoint = Offset.zero;
  double _previousScale = 1.0;

  // For pinch zoom and pan handling
  double _baseScale = 1.0;
  double _currentBaseScale = 1.0;
  Offset? _initialFocalPoint;

  // Persistent image elements for profile and logo
  ProfileElement? _profileImageElement;
  ImageElement? _logoImageElement;

  // final List<String> _fontFamilies = [
  //   'Roboto',
  //   'Arial',
  //   'Times New Roman',
  //   'Helvetica',
  //   'Comic Sans MS',
  //   'Verdana',
  //   'Courier New',
  //   'Georgia',
  //   'Palatino',
  //   'Garamond',
  // ];

  final List<String> _fontFamilies = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Helvetica',
    'Comic Sans MS',
    'Verdana',
    'Courier New',
    'Georgia',
    'Palatino',
    'Garamond',
    'Tahoma',
    'Trebuchet MS',
    'Lucida Sans',
    'Lucida Console',
    'Segoe UI',
    'Calibri',
    'Optima',
    'Candara',
    'Futura',
    'Franklin Gothic Medium',
    'Impact',
    'Book Antiqua',
  ];

  // final List<FontWeight> _fontWeights = [
  //   FontWeight.w300,
  //   FontWeight.normal,
  //   FontWeight.w600,
  //   FontWeight.bold, // This is the same as FontWeight.w700
  //   FontWeight.w900,
  // ];

  final List<FontWeight> _fontWeights = [
    FontWeight.w100, // Thin
    FontWeight.w200, // Extra Light
    FontWeight.w300, // Light
    FontWeight.w400, // Normal / Regular
    FontWeight.w500, // Medium
    FontWeight.w600, // Semi Bold
    FontWeight.w700, // Bold
    FontWeight.w800, // Extra Bold
    FontWeight.w900, // Black / Heavy
  ];

  final List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.indigo,
    Colors.teal,
    Colors.amber,
    Colors.deepOrange,
    Colors.cyan,
    Colors.lime,
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    _loadPosterFromApi();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthPreferences.getUserData();
    if (userData != null) {
      setState(() {
        phoneNumber = userData.user.mobile ?? phoneNumber;
        profileImage = userData.user.profileImage;
        email = userData.user.email ?? email;
      });

      if (profileImage != null && profileImage!.isNotEmpty) {
        _loadProfileImage();
      }

      if (_template != null) {
        _updateTextElementsWithUserData();
      }
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final response = await http.get(Uri.parse(profileImage!));
      if (response.statusCode == 200) {
        setState(() {
          _profileImageBytes = response.bodyBytes;
          // Create persistent profile image element
          _profileImageElement = ProfileElement(
            id: 'profile_image',
            imageUrl: '',
            x: 10,
            y: 10,
            width: 200,
            height: 200,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
  }

  void _updateTextElementsWithUserData() {
    if (_template == null) return;

    setState(() {
      for (var element in _template!.textElements) {
        switch (element.id) {
          case 'email':
            if (email != null && email!.isNotEmpty) {
              element.text = email!;
            }
            break;
          case 'mobile':
            if (phoneNumber != null && phoneNumber!.isNotEmpty) {
              element.text = phoneNumber!;
            }
            break;
        }
      }
    });
  }

  void _calculateScaleFactor(Size screenSize) {
    if (_template == null) return;

    final availableHeight = screenSize.height - 200;
    final availableWidth = screenSize.width - 32;

    final scaleX = availableWidth / _template!.width;
    final scaleY = availableHeight / _template!.height;

    _scaleFactor = scaleX < scaleY ? scaleX : scaleY;

    if (_scaleFactor < 0.3) _scaleFactor = 0.3;
    if (_scaleFactor > 1.5) _scaleFactor = 1.5;

    _canvasSize = Size(
      _template!.width * _scaleFactor,
      _template!.height * _scaleFactor,
    );
  }

  Future<void> _loadPosterFromApi() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(
          'http://194.164.148.244:4061/api/poster/singlecanvasposters/${widget.posterId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final apiResponse = json.decode(response.body) as Map<String, dynamic>;
        final template = PosterTemplate.fromApiResponse(apiResponse);

        setState(() {
          _template = template;
          _isLoading = false;
        });

        _updateTextElementsWithUserData();
      } else {
        throw Exception('Failed to load poster: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading poster from API: $e");
      debugPrint("Stack trace: $stackTrace");
      setState(() {
        _errorMessage = "Failed to load poster: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _pickLogoImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _logoImage = bytes;
          // Create persistent logo image element
          _logoImageElement = ImageElement(
            id: 'logo_image',
            imageUrl: '',
            x: _template != null ? _template!.width - 120 : 20,
            y: 20,
            width: 100,
            height: 100,
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking logo image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickAdditionalImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final tempDir = await getTemporaryDirectory();
        final file = File(
            '${tempDir.path}/additional_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);

        setState(() {
          _template?.imageElements.add(
            ImageElement(
              id: 'additional_${DateTime.now().millisecondsSinceEpoch}',
              imageUrl: file.path,
              x: _template!.width / 2 - 100,
              y: _template!.height / 2 - 100,
              width: 200,
              height: 200,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking additional image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _selectTextElement(TextElement element) {
    setState(() {
      for (var el in _template!.textElements) {
        el.isSelected = false;
      }
      for (var el in _template!.imageElements) {
        el.isSelected = false;
      }
      if (_profileImageElement != null)
        _profileImageElement!.isSelected = false;
      if (_logoImageElement != null) _logoImageElement!.isSelected = false;

      element.isSelected = true;
      _selectedTextElement = element;
      _selectedImageElement = null;
      _showToolbar = true;
    });
  }

  void _selectImageElement(ImageElement element) {
    setState(() {
      for (var el in _template!.textElements) {
        el.isSelected = false;
      }
      for (var el in _template!.imageElements) {
        el.isSelected = false;
      }
      if (_profileImageElement != null)
        _profileImageElement!.isSelected = false;
      if (_logoImageElement != null) _logoImageElement!.isSelected = false;

      element.isSelected = true;
      _selectedImageElement = element;
      _selectedTextElement = null;
      _showToolbar = true;
    });
  }

  // void _selectProfileImageElement(ProfileElement element) {
  //   setState(() {
  //     for (var el in _template!.textElements) {
  //       el.isSelected = false;
  //     }
  //     for (var el in _template!.imageElements) {
  //       el.isSelected = false;
  //     }
  //     if (_profileImageElement != null)
  //       _profileImageElement!.isSelected = false;
  //     if (_logoImageElement != null) _logoImageElement!.isSelected = false;

  //     element.isSelected = true;
  //     _selectedProfileImageElement = element;
  //     _selectedTextElement = null;
  //     _showToolbar = true;
  //   });
  // }

  void _selectProfileImageElement(ProfileElement element) {
    setState(() {
      // Deselect all other elements
      for (var el in _template!.textElements) {
        el.isSelected = false;
      }
      for (var el in _template!.imageElements) {
        el.isSelected = false;
      }
      if (_logoImageElement != null) _logoImageElement!.isSelected = false;

      // Select the profile image
      element.isSelected = true;
      _selectedProfileImageElement = element;
      _selectedTextElement = null;
      _selectedImageElement = null;
      _showToolbar = true;
    });
  }

  void _updateImageElementPosition(ImageElement element, Offset delta) {
    setState(() {
      final scaledDelta = delta / _scaleFactor;
      element.x += scaledDelta.dx;
      element.y += scaledDelta.dy;
      element.x = element.x.clamp(0, _template!.width - element.width);
      element.y = element.y.clamp(0, _template!.height - element.height);
    });
  }

  void _updateProfileImageElementPosition(
      ProfileElement element, Offset delta) {
    setState(() {
      final scaledDelta = delta / _scaleFactor;
      element.x += scaledDelta.dx;
      element.y += scaledDelta.dy;
      element.x = element.x.clamp(0, _template!.width - element.width);
      element.y = element.y.clamp(0, _template!.height - element.height);
    });
  }

  void _updateImageElementSize(ImageElement element, double scale) {
    setState(() {
      final newWidth = (_baseScale * scale).clamp(50.0, _template!.width * 0.8);
      final newHeight =
          (_baseScale * scale).clamp(50.0, _template!.height * 0.8);

      element.width = newWidth;
      element.height = newHeight;
    });
  }

  void _updateProfileImageElementSize(ProfileElement element, double scale) {
    setState(() {
      final newWidth = (_baseScale * scale).clamp(50.0, _template!.width * 0.8);
      final newHeight =
          (_baseScale * scale).clamp(50.0, _template!.height * 0.8);

      element.width = newWidth;
      element.height = newHeight;
    });
  }

  void _zoomImageElement(ImageElement element, double scaleFactor) {
    setState(() {
      final newWidth =
          (element.width * scaleFactor).clamp(20.0, _template!.width * 0.9);
      final newHeight =
          (element.height * scaleFactor).clamp(20.0, _template!.height * 0.9);

      // Calculate center point to maintain position during zoom
      final centerX = element.x + element.width / 2;
      final centerY = element.y + element.height / 2;

      element.width = newWidth;
      element.height = newHeight;

      // Reposition to maintain center
      element.x =
          (centerX - newWidth / 2).clamp(0, _template!.width - newWidth);
      element.y =
          (centerY - newHeight / 2).clamp(0, _template!.height - newHeight);
    });
  }

  // void _deselectAll() {
  //   setState(() {
  //     if (_template != null) {
  //       for (var el in _template!.textElements) {
  //         el.isSelected = false;
  //       }
  //       for (var el in _template!.imageElements) {
  //         el.isSelected = false;
  //       }
  //     }
  //     if (_profileImageElement != null)
  //       _profileImageElement!.isSelected = false;
  //     if (_logoImageElement != null) _logoImageElement!.isSelected = false;

  //     _selectedTextElement = null;
  //     _selectedImageElement = null;
  //     _showToolbar = false;
  //   });
  // }

  void _deselectAll() {
    setState(() {
      if (_template != null) {
        for (var el in _template!.textElements) {
          el.isSelected = false;
        }
        for (var el in _template!.imageElements) {
          el.isSelected = false;
        }
      }
      if (_profileImageElement != null)
        _profileImageElement!.isSelected = false;
      if (_logoImageElement != null) _logoImageElement!.isSelected = false;

      _selectedTextElement = null;
      _selectedImageElement = null;
      _selectedProfileImageElement = null;
      _showToolbar = false;
    });
  }

  // void _updateTextElementPosition(TextElement element, Offset delta) {
  //   setState(() {
  //     final scaledDelta = delta / _scaleFactor;
  //     element.x += scaledDelta.dx;
  //     element.y += scaledDelta.dy;
  //     element.x = element.x.clamp(0, _template!.width - element.width);
  //     element.y = element.y.clamp(0, _template!.height - element.height);
  //   });
  // }

  // void _updateTextElementPosition(TextElement element, Offset delta) {
  //   setState(() {
  //     final scaledDelta = delta / _scaleFactor;
  //     element.x += scaledDelta.dx;
  //     element.y += scaledDelta.dy;
  //   });
//   // }

//   void _updateTextElementPosition(TextElement element, Offset delta) {
//   setState(() {
//     final scaledDelta = delta / _scaleFactor;
//     element.x += scaledDelta.dx;
//     element.y += scaledDelta.dy;

//     // Allow text to go beyond canvas bounds for large text
//     // But keep some minimum visibility
//     element.x = element.x.clamp(-element.width * 0.8, _template!.width);
//     element.y = element.y.clamp(-element.height * 0.8, _template!.height);
//   });
// }

  void _updateTextElementPosition(TextElement element, Offset delta) {
    setState(() {
      final scaledDelta = delta / _scaleFactor;
      element.x += scaledDelta.dx;
      element.y += scaledDelta.dy;

      // Very permissive bounds for large text elements
      element.x = element.x.clamp(
          -_template!.width * 0.5, // Allow 50% outside left
          _template!.width * 1.5 // Allow 50% outside right
          );
      element.y = element.y.clamp(
          -_template!.height * 0.5, // Allow 50% outside top
          _template!.height * 1.5 // Allow 50% outside bottom
          );
    });
  }

  void _showTextEditDialog() {
    if (_selectedTextElement == null) return;

    final controller = TextEditingController(text: _selectedTextElement!.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTextElement!.text = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNewTextElement() {
    if (_template == null) return;

    final newElement = TextElement(
      id: 'text_${DateTime.now().millisecondsSinceEpoch}',
      text: 'New Text',
      x: 350,
      y: 350,
      width: 200,
      height: 50,
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Arial',
      textAlign: TextAlign.left,
    );

    setState(() {
      _template!.textElements.add(newElement);
      _selectTextElement(newElement);
    });
  }

  // void _deleteSelectedElement() {
  //   if (_selectedTextElement != null && _template != null) {
  //     setState(() {
  //       _template!.textElements.remove(_selectedTextElement);
  //       _selectedTextElement = null;
  //       _showToolbar = false;
  //     });
  //   } else if (_selectedImageElement != null && _template != null) {
  //     setState(() {
  //       // Check if it's profile or logo image
  //       if (_selectedImageElement!.id == 'profile_image') {
  //         _profileImageElement = null;
  //         _profileImageBytes = null;
  //       } else if (_selectedImageElement!.id == 'logo_image') {
  //         _logoImageElement = null;
  //         _logoImage = null;
  //       } else {
  //         _template!.imageElements.remove(_selectedImageElement);
  //       }
  //       _selectedImageElement = null;
  //       _showToolbar = false;
  //     });

  //   }
  // }

  void _deleteSelectedElement() {
    if (_selectedTextElement != null && _template != null) {
      setState(() {
        _template!.textElements.remove(_selectedTextElement);
        _selectedTextElement = null;
        _showToolbar = false;
      });
    } else if (_selectedImageElement != null && _template != null) {
      setState(() {
        // Check if it's logo image
        if (_selectedImageElement!.id == 'logo_image') {
          _logoImageElement = null;
          _logoImage = null;
        } else {
          _template!.imageElements.remove(_selectedImageElement);
        }
        _selectedImageElement = null;
        _showToolbar = false;
      });
    } else if (_selectedProfileImageElement != null) {
      // Handle profile image deletion
      setState(() {
        _profileImageElement = null;
        _profileImageBytes = null;
        _selectedProfileImageElement = null;
        _showToolbar = false;
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image deleted'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> savePoster() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 13),
              Text('Saving poster to gallery...'),
            ],
          ),
        ),
      );

      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(
        pngBytes,
        album: 'Posters',
        name: 'poster_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poster saved to gallery successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving poster: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _sharePoster() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 12),
              Text('Preparing poster for\n sharing...'),
            ],
          ),
        ),
      );

      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/poster_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      Navigator.of(context).pop();

      await Share.shareXFiles([XFile(file.path)], text: 'Check out my poster!');
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing poster: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildProfileImage() {
    if (_profileImageBytes == null || _profileImageElement == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _profileImageElement!.x,
      top: _profileImageElement!.y,
      width: _profileImageElement!.width,
      height: _profileImageElement!.height,
      child: GestureDetector(
        onTap: () => _selectProfileImageElement(_profileImageElement!),
        onScaleStart: (details) {
          _baseScale = _profileImageElement!.width;
          _initialFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          // Handle scaling (when scale != 1.0)
          if (details.scale != 1.0) {
            _updateProfileImageElementSize(
                _profileImageElement!, details.scale);
          }

          // Handle panning (when focalPoint changes)
          if (_initialFocalPoint != null) {
            final delta = details.focalPoint - _initialFocalPoint!;
            _updateProfileImageElementPosition(_profileImageElement!, delta);
            _initialFocalPoint = details.focalPoint;
          }
        },
        onScaleEnd: (details) {
          _initialFocalPoint = null;
        },
        child: Transform.rotate(
          angle: _profileImageElement!.rotation * 3.14159 / 180,
          child: Container(
            decoration: _profileImageElement!.isSelected
                ? BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    color: Colors.green.withOpacity(0.1),
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.memory(
                _profileImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoImage() {
    if (_logoImage == null || _logoImageElement == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _logoImageElement!.x,
      top: _logoImageElement!.y,
      width: _logoImageElement!.width,
      height: _logoImageElement!.height,
      child: GestureDetector(
        onTap: () => _selectImageElement(_logoImageElement!),
        onScaleStart: (details) {
          _baseScale = _logoImageElement!.width;
          _initialFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          // Handle scaling (when scale != 1.0)
          if (details.scale != 1.0) {
            _updateImageElementSize(_logoImageElement!, details.scale);
          }

          // Handle panning (when focalPoint changes)
          if (_initialFocalPoint != null) {
            final delta = details.focalPoint - _initialFocalPoint!;
            _updateImageElementPosition(_logoImageElement!, delta);
            _initialFocalPoint = details.focalPoint;
          }
        },
        onScaleEnd: (details) {
          _initialFocalPoint = null;
        },
        child: Transform.rotate(
          angle: _logoImageElement!.rotation * 3.14159 / 180,
          child: Container(
            decoration: _logoImageElement!.isSelected
                ? BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    color: Colors.green.withOpacity(0.1),
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.memory(
                _logoImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextElement(TextElement element) {
    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        onTap: () => _selectTextElement(element),
        onPanUpdate: (details) {
          _updateTextElementPosition(element, details.delta);
        },
        child: Transform.rotate(
          angle: element.rotation * 3.14159 / 180,
          child: Container(
            // Flexible constraints that allow for very large text
            constraints: BoxConstraints(
              minWidth: 50,
              maxWidth:
                  _template!.width * 3, // Triple canvas width for large text
              minHeight: 20,
              maxHeight: _template!.height * 3, // Triple canvas height
            ),
            decoration: element.isSelected
                ? BoxDecoration(
                    // border: Border.all(color: Colors.green, width: 2),
                  )
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _template!.width * 2, // Double canvas width
                maxHeight: _template!.height * 2, // Double canvas height
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    element.text,
                    style: TextStyle(
                      fontSize: element.fontSize,
                      color: element.color,
                      fontWeight: element.fontWeight,
                      fontFamily: element.fontFamily,
                      height: 1.2, // Better line spacing for large text
                    ),
                    textAlign: element.textAlign,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Widget _buildTextElement(TextElement element) {
//   return Positioned(
//     left: element.x,
//     top: element.y,
//     child: GestureDetector(
//       onTap: () => _selectTextElement(element),
//       onPanUpdate: (details) {
//         _updateTextElementPosition(element, details.delta);
//       },
//       child: Transform.rotate(
//         angle: element.rotation * 3.14159 / 180,
//         child: Container(
//           // Remove fixed width/height constraints
//           constraints: BoxConstraints(
//             minWidth: 50,
//             maxWidth: _template!.width * 2, // Allow text to be very wide
//             minHeight: 20,
//             maxHeight: _template!.height * 2, // Allow text to be very tall
//           ),
//           decoration: element.isSelected
//               ? BoxDecoration(
//                   // border: Border.all(color: const ui.Color.fromARGB(255, 33, 243, 100), width: 2),
//                   // color: Colors.blue.withOpacity(0.1),
//                 )
//               : null,
//           child: element.text.isNotEmpty
//               ? IntrinsicWidth(
//                   child: IntrinsicHeight(
//                     child: Container(
//                       width: element.width,
//                       height: element.height,
//                       child: Text(
//                         element.text,
//                         style: TextStyle(
//                           fontSize: element.fontSize,
//                           color: element.color,
//                           fontWeight: element.fontWeight,
//                           fontFamily: element.fontFamily,
//                         ),
//                         textAlign: element.textAlign,
//                         maxLines: null, // Allow unlimited lines
//                         overflow: TextOverflow.visible, // Show all text
//                         softWrap: true, // Allow text wrapping
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(
//                   width: element.width,
//                   height: element.height,
//                   decoration: BoxDecoration(
//                     // border: Border.all(
//                     //   color: Colors.grey.shade400,
//                     //   style: BorderStyle.solid,
//                     // ),
//                   ),
//                   // child: const Center(
//                   //   child: Text(
//                   //     'Empty Text',
//                   //     style: TextStyle(color: Colors.grey, fontSize: 12),
//                   //   ),
//                   // ),
//                 ),
//         ),
//       ),
//     ),
//   );
// }

  // Widget _buildTextElement(TextElement element) {
  //   return Positioned(
  //     left: element.x,
  //     top: element.y,
  //     width: element.width,
  //     height: element.height,
  //     child: GestureDetector(
  //       onTap: () => _selectTextElement(element),
  //       onPanUpdate: (details) {
  //         _updateTextElementPosition(element, details.delta);
  //       },
  //       child: Transform.rotate(
  //         angle: element.rotation * 3.14159 / 180,
  //         child: Container(
  //           decoration: element.isSelected
  //               ? BoxDecoration(
  //                   // border: Border.all(),
  //                   // color: Colors.blue.withOpacity(0.1),
  //                   )
  //               : null,
  //           child: element.text.isNotEmpty
  //               ? FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   alignment: _getAlignment(element.textAlign),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(4.0),
  //                     child: Text(
  //                       element.text,
  //                       style: TextStyle(
  //                         fontSize: element.fontSize,
  //                         color: element.color,
  //                         fontWeight: element.fontWeight,
  //                         fontFamily: element.fontFamily,
  //                       ),
  //                       textAlign: element.textAlign,
  //                       maxLines: null,
  //                       overflow: TextOverflow.visible,
  //                     ),
  //                   ),
  //                 )
  //               : Container(
  //                   decoration: BoxDecoration(
  //                     // border: Border.all(
  //                     //   color: Colors.grey.shade400,
  //                     //   style: BorderStyle.solid,
  //                     // ),
  //                   ),
  //                   // child: const Center(
  //                   //   child: Text(
  //                   //     'Empty Text',
  //                   //     style: TextStyle(color: Colors.grey, fontSize: 12),
  //                   //   ),
  //                   // ),
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildImageElement(ImageElement element) {
    return Positioned(
      left: element.x,
      top: element.y,
      width: element.width,
      height: element.height,
      child: GestureDetector(
        onTap: () => _selectImageElement(element),
        onScaleStart: (details) {
          _baseScale = element.width;
          _initialFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          // Handle scaling (when scale != 1.0)
          if (details.scale != 1.0) {
            _updateImageElementSize(element, details.scale);
          }

          // Handle panning (when focalPoint changes)
          if (_initialFocalPoint != null) {
            final delta = details.focalPoint - _initialFocalPoint!;
            _updateImageElementPosition(element, delta);
            _initialFocalPoint = details.focalPoint;
          }
        },
        onScaleEnd: (details) {
          _initialFocalPoint = null;
        },
        child: Transform.rotate(
          angle: element.rotation * 3.14159 / 180,
          child: Container(
            decoration: element.isSelected
                ? BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    color: Colors.green.withOpacity(0.1),
                  )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  element.id == 'logo_image' || element.id == 'profile_image'
                      ? 50
                      : 4),
              child: element.imageUrl.isNotEmpty
                  ? (element.imageUrl.startsWith('http')
                      ? Image.network(
                          element.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error,
                                        color: Colors.red, size: 24),
                                    Text(
                                      'Image Error',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(element.imageUrl),
                          fit: BoxFit.cover,
                        ))
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 24),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  // Widget _buildToolbar() {
  //   if (_selectedTextElement == null && _selectedImageElement == null) {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     color: Colors.white,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Row(
  //         children: [
  //           if (_selectedTextElement != null) ...[
  //             IconButton(
  //               icon: const Icon(Icons.edit, color: Colors.deepPurple),
  //               onPressed: _showTextEditDialog,
  //               tooltip: 'Edit Text',
  //             ),
  //             const VerticalDivider(width: 16),
  //             // Zoom Slider for Fine Control
  //             const Text('Size: ',
  //                 style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
  //             SizedBox(
  //               width: 120,
  //               child: Slider(
  //                 value: _selectedImageElement!.width,
  //                 min: 20.0,
  //                 max: _template!.width * 0.9,
  //                 divisions: 50,
  //                 label: '${_selectedImageElement!.width.round()}',
  //                 onChanged: (value) {
  //                   setState(() {
  //                     // Maintain aspect ratio
  //                     final aspectRatio = _selectedImageElement!.width /
  //                         _selectedImageElement!.height;
  //                     _selectedImageElement!.width = value;
  //                     _selectedImageElement!.height = value / aspectRatio;

  //                     // Keep within bounds
  //                     _selectedImageElement!.x = _selectedImageElement!.x.clamp(
  //                         0, _template!.width - _selectedImageElement!.width);
  //                     _selectedImageElement!.y = _selectedImageElement!.y.clamp(
  //                         0, _template!.height - _selectedImageElement!.height);
  //                   });
  //                 },
  //               ),
  //             ),
  //             const VerticalDivider(width: 16),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //               child: DropdownButtonHideUnderline(
  //                 child: DropdownButton<String>(
  //                   value: _selectedTextElement!.fontFamily,
  //                   items: _fontFamilies
  //                       .toSet()
  //                       .map(
  //                         (font) => DropdownMenuItem(
  //                           value: font,
  //                           child:
  //                               Text(font, style: TextStyle(fontFamily: font)),
  //                         ),
  //                       )
  //                       .toList(),
  //                   onChanged: (value) {
  //                     if (value != null) {
  //                       setState(() {
  //                         _selectedTextElement!.fontFamily = value;
  //                       });
  //                     }
  //                   },
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //               child: DropdownButtonHideUnderline(
  //                 child: DropdownButton<FontWeight>(
  //                   value: _selectedTextElement!.fontWeight,
  //                   items: _fontWeights
  //                       .map(
  //                         (weight) => DropdownMenuItem(
  //                           value: weight,
  //                           child: Text(
  //                             weight == FontWeight.bold
  //                                 ? 'Bold'
  //                                 : weight == FontWeight.w600
  //                                     ? 'Semi-Bold'
  //                                     : weight == FontWeight.w300
  //                                         ? 'Light'
  //                                         : weight == FontWeight.w900
  //                                             ? 'Black'
  //                                             : 'Normal',
  //                             style: TextStyle(fontWeight: weight),
  //                           ),
  //                         ),
  //                       )
  //                       .toList(),
  //                   onChanged: (value) {
  //                     if (value != null) {
  //                       setState(() {
  //                         _selectedTextElement!.fontWeight = value;
  //                       });
  //                     }
  //                   },
  //                 ),
  //               ),
  //             ),
  //             const VerticalDivider(width: 16),
  //             Row(
  //               children: [
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.format_align_left,
  //                     color: _selectedTextElement!.textAlign == TextAlign.left
  //                         ? Colors.deepPurple
  //                         : Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       _selectedTextElement!.textAlign = TextAlign.left;
  //                     });
  //                   },
  //                   tooltip: 'Align Left',
  //                 ),
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.format_align_center,
  //                     color: _selectedTextElement!.textAlign == TextAlign.center
  //                         ? Colors.deepPurple
  //                         : Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       _selectedTextElement!.textAlign = TextAlign.center;
  //                     });
  //                   },
  //                   tooltip: 'Align Center',
  //                 ),
  //                 IconButton(
  //                   icon: Icon(
  //                     Icons.format_align_right,
  //                     color: _selectedTextElement!.textAlign == TextAlign.right
  //                         ? Colors.deepPurple
  //                         : Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       _selectedTextElement!.textAlign = TextAlign.right;
  //                     });
  //                   },
  //                   tooltip: 'Align Right',
  //                 ),
  //               ],
  //             ),
  //             const VerticalDivider(width: 16),
  //             const Text(
  //               'Color: ',
  //               style: TextStyle(fontWeight: FontWeight.w500),
  //             ),
  //             ..._colors.map(
  //               (color) => GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     _selectedTextElement!.color = color;
  //                   });
  //                 },
  //                 child: Container(
  //                   margin: const EdgeInsets.symmetric(horizontal: 2),
  //                   width: 28,
  //                   height: 28,
  //                   decoration: BoxDecoration(
  //                     color: color,
  //                     border: Border.all(
  //                       color: _selectedTextElement!.color == color
  //                           ? Colors.deepPurple
  //                           : Colors.grey,
  //                       width: _selectedTextElement!.color == color ? 3 : 1,
  //                     ),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ] else if (_selectedImageElement != null) ...[
  //             // Zoom Out Button
  //             IconButton(
  //               icon: const Icon(Icons.zoom_out, color: Colors.deepPurple),
  //               onPressed: () {
  //                 _zoomImageElement(_selectedImageElement!, 0.9); // 10% smaller
  //               },
  //               tooltip: 'Zoom Out',
  //             ),
  //             // Current Size Display
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //               child: Text(
  //                 '${(_selectedImageElement!.width).round()}×${(_selectedImageElement!.height).round()}',
  //                 style: const TextStyle(fontSize: 12),
  //               ),
  //             ),
  //             // Zoom In Button
  //             IconButton(
  //               icon: const Icon(Icons.zoom_in, color: Colors.deepPurple),
  //               onPressed: () {
  //                 _zoomImageElement(_selectedImageElement!, 1.1); // 10% larger
  //               },
  //               tooltip: 'Zoom In',
  //             ),
  //             const VerticalDivider(width: 16),
  //             // Reset Size Button
  //             IconButton(
  //               icon: const Icon(Icons.aspect_ratio, color: Colors.deepPurple),
  //               onPressed: () {
  //                 // Reset to original size based on image type
  //                 double originalSize = 200.0;
  //                 if (_selectedImageElement!.id == 'logo_image') {
  //                   originalSize = 100.0;
  //                 } else if (_selectedImageElement!.id == 'profile_image') {
  //                   originalSize = 200.0;
  //                 }

  //                 setState(() {
  //                   _selectedImageElement!.width = originalSize;
  //                   _selectedImageElement!.height = originalSize;
  //                 });
  //               },
  //               tooltip: 'Reset Size',
  //             ),
  //             const VerticalDivider(width: 16),
  //             IconButton(
  //               icon: const Icon(Icons.crop, color: Colors.deepPurple),
  //               onPressed: () {
  //                 // Show shape options
  //                 showDialog(
  //                   context: context,
  //                   builder: (context) => AlertDialog(
  //                     title: const Text('Change Image Shape'),
  //                     content: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         ListTile(
  //                           leading: const Icon(Icons.crop_square),
  //                           title: const Text('Rectangle'),
  //                           onTap: () {
  //                             setState(() {
  //                               // For simplicity, we're just changing the border radius
  //                               // In a real app, you might want to clip the image differently
  //                             });
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                         ListTile(
  //                           leading: const Icon(Icons.circle),
  //                           title: const Text('Circle'),
  //                           onTap: () {
  //                             setState(() {
  //                               // For simplicity, we're just changing the border radius
  //                               // In a real app, you might want to clip the image differently
  //                             });
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //               tooltip: 'Change Shape',
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.delete, color: Colors.red),
  //               onPressed: _deleteSelectedElement,
  //               tooltip: 'Delete Image',
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildToolbar() {
    if (_selectedTextElement == null &&
        _selectedImageElement == null &&
        _selectedProfileImageElement == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedTextElement != null) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: _showTextEditDialog,
                tooltip: 'Edit Text',
              ),
              const VerticalDivider(width: 16),
              // Font Size Slider for Text Elements
              const Text('Size: ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
              SizedBox(
                width: 150,
                child: Slider(
                  value: _selectedTextElement!.fontSize,
                  min: 8.0,
                  max: 600.0,
                  divisions: 100,
                  label: '${_selectedTextElement!.fontSize.round()}',
                  onChanged: (value) {
                    setState(() {
                      _selectedTextElement!.fontSize = value;

                      if (value > 100) {
                        final textLength = _selectedTextElement!.text.length;
                        _selectedTextElement!.width = (textLength * value * 0.5)
                            .clamp(200.0, _template!.width * 2);
                        _selectedTextElement!.height =
                            (value * 1.5).clamp(50.0, _template!.height * 2);
                      }
                      //    if (value > 100) {
                      //   _selectedTextElement!.width = (_selectedTextElement!.width).clamp(400.0, _template!.width * 1.5);
                      //   _selectedTextElement!.height = (_selectedTextElement!.height).clamp(200.0, _template!.height * 1.5);
                      // }
                    });
                  },
                ),
              ),
              const VerticalDivider(width: 16),

              IconButton(
                icon: const Icon(Icons.fit_screen, color: Colors.deepPurple),
                onPressed: () {
                  setState(() {
                    // Auto-adjust container size based on font size and text length
                    double estimatedWidth = _selectedTextElement!.text.length *
                        _selectedTextElement!.fontSize *
                        0.6;
                    double estimatedHeight =
                        _selectedTextElement!.fontSize * 1.5;

                    _selectedTextElement!.width =
                        estimatedWidth.clamp(100.0, _template!.width * 1.5);
                    _selectedTextElement!.height =
                        estimatedHeight.clamp(50.0, _template!.height * 1.5);
                  });
                },
                tooltip: 'Auto-fit Size',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTextElement!.fontFamily,
                    items: _fontFamilies
                        .toSet()
                        .map(
                          (font) => DropdownMenuItem(
                            value: font,
                            child:
                                Text(font, style: TextStyle(fontFamily: font)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTextElement!.fontFamily = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FontWeight>(
                    value: _selectedTextElement!.fontWeight,
                    items: _fontWeights
                        .map(
                          (weight) => DropdownMenuItem(
                            value: weight,
                            child: Text(
                              weight == FontWeight.bold
                                  ? 'Bold'
                                  : weight == FontWeight.w600
                                      ? 'Semi-Bold'
                                      : weight == FontWeight.w300
                                          ? 'Light'
                                          : weight == FontWeight.w900
                                              ? 'Black'
                                              : 'Normal',
                              style: TextStyle(fontWeight: weight),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTextElement!.fontWeight = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const VerticalDivider(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.format_align_left,
                      color: _selectedTextElement!.textAlign == TextAlign.left
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTextElement!.textAlign = TextAlign.left;
                      });
                    },
                    tooltip: 'Align Left',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.format_align_center,
                      color: _selectedTextElement!.textAlign == TextAlign.center
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTextElement!.textAlign = TextAlign.center;
                      });
                    },
                    tooltip: 'Align Center',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.format_align_right,
                      color: _selectedTextElement!.textAlign == TextAlign.right
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTextElement!.textAlign = TextAlign.right;
                      });
                    },
                    tooltip: 'Align Right',
                  ),
                ],
              ),
              const VerticalDivider(width: 16),
              const Text(
                'Color: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              ..._colors.map(
                (color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTextElement!.color = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: _selectedTextElement!.color == color
                            ? Colors.deepPurple
                            : Colors.grey,
                        width: _selectedTextElement!.color == color ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Delete button for text elements
              const VerticalDivider(width: 16),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedElement,
                tooltip: 'Delete Text',
              ),
            ] else if (_selectedImageElement != null) ...[
              // IconButton(
              //   icon: const Icon(Icons.zoom_out, color: Colors.deepPurple),
              //   onPressed: () {
              //     _zoomImageElement(_selectedImageElement!, 0.9);
              //   },
              //   tooltip: 'Zoom Out',
              // ),

              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey.shade300),
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              //   child: Text(
              //     '${(_selectedImageElement!.width).round()}×${(_selectedImageElement!.height).round()}',
              //     style: const TextStyle(fontSize: 12),
              //   ),
              // ),
              // Zoom In Button
              // IconButton(
              //   icon: const Icon(Icons.zoom_in, color: Colors.deepPurple),
              //   onPressed: () {
              //     _zoomImageElement(_selectedImageElement!, 1.1); // 10% larger
              //   },
              //   tooltip: 'Zoom In',
              // ),
              // const VerticalDivider(width: 16),
              // Size Slider for Image Elements
              const Text('Size: ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
              SizedBox(
                width: 120,
                child: Slider(
                  value: _selectedImageElement!.width,
                  min: 20.0,
                  max: _template!.width * 0.9,
                  divisions: 50,
                  label: '${_selectedImageElement!.width.round()}',
                  onChanged: (value) {
                    setState(() {
                      // Maintain aspect ratio
                      final aspectRatio = _selectedImageElement!.width /
                          _selectedImageElement!.height;
                      _selectedImageElement!.width = value;
                      _selectedImageElement!.height = value / aspectRatio;

                      // Keep within bounds
                      _selectedImageElement!.x = _selectedImageElement!.x.clamp(
                          0, _template!.width - _selectedImageElement!.width);
                      _selectedImageElement!.y = _selectedImageElement!.y.clamp(
                          0, _template!.height - _selectedImageElement!.height);
                    });
                  },
                ),
              ),
              const VerticalDivider(width: 16),
              // Reset Size Button
              IconButton(
                icon: const Icon(Icons.aspect_ratio, color: Colors.deepPurple),
                onPressed: () {
                  // Reset to original size based on image type
                  double originalSize = 200.0;
                  if (_selectedImageElement!.id == 'logo_image') {
                    originalSize = 100.0;
                  } else if (_selectedImageElement!.id == 'profile_image') {
                    originalSize = 200.0;
                  }

                  setState(() {
                    _selectedImageElement!.width = originalSize;
                    _selectedImageElement!.height = originalSize;
                  });
                },
                tooltip: 'Reset Size',
              ),
              const VerticalDivider(width: 16),
              // IconButton(
              //   icon: const Icon(Icons.crop, color: Colors.deepPurple),
              //   onPressed: () {
              //     // Show shape options
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: const Text('Change Image Shape'),
              //         content: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             ListTile(
              //               leading: const Icon(Icons.crop_16_9), // Rectangle
              //               title: const Text('Rectangle'),
              //               onTap: () {
              //                 setState(() {

              //                 });
              //                 Navigator.pop(context);
              //               },
              //             ),
              //             ListTile(
              //               leading: const Icon(Icons.circle), // Circle
              //               title: const Text('Circle'),
              //               onTap: () {
              //                 setState(() {
              //                   // Change border radius / shape logic
              //                 });
              //                 Navigator.pop(context);
              //               },
              //             ),
              //             ListTile(
              //               leading: const Icon(Icons.crop_square), // Square
              //               title: const Text('Square'),
              //               onTap: () {
              //                 setState(() {
              //                   // Change border radius / shape logic
              //                 });
              //                 Navigator.pop(context);
              //               },
              //             ),
              //             ListTile(
              //               leading:
              //                   const Icon(Icons.change_history), // Triangle
              //               title: const Text('Triangle'),
              //               onTap: () {
              //                 setState(() {
              //                   // Change border radius / shape logic
              //                 });
              //                 Navigator.pop(context);
              //               },
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              //   tooltip: 'Change Shape',
              // ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteSelectedElement,
                tooltip: 'Delete Image',
              ),
            ] else if (_selectedProfileImageElement != null) ...[
              // Profile image specific controls
              const Text('Profile Image',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const VerticalDivider(width: 16),

              // Size controls for profile image
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.deepPurple),
                onPressed: () {
                  setState(() {
                    final newSize = (_selectedProfileImageElement!.width * 0.9)
                        .clamp(50.0, _template!.width * 0.8);
                    _selectedProfileImageElement!.width = newSize;
                    _selectedProfileImageElement!.height = newSize;
                  });
                },
                tooltip: 'Make Smaller',
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(_selectedProfileImageElement!.width).round()}×${(_selectedProfileImageElement!.height).round()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.deepPurple),
                onPressed: () {
                  setState(() {
                    final newSize = (_selectedProfileImageElement!.width * 1.1)
                        .clamp(50.0, _template!.width * 0.8);
                    _selectedProfileImageElement!.width = newSize;
                    _selectedProfileImageElement!.height = newSize;
                  });
                },
                tooltip: 'Make Larger',
              ),

              const VerticalDivider(width: 16),

              // Size Slider for Profile Image
              const Text('Size: ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
              SizedBox(
                width: 120,
                child: Slider(
                  value: _selectedProfileImageElement!.width,
                  min: 50.0,
                  max: _template!.width * 0.8,
                  divisions: 50,
                  label: '${_selectedProfileImageElement!.width.round()}',
                  onChanged: (value) {
                    setState(() {
                      _selectedProfileImageElement!.width = value;
                      _selectedProfileImageElement!.height =
                          value; // Keep it square

                      // Keep within bounds
                      _selectedProfileImageElement!.x =
                          _selectedProfileImageElement!.x.clamp(
                              0,
                              _template!.width -
                                  _selectedProfileImageElement!.width);
                      _selectedProfileImageElement!.y =
                          _selectedProfileImageElement!.y.clamp(
                              0,
                              _template!.height -
                                  _selectedProfileImageElement!.height);
                    });
                  },
                ),
              ),

              const VerticalDivider(width: 16),

              // Replace profile image button
              IconButton(
                icon: const Icon(Icons.photo_camera, color: Colors.deepPurple),
                onPressed: () async {
                  try {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        _profileImageBytes = bytes;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile image updated!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating profile image: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                tooltip: 'Replace Profile Image',
              ),

              // Delete profile image button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Show confirmation dialog for profile image deletion
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Profile Image'),
                      content: const Text(
                          'Are you sure you want to delete the profile image?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteSelectedElement();
                          },
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Delete Profile Image',
              ),
            ],
          ],
        ),
      ),
    );
  }

//   Widget _buildToolbar() {
//   if (_selectedTextElement == null && _selectedImageElement == null) {
//     return const SizedBox.shrink();
//   }

//   return Container(
//     padding: const EdgeInsets.all(8),
//     color: Colors.white,
//     child: SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           if (_selectedTextElement != null) ...[
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.deepPurple),
//               onPressed: _showTextEditDialog,
//               tooltip: 'Edit Text',
//             ),
//             const VerticalDivider(width: 16),
//             // Font Size Slider for Text Elements
//             const Text('Size: ',
//                 style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
//             SizedBox(
//               width: 120,
//               child: Slider(
//                 value: _selectedTextElement!.fontSize,
//                 min: 8.0,
//                 max: 72.0,
//                 divisions: 50,
//                 label: '${_selectedTextElement!.fontSize.round()}',
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedTextElement!.fontSize = value;
//                   });
//                 },
//               ),
//             ),
//             const VerticalDivider(width: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedTextElement!.fontFamily,
//                   items: _fontFamilies
//                       .toSet()
//                       .map(
//                         (font) => DropdownMenuItem(
//                           value: font,
//                           child:
//                               Text(font, style: TextStyle(fontFamily: font)),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         _selectedTextElement!.fontFamily = value;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<FontWeight>(
//                   value: _selectedTextElement!.fontWeight,
//                   items: _fontWeights
//                       .map(
//                         (weight) => DropdownMenuItem(
//                           value: weight,
//                           child: Text(
//                             weight == FontWeight.bold
//                                 ? 'Bold'
//                                 : weight == FontWeight.w600
//                                     ? 'Semi-Bold'
//                                     : weight == FontWeight.w300
//                                         ? 'Light'
//                                         : weight == FontWeight.w900
//                                             ? 'Black'
//                                             : 'Normal',
//                             style: TextStyle(fontWeight: weight),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         _selectedTextElement!.fontWeight = value;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),
//             const VerticalDivider(width: 16),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.format_align_left,
//                     color: _selectedTextElement!.textAlign == TextAlign.left
//                         ? Colors.deepPurple
//                         : Colors.grey,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _selectedTextElement!.textAlign = TextAlign.left;
//                     });
//                   },
//                   tooltip: 'Align Left',
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.format_align_center,
//                     color: _selectedTextElement!.textAlign == TextAlign.center
//                         ? Colors.deepPurple
//                         : Colors.grey,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _selectedTextElement!.textAlign = TextAlign.center;
//                     });
//                   },
//                   tooltip: 'Align Center',
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.format_align_right,
//                     color: _selectedTextElement!.textAlign == TextAlign.right
//                         ? Colors.deepPurple
//                         : Colors.grey,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _selectedTextElement!.textAlign = TextAlign.right;
//                     });
//                   },
//                   tooltip: 'Align Right',
//                 ),
//               ],
//             ),
//             const VerticalDivider(width: 16),
//             const Text(
//               'Color: ',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             ..._colors.map(
//               (color) => GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedTextElement!.color = color;
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: color,
//                     border: Border.all(
//                       color: _selectedTextElement!.color == color
//                           ? Colors.deepPurple
//                           : Colors.grey,
//                       width: _selectedTextElement!.color == color ? 3 : 1,
//                     ),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//           ] else if (_selectedImageElement != null) ...[
//             // Zoom Out Button
//             IconButton(
//               icon: const Icon(Icons.zoom_out, color: Colors.deepPurple),
//               onPressed: () {
//                 _zoomImageElement(_selectedImageElement!, 0.9); // 10% smaller
//               },
//               tooltip: 'Zoom Out',
//             ),
//             // Current Size Display
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '${(_selectedImageElement!.width).round()}×${(_selectedImageElement!.height).round()}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),
//             // Zoom In Button
//             IconButton(
//               icon: const Icon(Icons.zoom_in, color: Colors.deepPurple),
//               onPressed: () {
//                 _zoomImageElement(_selectedImageElement!, 1.1); // 10% larger
//               },
//               tooltip: 'Zoom In',
//             ),
//             const VerticalDivider(width: 16),
//             // Size Slider for Image Elements
//             const Text('Size: ',
//                 style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
//             SizedBox(
//               width: 120,
//               child: Slider(
//                 value: _selectedImageElement!.width,
//                 min: 20.0,
//                 max: _template!.width * 0.9,
//                 divisions: 50,
//                 label: '${_selectedImageElement!.width.round()}',
//                 onChanged: (value) {
//                   setState(() {
//                     // Maintain aspect ratio
//                     final aspectRatio = _selectedImageElement!.width /
//                         _selectedImageElement!.height;
//                     _selectedImageElement!.width = value;
//                     _selectedImageElement!.height = value / aspectRatio;

//                     // Keep within bounds
//                     _selectedImageElement!.x = _selectedImageElement!.x.clamp(
//                         0, _template!.width - _selectedImageElement!.width);
//                     _selectedImageElement!.y = _selectedImageElement!.y.clamp(
//                         0, _template!.height - _selectedImageElement!.height);
//                   });
//                 },
//               ),
//             ),
//             const VerticalDivider(width: 16),
//             // Reset Size Button
//             IconButton(
//               icon: const Icon(Icons.aspect_ratio, color: Colors.deepPurple),
//               onPressed: () {
//                 // Reset to original size based on image type
//                 double originalSize = 200.0;
//                 if (_selectedImageElement!.id == 'logo_image') {
//                   originalSize = 100.0;
//                 } else if (_selectedImageElement!.id == 'profile_image') {
//                   originalSize = 200.0;
//                 }

//                 setState(() {
//                   _selectedImageElement!.width = originalSize;
//                   _selectedImageElement!.height = originalSize;
//                 });
//               },
//               tooltip: 'Reset Size',
//             ),
//             const VerticalDivider(width: 16),
//             IconButton(
//               icon: const Icon(Icons.crop, color: Colors.deepPurple),
//               onPressed: () {
//                 // Show shape options
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Change Image Shape'),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.crop_square),
//                           title: const Text('Rectangle'),
//                           onTap: () {
//                             setState(() {
//                               // For simplicity, we're just changing the border radius
//                               // In a real app, you might want to clip the image differently
//                             });
//                             Navigator.pop(context);
//                           },
//                         ),
//                         ListTile(
//                           leading: const Icon(Icons.circle),
//                           title: const Text('Circle'),
//                           onTap: () {
//                             setState(() {
//                               // For simplicity, we're just changing the border radius
//                               // In a real app, you might want to clip the image differently
//                             });
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//               tooltip: 'Change Shape',
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: _deleteSelectedElement,
//               tooltip: 'Delete Image',
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_template != null && _scaleFactor == 1.0) {
      _calculateScaleFactor(screenSize);
    }

    return Scaffold(
      appBar: // In your build method, in the AppBar actions section, update this:

          AppBar(
            leading: IconButton(onPressed: (){
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
        // title: Text(_template?.name ?? 'Poster Editor'),
        // backgroundColor: const ui.Color.fromARGB(255, 58, 183, 85),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields,color: Colors.black,),
            onPressed: _addNewTextElement,
            tooltip: 'Add Text',
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate,color: Colors.black,),
            onPressed: _pickAdditionalImage,
            tooltip: 'Add Image',
          ),
          TextButton(
            onPressed: _pickLogoImage,
            child: const Text(
              "Logo",
              style: TextStyle(color: Colors.black),
            ),
          ),
          // CHANGE THIS CONDITION:
          if (_selectedTextElement != null ||
              _selectedImageElement != null ||
              _selectedProfileImageElement != null) // <- ADD THIS LINE
            IconButton(
              icon: const Icon(Icons.delete_outline,color: Colors.red,),
              onPressed: _deleteSelectedElement,
              tooltip: 'Delete Selected',
            ),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: _loadPosterFromApi,
          //   tooltip: 'Reload Poster',
          // ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert,color: Colors.black,),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text('Save Poster'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text('Share Poster'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'image') {
                savePoster();
              } else if (value == 'share') {
                _sharePoster();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading poster...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPosterFromApi,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _template == null
                  ? const Center(child: Text("No poster data available"))
                  : Column(
                      children: [
                        if (_showToolbar &&
                            (_selectedTextElement != null ||
                                _selectedImageElement != null))
                          _buildToolbar(),
                        Expanded(
                          child: GestureDetector(
                            onScaleStart: (details) {
                              _focusPoint = details.focalPoint;
                              _previousScale = _currentScale;
                              _startOffset = _currentOffset;

                              // _startOffset = details.focalPoint;
                              // _currentBaseScale = _currentScale;
                              // _normalizedOffset = _currentOffset;
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                _currentScale = (_previousScale * details.scale)
                                    .clamp(0.5, 3.0);

                                final focalPointInOriginal =
                                    (_focusPoint - _startOffset) /
                                        _previousScale;

                                // Calculate where that point should be after scaling
                                final focalPointAfterScale =
                                    focalPointInOriginal * _currentScale;

                                // Adjust the offset so the focal point stays under the user's fingers
                                _currentOffset =
                                    _focusPoint - focalPointAfterScale;
                                // _currentScale =
                                //     (_currentBaseScale * details.scale)
                                //         .clamp(0.5, 3.0);

                                // Calculate new offset based on pinch center
                                // final Offset offsetDelta =
                                //     (details.focalPoint - _startOffset) /
                                //         _currentScale;
                                // _currentOffset =
                                //     _normalizedOffset + offsetDelta;
                              });
                            },
                            onScaleEnd: (details) {
                              _previousScale = _currentScale;
                              // _normalizedOffset = _currentOffset;
                            },
                            onTap: _deselectAll,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..translate(
                                    _currentOffset.dx, _currentOffset.dy)
                                ..scale(_currentScale),
                              child: Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: RepaintBoundary(
                                      key: _canvasKey,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Container(
                                            width: _template!.width,
                                            height: _template!.height,
                                            decoration: BoxDecoration(
                                              color: _template!.backgroundColor,
                                              // border: Border.all(
                                              //     color: Colors.grey.shade300),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.hardEdge,
                                              children: [
                                                if (_template!
                                                        .backgroundImage !=
                                                    null)
                                                  Positioned.fill(
                                                    child: Image.network(
                                                      _template!
                                                          .backgroundImage!,
                                                      fit: BoxFit.fill,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularProgressIndicator(
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                const Text(
                                                                    'Loading background...'),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          color: _template!
                                                              .backgroundColor,
                                                          child: const Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons.error,
                                                                    size: 48,
                                                                    color: Colors
                                                                        .red),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                    'Failed to load background'),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ..._template!.textElements.map(
                                                  (element) =>
                                                      _buildTextElement(
                                                          element),
                                                ),
                                                ..._template!.imageElements.map(
                                                  (element) =>
                                                      _buildImageElement(
                                                          element),
                                                ),
                                                if (_profileImageBytes !=
                                                        null &&
                                                    _profileImageElement !=
                                                        null)
                                                  _buildProfileImage(),
                                                if (_logoImage != null &&
                                                    _logoImageElement != null)
                                                  _buildLogoImage(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: Colors.grey[200],
                          child: const Row(
                            children: [
                              // IconButton(
                              //   icon: const Icon(Icons.zoom_out),
                              //   onPressed: () {
                              //     setState(() {
                              //       _currentScale =
                              //           (_currentScale - 0.1).clamp(0.5, 3.0);
                              //     });
                              //   },
                              // ),
                              // Text('${(_currentScale * 100).round()}%'),
                              // IconButton(
                              //   icon: const Icon(Icons.zoom_in),
                              //   onPressed: () {
                              //     setState(() {
                              //       _currentScale =
                              //           (_currentScale + 0.1).clamp(0.5, 3.0);
                              //     });
                              //   },
                              // ),
                              // const Spacer(),
                              // IconButton(
                              //   icon: const Icon(Icons.center_focus_strong),
                              //   onPressed: () {
                              //     setState(() {
                              //       _currentScale = 1.0;
                              //       _currentOffset = Offset.zero;
                              //     });
                              //   },
                              //   tooltip: 'Reset Zoom',
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
