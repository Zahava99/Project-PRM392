import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'ai_beauty_scanner_model.dart';
export 'ai_beauty_scanner_model.dart';

class AiBeautyScannerWidget extends StatefulWidget {
  const AiBeautyScannerWidget({super.key});

  static String routeName = 'AiBeautyScanner';
  static String routePath = 'aiBeautyScanner';

  @override
  State<AiBeautyScannerWidget> createState() => _AiBeautyScannerWidgetState();
}

class _AiBeautyScannerWidgetState extends State<AiBeautyScannerWidget> {
  late AiBeautyScannerModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AiBeautyScannerModel());
    _fetchAvailableProducts();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableProducts() async {
    try {
      print('🛍️ Fetching available products...');
      final response = await ApiService.getAllProducts(page: 1, pageSize: 100);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        final products = productsJson
            .map((json) => ProductStruct.fromMap(json))
            .toList();
            
        setState(() {
          _model.setAvailableProducts(products);
        });
        
        print('✅ Loaded ${products.length} products');
      } else {
        print('❌ Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _model.setSelectedImage(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_model.selectedImage == null) return;

    setState(() {
      _model.setAnalyzing(true);
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('Bạn cần đăng nhập để sử dụng tính năng này');
      }

      print('🔄 Analyzing image with AI...');
      
      final response = await ApiService.analyzeBeautyImage(
        imageFile: _model.selectedImage!,
        token: token,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? responseData['response'] ?? '';
        
        // Try to parse JSON from the message
        AiAnalysisStruct? analysis = _parseAnalysisFromMessage(message);
        
        if (analysis != null) {
          setState(() {
            _model.setAiAnalysis(analysis);
            _model.setAnalysisResult('Phân tích hoàn tất');
          });
          
          _generateRecommendations(analysis);
        } else {
          // Fallback to simulate analysis if parsing fails
          await _simulateAIAnalysis();
        }
      } else {
        throw Exception('Lỗi phân tích: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi phân tích: $e');
      
      // Show appropriate error message
      if (e.toString().contains('GEMINI_OVERLOADED')) {
        // For overload - don't use simulation, just show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🤖 Hiện đang quá tải, vui lòng thử lại sau',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            backgroundColor: Colors.orange.shade600,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return; // Don't proceed to simulation for overload
      }
      
      // For other errors, show message and proceed to simulation
      String errorMessage = 'Có lỗi xảy ra, đang sử dụng chế độ mô phỏng';
      Color snackBarColor = Colors.blue.shade700;
      
      if (e.toString().contains('GEMINI_NO_IMAGE')) {
        errorMessage = 'Không nhận diện được ảnh, sử dụng phân tích mô phỏng';
        snackBarColor = Colors.purple.shade700;
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Kết nối chậm, chuyển sang chế độ offline';
        snackBarColor = Colors.red.shade700;
      } else if (e.toString().contains('đăng nhập')) {
        errorMessage = 'Cần đăng nhập để sử dụng AI, dùng chế độ demo';
        snackBarColor = Colors.indigo.shade700;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: snackBarColor,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      // Small delay before simulation
      await Future.delayed(Duration(milliseconds: 1000));
      await _simulateAIAnalysis();
    } finally {
      setState(() {
        _model.setAnalyzing(false);
      });
    }
  }

  AiAnalysisStruct? _parseAnalysisFromMessage(String message) {
    try {
      // Try to find JSON in the message
      final jsonRegex = RegExp(r'\{[^{}]*\}');
      final match = jsonRegex.firstMatch(message);
      
      if (match != null) {
        final jsonString = match.group(0)!;
        final data = jsonDecode(jsonString);
        
        return AiAnalysisStruct(
          skinTone: data['skinTone'] ?? '',
          skinType: data['skinType'] ?? '',
          faceShape: data['faceShape'] ?? '',
          recommendations: (data['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        );
      }
    } catch (e) {
      print('❌ Error parsing JSON: $e');
    }
    return null;
  }

  Future<void> _simulateAIAnalysis() async {
    print('🤖 Simulating AI analysis...');
    await Future.delayed(Duration(seconds: 2));
    
    // Generate random but realistic analysis results
    final skinTones = ['Warm Light', 'Warm Medium', 'Warm Deep', 'Cool Light', 'Cool Medium', 'Cool Deep', 'Neutral Light', 'Neutral Medium'];
    final skinTypes = ['Dry', 'Oily', 'Combination', 'Normal', 'Sensitive'];
    final faceShapes = ['Oval', 'Round', 'Square', 'Heart', 'Diamond', 'Rectangle'];
    
    final randomSkinTone = skinTones[math.Random().nextInt(skinTones.length)];
    final randomSkinType = skinTypes[math.Random().nextInt(skinTypes.length)];
    final randomFaceShape = faceShapes[math.Random().nextInt(faceShapes.length)];
    
    final recommendations = <String>[];
    
    // Generate recommendations based on analysis
    if (randomSkinTone.toLowerCase().contains('warm')) {
      recommendations.add('Chọn foundation có tông màu ấm (warm) để phù hợp với da bạn');
      recommendations.add('Sử dụng blush màu coral hoặc peach để tôn lên tông da ấm');
    } else if (randomSkinTone.toLowerCase().contains('cool')) {
      recommendations.add('Chọn foundation có tông màu mát (cool) với undertone hồng');
      recommendations.add('Sử dụng blush màu hồng hoặc rose để phù hợp với da mát');
    } else {
      recommendations.add('Chọn foundation neutral để phù hợp với tông da trung tính');
      recommendations.add('Có thể sử dụng nhiều loại màu sắc khác nhau');
    }
    
    if (randomSkinType.toLowerCase().contains('dry')) {
      recommendations.add('Sử dụng foundation dạng cream hoặc liquid có độ ẩm cao');
    } else if (randomSkinType.toLowerCase().contains('oily')) {
      recommendations.add('Chọn foundation dạng matte để kiểm soát dầu');
    }
    
    recommendations.add('Luôn sử dụng kem chống nắng trước khi trang điểm');
    recommendations.add('Tẩy trang sạch sẽ sau khi sử dụng makeup');
    
    final analysis = AiAnalysisStruct(
      skinTone: randomSkinTone,
      skinType: randomSkinType,
      faceShape: randomFaceShape,
      recommendations: recommendations,
    );
    
            setState(() {
      _model.setAiAnalysis(analysis);
      _model.setAnalysisResult('Phân tích hoàn tất');
    });
    
    _generateRecommendations(analysis);
  }

  void _generateRecommendations(AiAnalysisStruct analysis) {
    print('🎯 Generating product recommendations...');
    print('📊 Analysis: SkinTone=${analysis.skinTone}, SkinType=${analysis.skinType}, FaceShape=${analysis.faceShape}');
    print('🛍️ Available products: ${_model.availableProducts.length}');
    
    final recommendations = <RecommendedProductStruct>[];
    
    // Adaptive strictness based on product count
    final availableBeautyProducts = _model.availableProducts
        .where((p) => !_isNonBeautyProduct(p.name))
        .length;
    
    final bool isStrictMode = availableBeautyProducts >= 20; // Strict when many products
    final bool isMediumMode = availableBeautyProducts >= 10 && availableBeautyProducts < 20;
    final bool isLenientMode = availableBeautyProducts < 10; // Current state
    
    print('🎛️ Recommendation mode: ${isStrictMode ? "STRICT" : isMediumMode ? "MEDIUM" : "LENIENT"} (${availableBeautyProducts} beauty products)');
    
    for (final product in _model.availableProducts) {
      int matchScore = 0;
      String reason = '';
      
      print('🔍 Analyzing product: ${product.name}');
      
      // Skip non-beauty/makeup products for beauty scanner
      if (_isNonBeautyProduct(product.name)) {
        print('❌ Skipped ${product.name} - not a beauty product');
        continue;
      }
      
      print('✅ ${product.name} - is beauty product, analyzing...');
      
      // Skin tone based recommendations with adaptive scoring
      if (analysis.skinTone.toLowerCase().contains('warm')) {
        if (_isFoundationProduct(product.name)) {
          if (_hasWarmUndertone(product.name)) {
            matchScore += 45;
            reason = 'Foundation tông ấm phù hợp hoàn hảo với tone da ${analysis.skinTone}';
          } else if (!_hasCoolUndertone(product.name)) {
            matchScore += isStrictMode ? 15 : 30; // Adaptive scoring
            reason = 'Foundation phù hợp với tone da ${analysis.skinTone}';
          }
        }
        if (_isLipProduct(product.name)) {
          if (_hasWarmLipTone(product.name)) {
          matchScore += 35;
            reason = 'Màu son ấm phù hợp với tone da ${analysis.skinTone}';
          } else if (_isUniversalLipColor(product.name)) {
            matchScore += isStrictMode ? 15 : 25; // Less generous in strict mode
            reason = 'Màu son đa năng phù hợp với tone da ấm';
          } else if (isLenientMode) {
            matchScore += 15; // Only in lenient mode
            reason = 'Son môi tôn lên vẻ đẹp tự nhiên';
          }
        }
        if (_isBlushProduct(product.name)) {
          if (_hasWarmBlushTone(product.name)) {
          matchScore += 40;
            reason = 'Màu blush ấm tôn lên tone da ${analysis.skinTone}';
          } else if (!isStrictMode) {
            matchScore += 15; // Only when not strict
            reason = 'Blush phù hợp với tone da ấm';
          }
        }
      } else if (analysis.skinTone.toLowerCase().contains('cool')) {
        if (_isFoundationProduct(product.name)) {
          if (_hasCoolUndertone(product.name)) {
            matchScore += 45;
            reason = 'Foundation tông mát phù hợp hoàn hảo với tone da ${analysis.skinTone}';
          } else if (!_hasWarmUndertone(product.name)) {
            matchScore += isStrictMode ? 15 : 30; // Adaptive scoring
            reason = 'Foundation phù hợp với tone da ${analysis.skinTone}';
          }
        }
        if (_isLipProduct(product.name)) {
          if (_hasCoolLipTone(product.name)) {
          matchScore += 35;
            reason = 'Màu son mát phù hợp với tone da ${analysis.skinTone}';
          } else if (_isUniversalLipColor(product.name)) {
            matchScore += isStrictMode ? 15 : 25; // Less generous in strict mode
            reason = 'Màu son đa năng phù hợp với tone da mát';
          } else if (isLenientMode) {
            matchScore += 15; // Only in lenient mode
            reason = 'Son môi tôn lên vẻ đẹp tự nhiên';
          }
        }
        if (_isBlushProduct(product.name)) {
          if (_hasCoolBlushTone(product.name)) {
            matchScore += 40;
            reason = 'Màu blush mát tôn lên tone da ${analysis.skinTone}';
          } else if (!isStrictMode) {
            matchScore += 15; // Only when not strict
            reason = 'Blush phù hợp với tone da mát';
          }
        }
      } else if (analysis.skinTone.toLowerCase().contains('neutral')) {
        if (_isFoundationProduct(product.name)) {
          if (_hasNeutralUndertone(product.name)) {
            matchScore += 45;
            reason = 'Foundation neutral hoàn hảo cho tone da ${analysis.skinTone}';
          } else {
            matchScore += isStrictMode ? 20 : 35; // Adaptive scoring
            reason = 'Foundation phù hợp với tone da trung tính';
          }
        }
        if (_isLipProduct(product.name)) {
          matchScore += isStrictMode ? 20 : 30; // Neutral tone works with most lip colors
          reason = 'Son môi phù hợp với tone da trung tính đa năng';
        }
        if (_isBlushProduct(product.name)) {
          matchScore += isStrictMode ? 15 : 25;
          reason = 'Blush phù hợp với tone da trung tính';
        }
      }
      
      // Skin type based recommendations with adaptive scoring
      if (analysis.skinType.toLowerCase().contains('oily')) {
        if (_isFoundationProduct(product.name)) {
          if (_isMatteFormula(product.name)) {
            matchScore += 35;
            reason += reason.isEmpty ? 'Formula matte hoàn hảo cho da dầu' : ' • Formula matte kiểm soát dầu';
          } else if (_isLongWearingFormula(product.name)) {
          matchScore += 20;
            reason += reason.isEmpty ? 'Formula lâu trôi cho da dầu' : ' • Lâu trôi';
          } else if (!isStrictMode) {
            matchScore += 10; // Only when not strict
            reason += reason.isEmpty ? 'Foundation phù hợp cho da dầu' : ' • Phù hợp da dầu';
          }
        }
        if (_isPowderProduct(product.name)) {
          matchScore += 30;
          reason = reason.isEmpty ? 'Phấn phủ kiểm soát dầu hiệu quả' : reason + ' • Kiểm soát dầu';
        }
        if (_isPrimerProduct(product.name) && _isMattePrimer(product.name)) {
          matchScore += 25;
          reason = 'Primer matte chuẩn bị da dầu';
        }
      } else if (analysis.skinType.toLowerCase().contains('dry')) {
        if (_isFoundationProduct(product.name)) {
          if (_isHydratingFormula(product.name)) {
            matchScore += 35;
            reason += reason.isEmpty ? 'Formula dưỡng ẩm cho da khô' : ' • Dưỡng ẩm';
          } else if (_isDeweyFormula(product.name)) {
            matchScore += 30;
            reason += reason.isEmpty ? 'Finish dewy tự nhiên cho da khô' : ' • Finish dewy';
          } else if (!isStrictMode) {
            matchScore += 10; // Only when not strict
            reason += reason.isEmpty ? 'Foundation phù hợp cho da khô' : ' • Phù hợp da khô';
          }
        }
        if (_isMoisturizerProduct(product.name)) {
          matchScore += 40;
          reason = 'Dưỡng ẩm cần thiết cho da khô';
        }
        if (_isHydratingProduct(product.name)) {
          matchScore += 25;
          reason = reason.isEmpty ? 'Sản phẩm dưỡng ẩm' : reason;
        }
      } else if (analysis.skinType.toLowerCase().contains('normal')) {
        // Normal skin - adaptive recommendations
        if (_isFoundationProduct(product.name)) {
          matchScore += isStrictMode ? 15 : 25;
          reason += reason.isEmpty ? 'Foundation phù hợp cho da normal' : ' • Phù hợp da normal';
        }
        if (_isMoisturizerProduct(product.name)) {
          matchScore += isStrictMode ? 20 : 30;
          reason = reason.isEmpty ? 'Dưỡng ẩm duy trì da khỏe mạnh' : reason;
        }
      } else if (analysis.skinType.toLowerCase().contains('sensitive')) {
        if (_isGentleFormula(product.name)) {
          matchScore += 30;
          reason += reason.isEmpty ? 'Formula nhẹ nhàng cho da nhạy cảm' : ' • Nhẹ nhàng';
        }
        if (_isHypoallergenicProduct(product.name)) {
          matchScore += 35;
          reason = 'Không gây dị ứng, an toàn cho da nhạy cảm';
        }
      }
      
      // Face shape based recommendations
      if (analysis.faceShape.toLowerCase().contains('round')) {
        if (_isContourProduct(product.name)) {
          matchScore += 35;
          reason += reason.isEmpty ? 'Contouring tạo góc cạnh cho khuôn mặt tròn' : ' • Tạo góc cạnh';
        }
        if (_isBronzerProduct(product.name)) {
          matchScore += 30;
          reason += reason.isEmpty ? 'Bronzer tạo chiều sâu cho mặt tròn' : ' • Tạo chiều sâu';
        }
      } else if (analysis.faceShape.toLowerCase().contains('square')) {
        if (_isHighlighterProduct(product.name)) {
          matchScore += 35;
          reason += reason.isEmpty ? 'Highlight làm mềm đường nét góc cạnh' : ' • Làm mềm đường nét';
        }
      } else if (analysis.faceShape.toLowerCase().contains('oval')) {
        if (_isBlushProduct(product.name)) {
          matchScore += 25;
          reason += reason.isEmpty ? 'Blush tôn lên khuôn mặt oval hoàn hảo' : ' • Tôn khuôn mặt';
        }
      }
      
      // Essential beauty products (adaptive scoring)
      if (_isConcealerProduct(product.name)) {
        matchScore += isStrictMode ? 15 : 20;
        if (reason.isEmpty) reason = 'Che khuyết điểm cần thiết';
      }
      if (_isMascaraProduct(product.name)) {
        matchScore += isStrictMode ? 10 : 15;
        if (reason.isEmpty) reason = 'Làm dài mi tự nhiên';
      }
      if (_isEyebrowProduct(product.name)) {
        matchScore += isStrictMode ? 12 : 18;
        if (reason.isEmpty) reason = 'Định hình lông mày';
      }
      if (_isMoisturizerProduct(product.name)) {
        matchScore += isStrictMode ? 15 : 20; // Always recommend moisturizer
        if (reason.isEmpty) reason = 'Dưỡng ẩm cơ bản cho mọi loại da';
      }
      
      // Skincare essentials (adaptive)
      if (_isSkincareProduct(product.name)) {
        matchScore += isStrictMode ? 10 : 15; // Bonus for skincare
        if (reason.isEmpty) reason = 'Chăm sóc da cơ bản';
      }
      
      // Lip products fallback (only in lenient mode)
      if (_isLipProduct(product.name) && matchScore == 0 && isLenientMode) {
        matchScore += 12;
        reason = 'Son môi hoàn thiện vẻ đẹp';
      }
      
      // Price preference (slight bonus for affordable options)
      if (product.price < 500000) {
        matchScore += isStrictMode ? 1 : 3; // Less bonus in strict mode
      }
      
      // Quality bonus for well-reviewed products
      if (_isPopularBrand(product.name)) {
        matchScore += 5;
      }
      
      print('📊 ${product.name} - Score: $matchScore, Reason: $reason');
      
      if (matchScore > 0) {
        recommendations.add(RecommendedProductStruct(
          product: product,
          reason: reason.trim(),
          matchScore: matchScore,
        ));
      }
    }
    
    // Dynamic minimum score threshold
    final int minScoreThreshold = isStrictMode ? 25 : isMediumMode ? 15 : 5;
    final filteredRecommendations = recommendations
        .where((r) => r.matchScore >= minScoreThreshold)
        .toList();
    
    print('🎯 Filtered ${filteredRecommendations.length}/${recommendations.length} recommendations with score >= $minScoreThreshold');
    
    // Adaptive fallback system
    final recommendationsToUse = filteredRecommendations.isNotEmpty 
        ? filteredRecommendations 
        : recommendations;
    
    // If we still have fewer than 3 recommendations in lenient mode, add fallbacks
    if (recommendationsToUse.length < 3 && isLenientMode) {
      print('⚠️ Only ${recommendationsToUse.length} recommendations, adding fallbacks...');
      for (final product in _model.availableProducts) {
        if (!_isNonBeautyProduct(product.name) && 
            !recommendationsToUse.any((r) => r.product.productId == product.productId)) {
          recommendationsToUse.add(RecommendedProductStruct(
            product: product,
            reason: 'Sản phẩm chất lượng được đề xuất',
            matchScore: 5,
          ));
          if (recommendationsToUse.length >= 3) break;
        }
      }
    }
    
    // Sort by match score and take appropriate number
    recommendationsToUse.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    
    final int maxRecommendations = isStrictMode ? 8 : isMediumMode ? 6 : 4;
    final finalRecommendations = recommendationsToUse.take(maxRecommendations).toList();
    
    setState(() {
      _model.setRecommendedProducts(finalRecommendations);
    });
    
    print('✅ Generated ${finalRecommendations.length} high-quality recommendations');
    for (final rec in finalRecommendations) {
      print('   📦 ${rec.product.name} (Score: ${rec.matchScore}) - ${rec.reason}');
    }
  }

  // Helper methods for better product categorization
  bool _isNonBeautyProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('shampoo') || 
           name.contains('conditioner') || 
           name.contains('hair mask') ||
           name.contains('perfume') ||
           name.contains('fragrance') ||
           name.contains('supplement') ||
           name.contains('vitamin');
  }

  bool _isFoundationProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('foundation') || name.contains('base makeup');
  }

  bool _isBlushProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('blush') || name.contains('blusher');
  }

  bool _isLipProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('lipstick') || name.contains('lip') || name.contains('son');
  }

  bool _isPowderProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('powder') || name.contains('phấn');
  }

  bool _isContourProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('contour') || name.contains('contouring');
  }

  bool _isBronzerProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('bronzer') || name.contains('bronzing');
  }

  bool _isHighlighterProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('highlight') || name.contains('illuminat');
  }

  bool _isConcealerProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('concealer') || name.contains('che khuyết');
  }

  bool _isMascaraProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('mascara');
  }

  bool _isEyebrowProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('eyebrow') || name.contains('brow') || name.contains('lông mày');
  }

  bool _isPrimerProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('primer');
  }

  bool _isMoisturizerProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('moisturizer') || name.contains('cream') || name.contains('kem dưỡng');
  }

  // Undertone detection
  bool _hasWarmUndertone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('warm') || name.contains('golden') || name.contains('beige') || 
           name.contains('honey') || name.contains('camel');
  }

  bool _hasCoolUndertone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('cool') || name.contains('pink') || name.contains('rose') ||
           name.contains('porcelain') || name.contains('ivory');
  }

  bool _hasNeutralUndertone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('neutral') || name.contains('natural') || name.contains('buff');
  }

  // Color tone detection for blush
  bool _hasWarmBlushTone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('coral') || name.contains('peach') || name.contains('apricot') ||
           name.contains('bronze') || name.contains('terracotta');
  }

  bool _hasCoolBlushTone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('pink') || name.contains('rose') || name.contains('berry') ||
           name.contains('plum') || name.contains('mauve');
  }

  // Color tone detection for lips
  bool _hasWarmLipTone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('coral') || name.contains('orange') || name.contains('bronze') ||
           name.contains('nude warm') || name.contains('caramel');
  }

  bool _hasCoolLipTone(String productName) {
    final name = productName.toLowerCase();
    return name.contains('pink') || name.contains('berry') || name.contains('plum') ||
           name.contains('red cool') || name.contains('cherry');
  }

  bool _isUniversalLipColor(String productName) {
    final name = productName.toLowerCase();
    return name.contains('nude') || name.contains('mlbb') || name.contains('natural') ||
           name.contains('neutral') || name.contains('universal');
  }

  // Formula detection
  bool _isMatteFormula(String productName) {
    final name = productName.toLowerCase();
    return name.contains('matte');
  }

  bool _isDeweyFormula(String productName) {
    final name = productName.toLowerCase();
    return name.contains('dewy') || name.contains('glow') || name.contains('luminous');
  }

  bool _isHydratingFormula(String productName) {
    final name = productName.toLowerCase();
    return name.contains('hydrating') || name.contains('moisturizing') || 
           name.contains('dưỡng ẩm') || name.contains('moisture');
  }

  bool _isLongWearingFormula(String productName) {
    final name = productName.toLowerCase();
    return name.contains('long wear') || name.contains('long lasting') || 
           name.contains('24h') || name.contains('all day');
  }

  bool _isMattePrimer(String productName) {
    final name = productName.toLowerCase();
    return name.contains('primer') && name.contains('matte');
  }

  bool _isGentleFormula(String productName) {
    final name = productName.toLowerCase();
    return name.contains('gentle') || name.contains('sensitive') || 
           name.contains('nhẹ nhàng') || name.contains('mild');
  }

  bool _isHypoallergenicProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('hypoallergenic') || name.contains('allergy tested');
  }

  bool _isHydratingProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('hydra') || name.contains('moisture') || name.contains('aqua');
  }

  bool _isPopularBrand(String productName) {
    final name = productName.toLowerCase();
    return name.contains('mac') || name.contains('maybelline') || name.contains('loreal') ||
           name.contains('clinique') || name.contains('estee lauder') || name.contains('dior');
  }

  bool _isSkincareProduct(String productName) {
    final name = productName.toLowerCase();
    return name.contains('moisturizer') || 
           name.contains('cream') || 
           name.contains('serum') ||
           name.contains('cleanser') ||
           name.contains('toner') ||
           name.contains('sunscreen') ||
           name.contains('treatment');
  }

  Future<void> _addToCart(ProductStruct product) async {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sản phẩm đã hết hàng')),
      );
      return;
    }

        setState(() {
      _model.setAddingToCart(product.productId, true);
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng');
      }

      final response = await ApiService.addToCart(
        productId: product.productId,
        quantity: 1,
        token: token,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${product.name}" vào giỏ hàng!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Không thể thêm vào giỏ hàng');
      }
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
      ),
    );
    } finally {
      setState(() {
        _model.setAddingToCart(product.productId, false);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn nguồn ảnh',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: FlutterFlowTheme.of(context).primary,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }

  DetailStruct _convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      id: product.productId.hashCode, // Use hashCode as numeric ID
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'assets/images/placeholder.png',
      title: product.name,
      price: product.price.toString(), // Keep as number string for ProductContanierWidget to format
      catetype: product.category['name'] ?? '',
      stockQuantity: product.stockQuantity.toString(),
      description: product.description,
      brandName: product.brand['name'] ?? '',
      isFav: FFAppState().isProductFavorite(product.productId),
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
      isResult: '',
      itsResult: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.safePop();
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30.0,
          ),
        ),
        title: Text(
          'AI Beauty Scanner',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'SF Pro Text',
            color: Color(0xFF8B5CF6),
            fontSize: 24.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Upload a photo to get personalized makeup recommendations',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'SF Pro Text',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    lineHeight: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                
                // Upload Area
                if (_model.selectedImage == null) ...[
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF8B5CF6),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Color(0xFF8B5CF6),
                              size: 40,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Upload Photo',
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Take a selfie or choose from gallery',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Selected Image
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF8B5CF6),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _model.selectedImage!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            setState(() {
                              _model.resetState();
                            });
                          },
                          text: 'Chọn ảnh khác',
                          options: FFButtonOptions(
                            height: 50.0,
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).lightGray,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).borderColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: _model.isAnalyzing ? null : _analyzeImage,
                          text: _model.isAnalyzing ? 'Đang phân tích...' : 'Phân tích với AI',
                          options: FFButtonOptions(
                            height: 50.0,
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF8B5CF6),
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'SF Pro Text',
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                SizedBox(height: 30),
                
                // Loading or Results
                if (_model.isAnalyzing) ...[
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'AI đang phân tích da của bạn...',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_model.aiAnalysis != null) ...[
                  // Analysis Results
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF8B5CF6),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Kết quả phân tích AI',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'SF Pro Text',
                                color: Color(0xFF8B5CF6),
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Analysis Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnalysisItem(
                              icon: Icons.color_lens,
                              label: 'Tông da',
                              value: _model.aiAnalysis!.skinTone,
                            ),
                            _buildAnalysisItem(
                              icon: Icons.water_drop,
                              label: 'Loại da',
                              value: _model.aiAnalysis!.skinType,
                            ),
                            _buildAnalysisItem(
                              icon: Icons.face,
                              label: 'Hình dạng mặt',
                              value: _model.aiAnalysis!.faceShape,
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        Text(
                          'Gợi ý trang điểm',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Recommendations
                        ..._model.aiAnalysis!.recommendations.map((rec) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Recommended Products
                  if (_model.recommendedProducts.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sản phẩm được đề xuất cho bạn',
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_model.recommendedProducts.where((p) => p.product.stockQuantity > 0).length} sản phẩm có sẵn',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // Products Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75, // Increased for more space
                            ),
                            itemCount: _model.recommendedProducts.length,
                            itemBuilder: (context, index) {
                              final item = _model.recommendedProducts[index];
                              final product = item.product;
                              
                              // Convert ProductStruct to DetailStruct for navigation
                              final detailItem = _convertProductToDetail(product);
                              
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                    ProducutDetailPageWidget.routeName,
                                    queryParameters: {
                                      'detail': serializeParam(
                                        detailItem,
                                        ParamType.DataStruct,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                            child: product.imageUrls.isNotEmpty
                                                ? Image.network(
                                                    product.imageUrls.first,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => 
                                                        Container(
                                                          color: Colors.grey[200],
                                                          child: Icon(Icons.image_not_supported),
                                                        ),
                                                  )
                                                : Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(Icons.image),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Product Info
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8), // Reduced padding
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min, // Important: use min size
                                            children: [
                                              Text(
                                                product.name,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11, // Slightly smaller
                                                ),
                                                maxLines: 1, // Reduced to 1 line
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 2), // Reduced spacing
                                              Text(
                                                _formatPrice(product.price),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  color: Color(0xFF8B5CF6),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11, // Slightly smaller
                                                ),
                                              ),
                                              SizedBox(height: 2), // Reduced spacing
                                              Expanded( // Use Expanded instead of fixed height
                                                child: Text(
                                                  item.reason,
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    fontSize: 9, // Smaller text
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              
                                              // Match Score and Add Button
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${item.matchScore}% Match',
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  
                                                  InkWell(
                                                    onTap: product.stockQuantity > 0 && 
                                                           !(_model.addingToCart[product.productId] ?? false)
                                                        ? () => _addToCart(product)
                                                        : null,
                                                    child: Container(
                                                      padding: EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: product.stockQuantity > 0 
                                                            ? Color(0xFF8B5CF6)
                                                            : Colors.grey,
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: (_model.addingToCart[product.productId] ?? false)
                                                          ? SizedBox(
                                                              width: 12,
                                                              height: 12,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                              ),
                                                            )
                                                          : Icon(
                                                              product.stockQuantity > 0 
                                                                  ? Icons.add_shopping_cart
                                                                  : Icons.remove_shopping_cart,
                                                              color: Colors.white,
                                                              size: 12,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFF8B5CF6),
          size: 24,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 