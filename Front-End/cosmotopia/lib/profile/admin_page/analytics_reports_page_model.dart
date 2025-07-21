import '/backend/api_service.dart';
import '/app_state.dart';
import 'package:flutter/material.dart';

class AnalyticsReportsPageModel extends ChangeNotifier {
  // Dashboard state
  Map<String, dynamic> analyticsData = {};
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  
  // Summary stats
  int totalUsers = 0;
  int totalProducts = 0;
  int totalCategories = 0;
  int totalBrands = 0;
  int activeUsers = 0;
  int adminUsers = 0;
  
  // Chart data
  Map<String, int> userStatusDistribution = {};
  Map<String, int> userRoleDistribution = {};
  Map<String, int> productsByCategory = {};
  List<Map<String, dynamic>> topSellingProducts = [];
  
  // Recent activity
  List<Map<String, dynamic>> recentActivity = [];
  
  // Selected tab/view
  int selectedTabIndex = 0;
  
  // Constructor to initialize data
  AnalyticsReportsPageModel() {
    loadAnalytics();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  Future<void> loadAnalytics({bool refresh = false}) async {
    if (isLoading && !refresh) return;
    
    isLoading = true;
    hasError = false;
    notifyListeners();
    
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      final dashboard = await ApiService.getAnalyticsDashboard(token: token);
      
      analyticsData = dashboard;
      
      // Extract summary data
      final summary = dashboard['summary'] as Map<String, dynamic>? ?? {};
      totalUsers = summary['totalUsers'] ?? 0;
      totalProducts = summary['totalProducts'] ?? 0;
      totalCategories = summary['totalCategories'] ?? 0;
      totalBrands = summary['totalBrands'] ?? 0;
      
      // Extract user stats
      final users = dashboard['users'] as Map<String, dynamic>? ?? {};
      activeUsers = users['active'] ?? 0;
      adminUsers = users['admins'] ?? 0;
      
      // Extract chart data
      final charts = dashboard['charts'] as Map<String, dynamic>? ?? {};
      userStatusDistribution = Map<String, int>.from(charts['userStatusDistribution'] ?? {});
      userRoleDistribution = Map<String, int>.from(charts['userRoleDistribution'] ?? {});
      productsByCategory = Map<String, int>.from(charts['productsByCategory'] ?? {});
      topSellingProducts = List<Map<String, dynamic>>.from(charts['topSellingProducts'] ?? []);
      
      // Extract recent activity
      final List<dynamic> activity = dashboard['recentActivity'] ?? [];
      recentActivity = activity.cast<Map<String, dynamic>>();
      
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      print('❌ Error loading analytics: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void setSelectedTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }
  
  // Helper methods for chart data processing
  List<MapEntry<String, int>> getTopCategories({int limit = 5}) {
    var sorted = productsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
  
  double getUserActivePercentage() {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }
  
  double getAdminPercentage() {
    if (totalUsers == 0) return 0.0;
    return (adminUsers / totalUsers) * 100;
  }
  
  String getFormattedTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
  
  IconData getActivityIcon(String type) {
    switch (type) {
      case 'user_registration':
        return Icons.person_add;
      case 'product_added':
        return Icons.add_box;
      case 'order_placed':
        return Icons.shopping_cart;
      case 'payment_completed':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }
  
  Color getActivityColor(String type) {
    switch (type) {
      case 'user_registration':
        return Colors.green;
      case 'product_added':
        return Colors.blue;
      case 'order_placed':
        return Colors.orange;
      case 'payment_completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 