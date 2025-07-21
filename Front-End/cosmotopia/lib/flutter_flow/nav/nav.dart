import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';
import '/backend/api_service.dart';
import 'package:http/http.dart' as http;
import '/profile/admin_page/admin_page_widget.dart';
import '/profile/admin_page/product_management_page_widget.dart';
import '/profile/admin_page/user_management_page_widget.dart';
import '/profile/admin_page/analytics_reports_page_widget.dart';
import '/profile/admin_page/order_management_page_widget.dart';
import '/profile/admin_page/payment_management_page_widget.dart';
import '/cart/payment_success_page/payment_success_page_widget.dart';
import '/cart/payment_cancel_page/payment_cancel_page_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/splashPage',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      redirect: (context, state) {
        print('🌐 ROUTER DEBUG: Navigating to ${state.uri}');
        print('🌐 ROUTER DEBUG: Path: ${state.uri.path}');
        print('🌐 ROUTER DEBUG: Query: ${state.uri.query}');
        return null; // No redirect, let normal routing happen
      },
      errorBuilder: (context, state) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                child: Image.asset(
                  'assets/images/01_Splash_Screen.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : SignInPageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    child: Image.asset(
                      'assets/images/01_Splash_Screen.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : SignInPageWidget(),
          routes: [
            FFRoute(
              name: SplashPageWidget.routeName,
              path: SplashPageWidget.routePath,
              builder: (context, params) => SplashPageWidget(),
            ),
            FFRoute(
              name: OnbordingPageWidget.routeName,
              path: OnbordingPageWidget.routePath,
              builder: (context, params) => OnbordingPageWidget(),
            ),
            FFRoute(
              name: SignInPageWidget.routeName,
              path: SignInPageWidget.routePath,
              builder: (context, params) => SignInPageWidget(),
            ),
            FFRoute(
              name: SignUpPageWidget.routeName,
              path: SignUpPageWidget.routePath,
              builder: (context, params) => SignUpPageWidget(),
            ),
            FFRoute(
              name: OtpVerificationPageWidget.routeName,
              path: OtpVerificationPageWidget.routePath,
              builder: (context, params) => OtpVerificationPageWidget(
                email: params.getParam('email', ParamType.String) ?? '',
              ),
            ),
            FFRoute(
              name: ForgotPasswordPageWidget.routeName,
              path: ForgotPasswordPageWidget.routePath,
              builder: (context, params) => ForgotPasswordPageWidget(),
            ),
            FFRoute(
              name: ProfilePageWidget.routeName,
              path: ProfilePageWidget.routePath,
              builder: (context, params) => ProfilePageWidget(),
            ),
            FFRoute(
              name: MyProfilePageWidget.routeName,
              path: MyProfilePageWidget.routePath,
              builder: (context, params) => MyProfilePageWidget(),
            ),
            FFRoute(
              name: EditProfilePageWidget.routeName,
              path: EditProfilePageWidget.routePath,
              builder: (context, params) => EditProfilePageWidget(),
            ),
            FFRoute(
              name: SettingPageWidget.routeName,
              path: SettingPageWidget.routePath,
              builder: (context, params) => SettingPageWidget(),
            ),
            FFRoute(
              name: PrivacyPolicyPageWidget.routeName,
              path: PrivacyPolicyPageWidget.routePath,
              builder: (context, params) => PrivacyPolicyPageWidget(),
            ),
            FFRoute(
              name: TermsConditionPageWidget.routeName,
              path: TermsConditionPageWidget.routePath,
              builder: (context, params) => TermsConditionPageWidget(),
            ),
            FFRoute(
              name: HelpPageWidget.routeName,
              path: HelpPageWidget.routePath,
              builder: (context, params) => HelpPageWidget(),
            ),
            FFRoute(
              name: AffiliateDashboardWidget.routeName,
              path: AffiliateDashboardWidget.routePath,
              builder: (context, params) => AffiliateDashboardWidget(),
            ),
            FFRoute(
              name: GenerateLinkWidget.routeName,
              path: GenerateLinkWidget.routePath,
              builder: (context, params) => GenerateLinkWidget(),
            ),
            FFRoute(
              name: EarningsAnalyticsWidget.routeName,
              path: EarningsAnalyticsWidget.routePath,
              builder: (context, params) => EarningsAnalyticsWidget(),
            ),
            FFRoute(
              name: WithdrawalWidget.routeName,
              path: WithdrawalWidget.routePath,
              builder: (context, params) => WithdrawalWidget(),
            ),
            FFRoute(
              name: ManageLinksWidget.routeName,
              path: ManageLinksWidget.routePath,
              builder: (context, params) => ManageLinksWidget(),
            ),
            FFRoute(
              name: BottomPageWidget.routeName,
              path: BottomPageWidget.routePath,
              builder: (context, params) => BottomPageWidget(),
            ),
            FFRoute(
              name: FilterPageWidget.routeName,
              path: FilterPageWidget.routePath,
              builder: (context, params) => FilterPageWidget(),
            ),
            FFRoute(
              name: PaymentPageWidget.routeName,
              path: PaymentPageWidget.routePath,
              builder: (context, params) => PaymentPageWidget(),
            ),
            FFRoute(
              name: PaymentSuccessPageWidget.routeName,
              path: PaymentSuccessPageWidget.routePath,
              builder: (context, params) => PaymentSuccessPageWidget(
                orderCode: params.getParam('orderCode', ParamType.String),
                amount: params.getParam('amount', ParamType.String),
              ),
            ),
            FFRoute(
              name: PaymentCancelPageWidget.routeName,
              path: PaymentCancelPageWidget.routePath,
              builder: (context, params) => PaymentCancelPageWidget(
                orderCode: params.getParam('orderCode', ParamType.String),
                reason: params.getParam('reason', ParamType.String),
              ),
            ),
            FFRoute(
              name: WaterColorPageWidget.routeName,
              path: WaterColorPageWidget.routePath,
              builder: (context, params) => WaterColorPageWidget(
                title: params.getParam(
                  'title',
                  ParamType.String,
                ),
                categoryId: params.getParam(
                  'categoryId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: JustForYouPageWidget.routeName,
              path: JustForYouPageWidget.routePath,
              builder: (context, params) => JustForYouPageWidget(),
            ),
            FFRoute(
              name: NewArrivalPageWidget.routeName,
              path: NewArrivalPageWidget.routePath,
              builder: (context, params) => NewArrivalPageWidget(),
            ),
            FFRoute(
              name: ProducutDetailPageWidget.routeName,
              path: ProducutDetailPageWidget.routePath,
              builder: (context, params) => ProducutDetailPageWidget(
                detail: params.getParam(
                  'detail',
                  ParamType.DataStruct,
                  isList: false,
                  structBuilder: DetailStruct.fromSerializableMap,
                ),
              ),
            ),
            

            FFRoute(
              name: SearchPageWidget.routeName,
              path: SearchPageWidget.routePath,
              builder: (context, params) => SearchPageWidget(),
            ),
            FFRoute(
              name: TrackOrderPageWidget.routeName,
              path: TrackOrderPageWidget.routePath,
              builder: (context, params) => TrackOrderPageWidget(),
            ),
            FFRoute(
              name: EditAddressPageWidget.routeName,
              path: EditAddressPageWidget.routePath,
              builder: (context, params) => EditAddressPageWidget(),
            ),
            FFRoute(
              name: VerificationPageWidget.routeName,
              path: VerificationPageWidget.routePath,
              builder: (context, params) => VerificationPageWidget(),
            ),
            FFRoute(
              name: ResetPasswordPageWidget.routeName,
              path: ResetPasswordPageWidget.routePath,
              builder: (context, params) => ResetPasswordPageWidget(),
            ),
            FFRoute(
              name: CategoriesPageWidget.routeName,
              path: CategoriesPageWidget.routePath,
              builder: (context, params) => CategoriesPageWidget(),
            ),
            FFRoute(
              name: CheckOutPageWidget.routeName,
              path: CheckOutPageWidget.routePath,
              builder: (context, params) => CheckOutPageWidget(),
            ),
            FFRoute(
              name: CartPageWidget.routeName,
              path: CartPageWidget.routePath,
              builder: (context, params) => CartPageWidget(),
            ),
            FFRoute(
              name: NotificationPageWidget.routeName,
              path: NotificationPageWidget.routePath,
              builder: (context, params) => NotificationPageWidget(),
            ),
            FFRoute(
              name: SearchResultWidget.routeName,
              path: SearchResultWidget.routePath,
              builder: (context, params) => SearchResultWidget(
                searchQuery: params.getParam(
                  'searchQuery',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: AboutusPageWidget.routeName,
              path: AboutusPageWidget.routePath,
              builder: (context, params) => AboutusPageWidget(),
            ),
            FFRoute(
              name: SecurityPageWidget.routeName,
              path: SecurityPageWidget.routePath,
              builder: (context, params) => SecurityPageWidget(),
            ),
            FFRoute(
              name: ChangePasswordPageWidget.routeName,
              path: ChangePasswordPageWidget.routePath,
              builder: (context, params) => ChangePasswordPageWidget(),
            ),
            FFRoute(
              name: ChatPageWidget.routeName,
              path: ChatPageWidget.routePath,
              builder: (context, params) => ChatPageWidget(),
            ),
            FFRoute(
              name: AiBeautyScannerWidget.routeName,
              path: AiBeautyScannerWidget.routePath,
              builder: (context, params) => AiBeautyScannerWidget(),
            ),
            FFRoute(
              name: AdminPageWidget.routeName,
              path: AdminPageWidget.routePath,
              builder: (context, params) => AdminPageWidget(),
            ),
            FFRoute(
              name: ProductManagementPageWidget.routeName,
              path: ProductManagementPageWidget.routePath,
              builder: (context, params) => ProductManagementPageWidget(),
            ),
            FFRoute(
              name: UserManagementPageWidget.routeName,
              path: UserManagementPageWidget.routePath,
              builder: (context, params) => UserManagementPageWidget(),
            ),
            FFRoute(
              name: AnalyticsReportsPageWidget.routeName,
              path: AnalyticsReportsPageWidget.routePath,
              builder: (context, params) => AnalyticsReportsPageWidget(),
            ),
            FFRoute(
              name: OrderManagementPageWidget.routeName,
              path: OrderManagementPageWidget.routePath,
              builder: (context, params) => OrderManagementPageWidget(),
            ),
            FFRoute(
              name: PaymentManagementPageWidget.routeName,
              path: PaymentManagementPageWidget.routePath,
              builder: (context, params) => PaymentManagementPageWidget(),
            ),
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
        
        // Deep link route for affiliate product links - Independent route  
        FFRoute(
          name: 'AffiliateProductDetail',
          path: '/Product/affiliate/:productId',
          builder: (context, params) {
            final productId = params.getParam('productId', ParamType.String);
            final ref = params.getParam('ref', ParamType.String);
            
            // Try to get referral code from multiple parameter names (backend might use different names)
            final referralCodeFromQuery = params.state.uri.queryParameters['referralCode'] ?? 
                                         params.state.uri.queryParameters['affiliate_id'];
            
            print('🔗 =================================');
            print('🔗 DEEP LINK HANDLER TRIGGERED');
            print('🔗 Deep link accessed: productId=$productId, ref=$ref');
            print('🔗 referralCode from query: $referralCodeFromQuery');
            print('🔗 Deep link route matched successfully!');
            
            // Debug: Log all available parameters
            print('🔍 DEBUG: All path parameters: ${params.state.pathParameters}');
            print('🔍 DEBUG: All query parameters: ${params.state.uri.queryParameters}');
            print('🔍 DEBUG: All params: ${params.state.allParams}');
            print('🔍 DEBUG: Full URI: ${params.state.uri}');
            
            // Check if user is logged in
            final appState = context.read<FFAppState>();
            print('🔗 DEBUG: Current login status: ${appState.islogin}');
            print('🔗 DEBUG: Current token: ${appState.token.isEmpty ? "EMPTY" : "SET"}');
            print('🔗 =================================');
            
            if (!appState.islogin) {
              // User not logged in, save intended route for after login
              // Try to get referral code from multiple parameter names
              final referralCode = ref ?? 
                                  params.state.uri.queryParameters['referralCode'] ?? 
                                  params.state.uri.queryParameters['affiliate_id'];
              
              final intendedPath = '/Product/affiliate/$productId${referralCode != null ? '?ref=$referralCode' : ''}';
              
              print('🔗 USER NOT LOGGED IN - Saving intended route');
              print('🔗 Referral code found: $referralCode');
              print('🔗 Intended path to save: $intendedPath');
              
              // Use WidgetsBinding to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                appState.intendedRoute = intendedPath;
                print('🔗 DEBUG: Intended route saved successfully');
                print('🔗 DEBUG: Current value in appState: "${appState.intendedRoute}"');
                print('🔗 DEBUG: Length: ${appState.intendedRoute.length}');
                print('🔗 DEBUG: isEmpty: ${appState.intendedRoute.isEmpty}');
              });
              
              // Track the affiliate click if referral code is present (even if not logged in)
              if (referralCode != null && referralCode.isNotEmpty) {
                _trackAffiliateClick(referralCode);
              }
              
              // Redirect to sign in page
              return SignInPageWidget();
            }
            
            // User is logged in, proceed with normal flow
            print('🔗 User already logged in - proceeding with normal flow');
            
            // Try to get referral code from multiple parameter names
            final referralCode = ref ?? 
                                params.state.uri.queryParameters['referralCode'] ?? 
                                params.state.uri.queryParameters['affiliate_id'];
            
            // Track the affiliate click if referral code is present
            if (referralCode != null && referralCode.isNotEmpty) {
              print('🔗 Tracking affiliate click for referral: $referralCode');
              _trackAffiliateClick(referralCode);
            }
            
            // Navigate to product detail page by product ID
            return FutureBuilder(
              future: _loadProductDetail(productId ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasData && snapshot.data != null) {
                  return ProducutDetailPageWidget(detail: snapshot.data!);
                }
                
                // Fallback to bottom page if product not found
                return BottomPageWidget();
              },
            );
          },
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the appropriate
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      // Check if user is logged in to determine where to go
      final appState = read<FFAppState>();
      if (appState.islogin) {
        // User is logged in, go to home page
        print('🔙 No route to pop, navigating to home page');
        go('/bottomPage');
      } else {
        // User not logged in, go to initial page
        print('🔙 No route to pop, navigating to initial page');
        go('/');
      }
    }
  }
}

// Helper function to track affiliate clicks from deep links
Future<void> _trackAffiliateClick(String referralCode) async {
  try {
    print('🔗 Tracking affiliate click for referral: $referralCode');
    
    // Lấy token từ FFAppState
    final appState = FFAppState(); // Có thể cần context ở đây
    final token = appState.token;
    
    if (token.isEmpty) {
      print('⚠️ No token available, tracking affiliate click without authentication');
      // Vẫn có thể track click nhưng không có userId
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5192/api/Affiliate/track-click?referralCode=$referralCode'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        print('✅ Affiliate click tracked successfully (anonymous)');
      } else {
        print('❌ Failed to track affiliate click: ${response.statusCode}');
      }
      return;
    }
    
    final response = await ApiService.trackAffiliateClick(
      referralCode: referralCode,
      token: token,
    );
    
    if (response.statusCode == 200) {
      print('✅ Affiliate click tracked successfully from deep link');
    } else {
      print('❌ Failed to track affiliate click: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error tracking affiliate click from deep link: $e');
  }
}

// Helper function to load product detail by ID
Future<DetailStruct?> _loadProductDetail(String productId) async {
  try {
    print('🔍 Loading product detail for ID: $productId');
    final response = await ApiService.getProductById(productId);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔍 Product API response: $data');
      
      // Try different response formats
      Map<String, dynamic>? productData;
      
      if (data is Map<String, dynamic>) {
        productData = data['product'] ?? data['data'] ?? data;
      } else if (data is List && data.isNotEmpty) {
        productData = data[0];
      }
      
      if (productData != null) {
        // Transform API response to DetailStruct compatible format
        final transformedData = _transformProductData(productData);
        return DetailStruct.fromMap(transformedData);
      }
    }
    
    print('❌ Product not found for ID: $productId (Status: ${response.statusCode})');
    return null;
  } catch (e) {
    print('❌ Error loading product detail: $e');
    return null;
  }
}

