import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'ai_beauty_scanner_widget.dart' show AiBeautyScannerWidget;
import 'package:flutter/material.dart';
import 'dart:io';

class AiBeautyScannerModel extends FlutterFlowModel<AiBeautyScannerWidget> {
  ///  Local state fields for this page.
  File? selectedImage;
  bool isUploading = false;
  bool isAnalyzing = false;
  String? analysisResult;
  String? taskId;
  
  // New fields for detailed analysis
  AiAnalysisStruct? aiAnalysis;
  List<ProductStruct> availableProducts = [];
  List<RecommendedProductStruct> recommendedProducts = [];
  Map<String, bool> addingToCart = {};

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  void setSelectedImage(File? image) {
    selectedImage = image;
  }

  void setUploading(bool uploading) {
    isUploading = uploading;
  }

  void setAnalyzing(bool analyzing) {
    isAnalyzing = analyzing;
  }

  void setAnalysisResult(String? result) {
    analysisResult = result;
  }

  void setTaskId(String? id) {
    taskId = id;
  }

  void setAiAnalysis(AiAnalysisStruct? analysis) {
    aiAnalysis = analysis;
  }

  void setAvailableProducts(List<ProductStruct> products) {
    availableProducts = products;
  }

  void setRecommendedProducts(List<RecommendedProductStruct> products) {
    recommendedProducts = products;
  }

  void setAddingToCart(String productId, bool isAdding) {
    addingToCart[productId] = isAdding;
  }

  void resetState() {
    selectedImage = null;
    isUploading = false;
    isAnalyzing = false;
    analysisResult = null;
    taskId = null;
    aiAnalysis = null;
    recommendedProducts = [];
    addingToCart = {};
  }
} 