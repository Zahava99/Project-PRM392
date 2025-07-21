import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'my_profile_page_widget.dart' show MyProfilePageWidget;
import 'package:flutter/material.dart';

class MyProfilePageModel extends FlutterFlowModel<MyProfilePageWidget> {
  // State variables for user data
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  bool isLoading = true;
  
  // Edit mode state
  bool isEditMode = false;
  bool isSaving = false;
  
  // Text controllers for edit mode
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  
  // Focus nodes
  late FocusNode firstNameFocusNode;
  late FocusNode lastNameFocusNode;
  late FocusNode phoneFocusNode;
  
  // Validators
  String? Function(BuildContext, String?)? firstNameValidator;
  String? Function(BuildContext, String?)? lastNameValidator;
  String? Function(BuildContext, String?)? phoneValidator;

  @override
  void initState(BuildContext context) {
    // Initialize controllers and focus nodes
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    
    firstNameFocusNode = FocusNode();
    lastNameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    
    // Setup validators
    firstNameValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return 'First name is required';
      }
      return null;
    };
    
    lastNameValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return 'Last name is required';
      }
      return null;
    };
    
    phoneValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return 'Phone number is required';
      }
      // Basic phone validation for Vietnamese numbers
      String cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length < 9 || cleanPhone.length > 11) {
        return 'Please enter a valid phone number';
      }
      return null;
    };
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    phoneFocusNode.dispose();
  }
  
  void updateEditMode(bool editMode) {
    isEditMode = editMode;
  }
  
  void populateEditFields(String firstName, String lastName, String phone) {
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    phoneController.text = phone;
  }
}