// Transform API response to DetailStruct compatible format
Map<String, dynamic> _transformProductData(Map<String, dynamic> apiData) {
  return {
    'productId': apiData['productId'] ?? '',
    'title': apiData['name'] ?? '',  // API uses 'name', DetailStruct uses 'title'
    'description': apiData['description'] ?? '',
    'price': _formatPrice(apiData['price']),  // Convert double to int String
    'stockQuantity': apiData['stockQuantity']?.toString() ?? '0',  // Convert int to String
    'image': _getFirstImageUrl(apiData['imageUrls']),  // Extract first image URL
    'catetype': _getCategoryName(apiData['category']),  // Extract category name
    'brandName': _getBrandName(apiData['brand']),  // Extract brand name
    // Set defaults for other fields
    'is_fav': false,
    'is_just': false,
    'is_new': false,
    'is_cart': false,
    'is_color': false,
  };
}

String _getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls is List && imageUrls.isNotEmpty) {
    return imageUrls[0].toString();
  }
  return '';
}

String _getCategoryName(dynamic category) {
  if (category is Map<String, dynamic>) {
    return category['name']?.toString() ?? '';
  }
  return '';
}

String _getBrandName(dynamic brand) {
  if (brand is Map<String, dynamic>) {
    return brand['name']?.toString() ?? '';
  }
  return '';
}

String _formatPrice(dynamic price) {
  if (price == null) return '0';
  
  // Convert to double first, then to int, then to string
  if (price is num) {
    return price.toInt().toString();
  }
  
  // Try to parse if it's a string
  final doublePrice = double.tryParse(price.toString());
  if (doublePrice != null) {
    return doublePrice.toInt().toString();
  }
  
  return '0';
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
