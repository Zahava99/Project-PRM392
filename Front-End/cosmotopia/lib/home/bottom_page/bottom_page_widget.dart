import '/all_component/chat_bubble/chat_bubble_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'bottom_page_model.dart';
import 'bottom_page_subfile/data_loader_mixin.dart';
import 'bottom_page_subfile/home_tab_widget.dart';
import 'bottom_page_subfile/order_tab_widget.dart';
import 'bottom_page_subfile/favorite_tab_widget.dart';
import 'bottom_page_subfile/profile_tab_widget.dart';
import 'bottom_page_subfile/bottom_navigation_widget.dart';

export 'bottom_page_model.dart';

class BottomPageWidget extends StatefulWidget {
  const BottomPageWidget({super.key});

  static String routeName = 'BottomPage';
  static String routePath = 'bottomPage';

  @override
  State<BottomPageWidget> createState() => _BottomPageWidgetState();
}

class _BottomPageWidgetState extends State<BottomPageWidget>
    with TickerProviderStateMixin, DataLoaderMixin, WidgetsBindingObserver, RouteAware {
  late BottomPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomPageModel());
    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
    
    // Add observers
    WidgetsBinding.instance.addObserver(this);
    FFAppState().addListener(onAppStateChange);
    
    _initializeAnimations();
    _loadAllData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshDataIfNeeded();
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Refresh data when returning to this page from another page
    _refreshDataIfNeeded();
  }

  void _refreshDataIfNeeded() {
    final now = DateTime.now();
    if (_lastRefreshTime == null || 
        now.difference(_lastRefreshTime!).inSeconds > 30) {
      _lastRefreshTime = now;
      _loadAllData();
      print('🔄 Refreshing bottom page data due to lifecycle change');
    }
  }

  void _initializeAnimations() {
    animationsMap.addAll({
      'categoryContainOnPageLoadAnimation': AnimationInfo(
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
      'productContanierOnPageLoadAnimation': AnimationInfo(
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
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.linear,
            delay: 100.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.linear,
            delay: 100.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.linear,
            delay: 100.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  void _loadAllData() {
    loadCategories();
    loadProducts();
    loadFavoriteProducts();
    loadCurrentUser();
    loadUserOrders();
  }

  Future<void> _handleRefresh() async {
    print('🔄 Manual refresh triggered');
    _loadAllData();
    // Wait a bit for the refresh animation
    await Future.delayed(Duration(milliseconds: 500));
  }

  void _handleTabNavigation(int index) {
    _model.bottomadded = index;
    safeSetState(() {});
    _model.pageViewController?.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    
    // Refresh data when switching to certain tabs
    if (index == 0) { // Home tab
      _refreshDataIfNeeded();
    } else if (index == 1) { // Order tab
      loadUserOrders();
    } else if (index == 2) { // Favorite tab
      loadFavoriteProducts();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FFAppState().removeListener(onAppStateChange);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _model.pageViewController ??= PageController(initialPage: 0),
                      onPageChanged: (_) async {
                        FFAppState().bottomindex = _model.pageViewCurrentIndex;
                        FFAppState().update(() {});
                        _model.bottomadded = _model.pageViewCurrentIndex;
                        safeSetState(() {});
                      },
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Home Tab with RefreshIndicator
                        RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: HomeTabWidget(
                            model: _model,
                            animationsMap: animationsMap,
                            categories: categories,
                            isLoadingCategory: isLoadingCategory,
                            categoryError: categoryError,
                            justForYouProducts: justForYouProducts,
                            newArrivalProducts: newArrivalProducts,
                            isLoadingProducts: isLoadingProducts,
                            productsError: productsError,
                            userName: userName,
                            isLoadingUser: isLoadingUser,
                            onReloadFavorites: () => loadFavoriteProducts(),
                          ),
                        ),
                        
                        // Order Tab with RefreshIndicator
                        RefreshIndicator(
                          onRefresh: () async {
                            await loadUserOrders();
                            await Future.delayed(Duration(milliseconds: 500));
                          },
                          child: OrderTabWidget(
                            model: _model,
                            animationsMap: animationsMap,
                            activeOrders: activeOrders,
                            completedOrders: completedOrders,
                            isLoadingOrders: isLoadingOrders,
                            ordersError: ordersError,
                          ),
                        ),
                        
                        // Favorite Tab with RefreshIndicator
                        RefreshIndicator(
                          onRefresh: () async {
                            await loadFavoriteProducts();
                            await Future.delayed(Duration(milliseconds: 500));
                          },
                          child: FavoriteTabWidget(
                            model: _model,
                            animationsMap: animationsMap,
                            favoriteProducts: favoriteProducts,
                            isLoadingFavorites: isLoadingFavorites,
                            favoritesError: favoritesError,
                            onReloadFavorites: () => loadFavoriteProducts(),
                          ),
                        ),
                        
                        // Profile Tab
                        ProfileTabWidget(
                          animationsMap: animationsMap,
                          userName: userName,
                          isLoadingUser: isLoadingUser,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavigationWidget(
                model: _model,
                currentIndex: _model.bottomadded,
                onTap: _handleTabNavigation,
              ),
            ),
            
            // Chat Bubble
            ChatBubbleWidget(
              isDraggable: true,
              size: 60.0,
              onTap: () {
                context.pushNamed(ChatPageWidget.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
