import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _isintro = prefs.getBool('ff_isintro') ?? _isintro;
    });
    _safeInit(() {
      _islogin = prefs.getBool('ff_islogin') ?? _islogin;
    });
    _safeInit(() {
      _introindex = prefs.getInt('ff_introindex') ?? _introindex;
    });
    _safeInit(() {
      _phone = prefs.getString('ff_phone') ?? _phone;
    });
    _safeInit(() {
      _countryCode = prefs.getString('ff_countryCode') ?? _countryCode;
    });
    _safeInit(() {
      _firstname = prefs.getString('ff_firstname') ?? _firstname;
    });
    _safeInit(() {
      _emailaddress = prefs.getString('ff_emailaddress') ?? _emailaddress;
    });
    _safeInit(() {
      _phonenumber = prefs.getString('ff_phonenumber') ?? _phonenumber;
    });
    _safeInit(() {
      _favoriteProductIds = prefs.getStringList('ff_favoriteProductIds') ?? _favoriteProductIds;
    });
    _safeInit(() {
      _userRole = prefs.getString('ff_userRole') ?? _userRole;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<String> _favoriteProductIds = [];
  List<String> get favoriteProductIds => _favoriteProductIds;
  set favoriteProductIds(List<String> value) {
    _favoriteProductIds = value;
    prefs.setStringList('ff_favoriteProductIds', value);
  }

  String _userRole = '';
  String get userRole => _userRole;
  set userRole(String value) {
    _userRole = value;
    prefs.setString('ff_userRole', value);
  }

  // Store intended route for deep links when user is not logged in
  String _intendedRoute = '';
  String get intendedRoute => _intendedRoute;
  set intendedRoute(String value) {
    _intendedRoute = value;
    notifyListeners();
  }

  // Clear intended route after navigation
  void clearIntendedRoute() {
    _intendedRoute = '';
    notifyListeners();
  }

  void addToFavoriteProductIds(String productId) {
    if (!_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.add(productId);
      prefs.setStringList('ff_favoriteProductIds', _favoriteProductIds);
      notifyListeners();
    }
  }

  void removeFromFavoriteProductIds(String productId) {
    _favoriteProductIds.remove(productId);
    prefs.setStringList('ff_favoriteProductIds', _favoriteProductIds);
    notifyListeners();
  }

  bool isProductFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  bool _isintro = false;
  bool get isintro => _isintro;
  set isintro(bool value) {
    _isintro = value;
    prefs.setBool('ff_isintro', value);
  }

  bool _islogin = false;
  bool get islogin => _islogin;
  set islogin(bool value) {
    _islogin = value;
    prefs.setBool('ff_islogin', value);
  }

  int _introindex = 0;
  int get introindex => _introindex;
  set introindex(int value) {
    _introindex = value;
    prefs.setInt('ff_introindex', value);
  }
  // List<CategoryStruct> _categorylist = [
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"0\",\"name\":\"Calculator\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/b52ejrgmsw5v/cal.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"1\",\"name\":\"Pencil\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/cjmx9nig7gce/pencile.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"2\",\"name\":\"Note Book\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/zozfsbjb59ls/book.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"3\",\"name\":\"Eraser\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/jajucxo4oqof/eeraser.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"4\",\"name\":\"Water Color\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/oi2l9dx09pji/color.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"5\",\"name\":\"File\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/zr0jf7dp2ib9/file.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"6\",\"name\":\"Scissor\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/zcwexa29kjxr/scissors.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"7\",\"name\":\"Sharpener\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/kfbr7gmq21ap/sharpner.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"8\",\"name\":\"Drawing Pin\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/yw90we81c5pz/pin.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"9\",\"name\":\"Stapler\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/u2t0lxsmfiy0/stapler.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"10\",\"name\":\"Paper Clip\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/ywfzvnvadt1m/peper_clip.png\"}')),
  //   CategoryStruct.fromSerializableMap(jsonDecode(
  //       '{\"id\":\"11\",\"name\":\"Calendar\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/a07r8w2um191/calendar.png\"}'))
  // ];
  List<CategoryStruct> _categorylist = [];
  List<CategoryStruct> get categorylist => _categorylist;
  set categorylist(List<CategoryStruct> value) {
    _categorylist = value;
    notifyListeners();
  }

  void addToCategorylist(CategoryStruct value) {
    categorylist.add(value);
  }

  void removeFromCategorylist(CategoryStruct value) {
    categorylist.remove(value);
  }

  void removeAtIndexFromCategorylist(int index) {
    categorylist.removeAt(index);
  }

  void updateCategorylistAtIndex(
    int index,
    CategoryStruct Function(CategoryStruct) updateFn,
  ) {
    categorylist[index] = updateFn(_categorylist[index]);
  }

  void insertAtIndexInCategorylist(int index, CategoryStruct value) {
    categorylist.insert(index, value);
  }

  List<DetailStruct> _detaillist = [
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"0\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/ndvdb37d9oe2/color1.png\",\"title\":\"Camel Water Color\",\"price\":\"\$20.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_cart\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"1\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/zm7kt4fl3w5d/color2.png\",\"title\":\"Paint and pencils\",\"price\":\"\$10.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_cart\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"2\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/8l823phsumdv/color3.png\",\"title\":\"Colourful rainbow...\",\"price\":\"\$12.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"3\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/thebhvr6ow80/color4.png\",\"title\":\"The paint, brushes\",\"price\":\"\$15.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"4\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/glyic9fcsmw6/color5.png\",\"title\":\"Camel Water Color\",\"price\":\"\$20.50\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"5\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/i65xijkrrkma/color6.png\",\"title\":\"wooden surface...\",\"price\":\"\$15.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"6\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/mlwqew98ucym/color7.png\",\"title\":\"Office accessories\",\"price\":\"\$22.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"0\",\"id\":\"7\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/ua5s2cihebfg/color8.png\",\"title\":\"Props on table\",\"price\":\"\$10.00\",\"catetype\":\"Water Color\",\"is_fav\":\"false\",\"is_color\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"8\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/lumveram2vwr/jfy1.png\",\"title\":\"Still life of drawing\",\"price\":\"\$40.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"9\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/crqxm14b87ej/jfy2.png\",\"title\":\"Camel Water Color\",\"price\":\"\$20.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"10\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/a78f4e37eqag/jst3.png\",\"title\":\"Sticky note\",\"price\":\"\$10.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"11\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/c09ri08g3qv5/jfy4.png\",\"title\":\"Cup of color pencils\",\"price\":\"\$15.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"12\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/bbj67b6dv7ug/jfy6.png\",\"title\":\"My First Hindi Words\",\"price\":\"\$26.50\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"13\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/s48z726kwvgo/jfy7.png\",\"title\":\"Pens in a basket\",\"price\":\"\$26.50\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"14\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/rb80dakr60y6/jfy8.png\",\"title\":\"Office accessories\",\"price\":\"\$22.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"1\",\"id\":\"15\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/1cyldajsiyom/jfy9.png\",\"title\":\"Stapler and stamp\",\"price\":\"\$10.00\",\"catetype\":\"Just for you\",\"is_fav\":\"false\",\"is_just\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"2\",\"id\":\"16\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/be0o4vsyl5ba/new1.png\",\"title\":\"School supplies on a background Top\",\"price\":\"\$20.50\",\"catetype\":\"New Arrivals\",\"is_fav\":\"false\",\"is_new\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"2\",\"id\":\"17\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/3mgaqdnop45d/new2.png\",\"title\":\"Art & Craft Masking Tape\",\"price\":\"\$17.00\",\"catetype\":\"New Arrivals\",\"is_fav\":\"false\",\"is_new\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"2\",\"id\":\"18\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/a419pyil8zva/new3.png\",\"title\":\"Office stationery with glue\",\"price\":\"\$22.50\",\"catetype\":\"New Arrivals\",\"is_fav\":\"false\",\"is_new\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"2\",\"id\":\"19\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/be0o4vsyl5ba/new1.png\",\"title\":\"School supplies on a background Top\",\"price\":\"\$20.50\",\"catetype\":\"New Arrivals\",\"is_fav\":\"false\",\"is_new\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"20\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/pciydsjrr34e/r1.png\",\"title\":\"Pens in a basket\",\"price\":\"\$10.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"21\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/pgy8vi2dqb8d/r2.png\",\"title\":\"Stylish a pen\",\"price\":\"\$10.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"22\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/ckwi9b35dn1d/r3.png\",\"title\":\"3d rendering of pen\",\"price\":\"\$20.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"23\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/pzn882ls5oxs/r4.png\",\"title\":\"Blue pen\",\"price\":\"\$10.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"24\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/wbg8nuvo65sl/r5.png\",\"title\":\"Luxury stationery\",\"price\":\"\$8.50\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"25\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/k86vp1gl1djn/r6.png\",\"title\":\"Business fountain..\",\"price\":\"\$12.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"26\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/2qqx3r0li5c6/r7.png\",\"title\":\"Pens in a basket\",\"price\":\"\$10.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}')),
    DetailStruct.fromSerializableMap(jsonDecode(
        '{\"prid\":\"3\",\"id\":\"27\",\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/zrayiqan0pcs/r8.png\",\"title\":\"Cup of color pencils\",\"price\":\"\$15.00\",\"catetype\":\"Search Result\",\"is_fav\":\"false\",\"is_just\":\"false\",\"is_new\":\"false\",\"is_cart\":\"false\",\"is_color\":\"false\",\"is_result\":\"Hello World\",\"its_result\":\"true\"}'))
  ];
  List<DetailStruct> get detaillist => _detaillist;
  set detaillist(List<DetailStruct> value) {
    _detaillist = value;
  }

  void addToDetaillist(DetailStruct value) {
    detaillist.add(value);
  }

  void removeFromDetaillist(DetailStruct value) {
    detaillist.remove(value);
  }

  void removeAtIndexFromDetaillist(int index) {
    detaillist.removeAt(index);
  }

  void updateDetaillistAtIndex(
    int index,
    DetailStruct Function(DetailStruct) updateFn,
  ) {
    detaillist[index] = updateFn(_detaillist[index]);
  }

  void insertAtIndexInDetaillist(int index, DetailStruct value) {
    detaillist.insert(index, value);
  }

  List<DetailStruct> _orderlist = [];
  List<DetailStruct> get orderlist => _orderlist;
  set orderlist(List<DetailStruct> value) {
    _orderlist = value;
  }

  void addToOrderlist(DetailStruct value) {
    orderlist.add(value);
  }

  void removeFromOrderlist(DetailStruct value) {
    orderlist.remove(value);
  }

  void removeAtIndexFromOrderlist(int index) {
    orderlist.removeAt(index);
  }

  void updateOrderlistAtIndex(
    int index,
    DetailStruct Function(DetailStruct) updateFn,
  ) {
    orderlist[index] = updateFn(_orderlist[index]);
  }

  void insertAtIndexInOrderlist(int index, DetailStruct value) {
    orderlist.insert(index, value);
  }

  int _bottomindex = 0;
  int get bottomindex => _bottomindex;
  set bottomindex(int value) {
    _bottomindex = value;
  }

  int _lastClickTrackedAt = 0;
  int get lastClickTrackedAt => _lastClickTrackedAt;
  set lastClickTrackedAt(int value) {
    _lastClickTrackedAt = value;
  }

  List<NotificationDataStruct> _notificationlist = [
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/g6za5jys5upp/no1.png\",\"titile\":\"Booking Successful!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"1 hr ago\"}')),
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/yelvaym3d1zn/no2.png\",\"titile\":\"Forgot Password Successful!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"2 hr ago\"}')),
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/94sgl26ci68c/no3.png\",\"titile\":\"Credit Card Connected!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"3 hr ago\"}')),
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/fndp6lwwh47f/no4.png\",\"titile\":\"Account Setup Sucessfully!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"2 hr ago\"}')),
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/g6za5jys5upp/no1.png\",\"titile\":\"Order Successful!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"1 hr ago\"}')),
    NotificationDataStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/stationery-ecommerce-app-dev-21z202/assets/g6za5jys5upp/no1.png\",\"titile\":\"Booking Successful!\",\"message\":\"You have successfully booked the Art Workshops. \",\"time\":\"2 hr ago\"}'))
  ];
  List<NotificationDataStruct> get notificationlist => _notificationlist;
  set notificationlist(List<NotificationDataStruct> value) {
    _notificationlist = value;
  }

  void addToNotificationlist(NotificationDataStruct value) {
    notificationlist.add(value);
  }

  void removeFromNotificationlist(NotificationDataStruct value) {
    notificationlist.remove(value);
  }

  void removeAtIndexFromNotificationlist(int index) {
    notificationlist.removeAt(index);
  }

  void updateNotificationlistAtIndex(
    int index,
    NotificationDataStruct Function(NotificationDataStruct) updateFn,
  ) {
    notificationlist[index] = updateFn(_notificationlist[index]);
  }

  void insertAtIndexInNotificationlist(
      int index, NotificationDataStruct value) {
    notificationlist.insert(index, value);
  }

  List<String> _searchlist = [];
  List<String> get searchlist => _searchlist;
  set searchlist(List<String> value) {
    _searchlist = value;
  }

  void addToSearchlist(String value) {
    searchlist.add(value);
  }

  void removeFromSearchlist(String value) {
    searchlist.remove(value);
  }

  void removeAtIndexFromSearchlist(int index) {
    searchlist.removeAt(index);
  }

  void updateSearchlistAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    searchlist[index] = updateFn(_searchlist[index]);
  }

  void insertAtIndexInSearchlist(int index, String value) {
    searchlist.insert(index, value);
  }

  String _phone = '9952696528';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
    prefs.setString('ff_phone', value);
  }

  String _countryCode = '';
  String get countryCode => _countryCode;
  set countryCode(String value) {
    _countryCode = value;
    prefs.setString('ff_countryCode', value);
  }

  String _firstname = '';
  String get firstname => _firstname;
  set firstname(String value) {
    _firstname = value;
    prefs.setString('ff_firstname', value);
  }

  String _emailaddress = '';
  String get emailaddress => _emailaddress;
  set emailaddress(String value) {
    _emailaddress = value;
    prefs.setString('ff_emailaddress', value);
  }

  String _phonenumber = '';
  String get phonenumber => _phonenumber;
  set phonenumber(String value) {
    _phonenumber = value;
    prefs.setString('ff_phonenumber', value);
  }

  String _token = '';
  String get token => _token;
  set token(String value) {
    _token = value;
    // Nếu muốn lưu vào SharedPreferences, thêm dòng sau:
    // prefs.setString('ff_token', value);
  }

  List<ProductStruct> _productlist = [];
  List<ProductStruct> get productlist => _productlist;
  set productlist(List<ProductStruct> value) {
    _productlist = value;
    notifyListeners();
  }

  void addToProductlist(ProductStruct value) {
    productlist.add(value);
  }

  void removeFromProductlist(ProductStruct value) {
    productlist.remove(value);
  }

  void removeAtIndexFromProductlist(int index) {
    productlist.removeAt(index);
  }

  void updateProductlistAtIndex(
    int index,
    ProductStruct Function(ProductStruct) updateFn,
  ) {
    productlist[index] = updateFn(_productlist[index]);
  }

  void insertAtIndexInProductlist(int index, ProductStruct value) {
    productlist.insert(index, value);
  }

  String _address = '';
  String get address => _address;
  set address(String value) {
    _address = value;
    prefs.setString('ff_address', value);
  }

  // Shipping and tax information for checkout
  int _shippingFee = 0;
  int get shippingFee => _shippingFee;
  set shippingFee(int value) {
    _shippingFee = value;
  }

  int _calculatedTax = 0;
  int get calculatedTax => _calculatedTax;
  set calculatedTax(int value) {
    _calculatedTax = value;
  }

  // Data refresh flags
  bool _needsDataRefresh = false;
  bool get needsDataRefresh => _needsDataRefresh;
  
  void triggerDataRefresh() {
    _needsDataRefresh = true;
    notifyListeners();
    print('🔄 FFAppState: Data refresh triggered');
  }
  
  void clearDataRefreshFlag() {
    _needsDataRefresh = false;
  }
  
  // Specific refresh flags
  bool _needsProductRefresh = false;
  bool get needsProductRefresh => _needsProductRefresh;
  
  void triggerProductRefresh() {
    _needsProductRefresh = true;
    triggerDataRefresh(); // Also trigger general refresh
    print('🔄 FFAppState: Product refresh triggered');
  }
  
  void clearProductRefreshFlag() {
    _needsProductRefresh = false;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
