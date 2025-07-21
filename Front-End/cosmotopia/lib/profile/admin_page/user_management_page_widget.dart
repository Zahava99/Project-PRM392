import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'user_management_page_model.dart';
export 'user_management_page_model.dart';

class UserManagementPageWidget extends StatefulWidget {
  const UserManagementPageWidget({super.key});

  static String routeName = 'UserManagementPage';
  static String routePath = 'userManagementPage';

  @override
  State<UserManagementPageWidget> createState() => _UserManagementPageWidgetState();
}

class _UserManagementPageWidgetState extends State<UserManagementPageWidget>
    with TickerProviderStateMixin {
  late UserManagementPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = UserManagementPageModel();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _model.loadUsers();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Icon(
                    Icons.person,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user['email'] ?? '',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 14.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showEditDialog(user),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                _buildInfoChip(
                  'Role: ${_model.getRoleText(user['roleType'])}',
                  Colors.blue,
                ),
                SizedBox(width: 8.0),
                _buildStatusChip(_model.getUserStatusText(user['userStatus'])),
              ],
            ),
            if (user['phone'] != null && user['phone'].toString().isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Phone: ${user['phone']}',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'SF Pro Text',
          fontSize: 12.0,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'inactive':
        chipColor = Colors.orange;
        break;
      case 'banned':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'SF Pro Text',
          fontSize: 12.0,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(String sectionKey, String title, IconData icon, Color color) {
    final sectionUsers = _model.groupedUsers[sectionKey] ?? [];
    final isExpanded = _model.sectionExpanded[sectionKey] ?? false;
    final userCount = sectionUsers.length;
    
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () => _model.toggleSection(sectionKey),
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22.0,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  
                  // Title and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$userCount ${userCount == 1 ? 'user' : 'users'}',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 13.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expand/Collapse Icon
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
          
          // Section Content
          if (isExpanded && userCount > 0)
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Column(
                children: sectionUsers.map((user) => Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: _buildUserCard(user),
                )).toList(),
              ),
            ),
          
          // Empty state
          if (isExpanded && userCount == 0)
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Text(
                'No users in this category',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    _model.openEditDialog(user);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${user['firstName']} ${user['lastName']}'),
                  Text(user['email'] ?? ''),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<int>(
                    value: _model.selectedRoleType,
                    decoration: InputDecoration(labelText: 'Role'),
                    items: _model.roleNames.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _model.selectedRoleType = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<int>(
                    value: _model.selectedUserStatus,
                    decoration: InputDecoration(labelText: 'Status'),
                    items: _model.statusNames.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _model.selectedUserStatus = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _model.closeEditDialog();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _model.saveUserChanges();
                Navigator.of(context).pop();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {}); // Refresh the UI
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update user'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                      child: InkWell(
                        onTap: () async {
                          context.safePop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                    Text(
                      'User Management',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF pro display',
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                      child: InkWell(
                        onTap: () async {
                          await _model.loadUsers(refresh: true);
                        },
                        child: Icon(
                          Icons.refresh,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Users Count
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_model.users.length} users found',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                    if (_model.users.isNotEmpty)
                      Text(
                        'Admins: ${_model.getSectionCount('admins')} • Staff: ${_model.getSectionCount('staff')} • Users: ${_model.getSectionCount('users')}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 12.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              
                                // User List
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _model,
                      builder: (context, child) {
                    if (_model.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.0,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Failed to load users',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _model.errorMessage,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => _model.loadUsers(refresh: true),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (_model.users.isEmpty && _model.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    
                    if (_model.users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'No users found',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                      child: Column(
                        children: [
                          // Admins Section
                          _buildCollapsibleSection(
                            'admins',
                            'Administrators',
                            Icons.admin_panel_settings,
                            Colors.red,
                          ),
                          
                          SizedBox(height: 12.0),
                          
                          // Staff Section
                          _buildCollapsibleSection(
                            'staff',
                            'Affiliates',
                            Icons.work,
                            Colors.orange,
                          ),
                          
                          SizedBox(height: 12.0),
                          
                          // Regular Users Section
                          _buildCollapsibleSection(
                            'users',
                            'Customers',
                            Icons.people,
                            Colors.blue,
                          ),
                          
                          SizedBox(height: 12.0),
                          
                          // Banned Users Section
                          _buildCollapsibleSection(
                            'inactive',
                            'Banned Users',
                            Icons.person_off,
                            Colors.red,
                          ),
                          
                          // Loading indicator
                          if (_model.isLoading)
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
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
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
  }
} 