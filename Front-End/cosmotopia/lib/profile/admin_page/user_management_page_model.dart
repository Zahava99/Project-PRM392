import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_service.dart';
import 'package:flutter/material.dart';

class UserManagementPageModel extends ChangeNotifier {
  // User list state
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  
  // Pagination
  int currentPage = 1;
  int pageSize = 20;
  bool hasMoreData = true;
  
  // Collapsible sections state
  Map<String, bool> sectionExpanded = {
    'admins': true,
    'staff': true,
    'users': true,
    'inactive': false,
  };
  
  // Edit dialog state
  bool isEditDialogOpen = false;
  Map<String, dynamic>? selectedUser;
  int? selectedUserStatus;
  int? selectedRoleType;
  
  // Role and status mappings  
  final Map<int, String> roleNames = {
    0: 'Administrator',
    1: 'Manager',
    2: 'Affiliates',
    3: 'Customers',
    4: 'Sales Staff',
  };
  
  final Map<String, int> statusValues = {
    'Active': 0,
    'Banned': 1,
  };
  
  final Map<int, String> statusNames = {
    0: 'Active',
    1: 'Banned',
  };

  // Constructor to initialize data
  UserManagementPageModel() {
    loadUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      users.clear();
      hasMoreData = true;
    }
    
    if (isLoading || !hasMoreData) return;
    
    isLoading = true;
    hasError = false;
    notifyListeners();
    
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      final response = await ApiService.getAllUsers(
        token: token,
        page: currentPage,
        pageSize: pageSize,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> newUsers = data['data'] ?? [];
        
        if (refresh) {
          users = newUsers.cast<Map<String, dynamic>>();
        } else {
          users.addAll(newUsers.cast<Map<String, dynamic>>());
        }
        
        hasMoreData = newUsers.length >= pageSize;
        currentPage++;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      print('❌ Error loading users: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  void openEditDialog(Map<String, dynamic> user) {
    selectedUser = user;
    selectedUserStatus = _parseUserStatus(user['userStatus']);
    selectedRoleType = user['roleType'];
    isEditDialogOpen = true;
    notifyListeners();
  }
  
  void closeEditDialog() {
    selectedUser = null;
    selectedUserStatus = null;
    selectedRoleType = null;
    isEditDialogOpen = false;
    notifyListeners();
  }
  
  Future<bool> saveUserChanges() async {
    if (selectedUser == null) return false;
    
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      final userId = selectedUser!['userId'].toString();
      
      final response = await ApiService.editUserStatusAndRole(
        userId: userId,
        token: token,
        userStatus: selectedUserStatus,
        roleType: selectedRoleType,
      );
      
      print('📥 Edit user response: ${response.statusCode}');
      print('📥 Edit user response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Update local user data
        final userIndex = users.indexWhere((u) => u['userId'] == selectedUser!['userId']);
        if (userIndex != -1) {
          // Update userStatus as string (to match API response format)
          if (selectedUserStatus != null) {
            users[userIndex]['userStatus'] = selectedUserStatus.toString();
          }
          // Update roleType as integer
          if (selectedRoleType != null) {
            users[userIndex]['roleType'] = selectedRoleType;
            users[userIndex]['roleName'] = roleNames[selectedRoleType];
          }
        }
        
        closeEditDialog();
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      errorMessage = e.toString();
      print('❌ Error saving user changes: $e');
      return false;
    }
  }
  
  int? _parseUserStatus(dynamic status) {
    if (status is int) return status;
    if (status is String) {
      // Try to parse as integer first
      final parsed = int.tryParse(status);
      if (parsed != null) return parsed;
      
      // Fallback to string mapping
      return statusValues[status];
    }
    return null;
  }
  
  String getUserStatusText(dynamic status) {
    final statusInt = _parseUserStatus(status);
    return statusNames[statusInt] ?? status.toString();
  }
  
  String getRoleText(int? roleType) {
    return roleNames[roleType] ?? 'Unknown';
  }
  
  void toggleSection(String sectionKey) {
    sectionExpanded[sectionKey] = !(sectionExpanded[sectionKey] ?? false);
    notifyListeners();
  }
  
  // Group users by role and status
  Map<String, List<Map<String, dynamic>>> get groupedUsers {
    Map<String, List<Map<String, dynamic>>> groups = {
      'admins': [],
      'staff': [],
      'users': [],
      'inactive': [],
    };
    
    for (var user in users) {
      final roleType = user['roleType'] ?? 3;
      final userStatus = _parseUserStatus(user['userStatus']) ?? 0;
      
      // Check if user is banned first
      if (userStatus == 1) {
        groups['inactive']!.add(user);
      } else {
        // Group by roleType for active users
        switch (roleType) {
          case 0: // Administrator
            groups['admins']!.add(user);
            break;
          case 1: // Manager
            groups['admins']!.add(user);
            break;
          case 2: // Affiliates
            groups['staff']!.add(user);
            break;
          case 3: // Customers
            groups['users']!.add(user);
            break;
          case 4: // Sales Staff
            groups['staff']!.add(user);
            break;
          default:
            // Unknown role types go to users
            groups['users']!.add(user);
        }
      }
    }
    
    return groups;
  }
  
  int getSectionCount(String sectionKey) {
    return groupedUsers[sectionKey]?.length ?? 0;
  }
} 