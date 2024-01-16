recently_view_response_model.dart
```dart
import 'package:flutter/rendering.dart';

import '../../post/post_data/post_model.dart';

class RecentlyViewedResponse {
  final Map<String, dynamic>? data;
  final String message;
  final String status;
  final int statusCode;
  final TermData postsInfo;

  RecentlyViewedResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.statusCode,
    required this.postsInfo,
  });

  factory RecentlyViewedResponse.fromJson(
      {required Map<String, dynamic> data, required int statusCode}) {
    TermData postInfo = TermData.fromJson(data['data']);

    return RecentlyViewedResponse(
      data: data['data'] ?? {},
      message: data['message'],
      status: data['status'].toString(),
      statusCode: statusCode,
      postsInfo: postInfo,
    );
  }
}

class TermData {
  final List<dynamic> filterList;
  final int totalCount;
  final List<Post> posts;

  TermData({
    required this.filterList,
    required this.totalCount,
    required this.posts,
  });

  factory TermData.fromJson(Map<String, dynamic> json) {
    return TermData(
      filterList: json['filter_list'],
      totalCount: json['total_count'],
      posts: List<Post>.from(json['posts'].map((x) => Post.fromJson(x))),
    );
  }

  Map<String, dynamic> fromJson() {
    return {
      'filter_list': filterList,
      'total_count': totalCount,
      'posts': List<Post>.from(posts.map((el) => el.toJson()))
    };
  }
}

```





mypage_provider.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/mypage/settings/blocked_user_response.dart';
import '../../models/mypage/mypost_response_model.dart';
import '../../models/home/global_model.dart';
import '../../models/mypage/recent/recently_view_response_model.dart';
import '../../models/mypage/subscribe/subscribe_tag_response.dart';
import '../../models/mypage/profile/user_change_response.dart';
import '../../models/mypage/profile/user_check_response.dart';
import '../../models/user/user_model.dart';
import '../../service/auth_service.dart';

/// 마이페이지 프로바이더
class MyPageProvider with DioMixin implements Dio {
  final Dio dio = Dio(
    BaseOptions(
      maxRedirects: 5,
      connectTimeout: 60000,
      sendTimeout: 60 * 1000,
      receiveTimeout: 60 * 1000,
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    ),
  );
  late Response<Map<String, dynamic>> response;

  MyPageProvider() {
    Map<String, dynamic> headers = {
      'system-key': "${dotenv.env['APP_HEADER_SYSTEM_KEY']}",
    };

    if (AuthService.to.isLogin.value) {
      headers['Authorization'] = 'Bearer ${AuthService.to.accessToken}';
    }

    dio.options.headers = headers;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        return handler.next(e);
      },
    ));
  }

  /// 태그 조회 프로바이더 핸들러
  /// [method] String
  /// [bool] orderBy
  /// [requestModel] dynamic
  Future<SubscribeTagResponse> MYTAG({
    required String method,
    bool orderBy = false,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/mytag";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response = await dio.get(orderBy ? '?orderTypeCd=POPULAR' : '');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }
      return SubscribeTagResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  Future<SubscribeTagResponse> UpdateFilter({
    bool orderBy = false,
    String tagFilterCd = '',
    String order = '',
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/mytag";
      response = await dio.get(orderBy
          ? '?orderTypeCd=POPULAR&tagFilterCd=$tagFilterCd'
          : '?tagFilterCd=$tagFilterCd');
      return SubscribeTagResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  Future<SubscribeTagResponse> loadMoreTags({
    String cursorId = '',
    String filterCd = '',
    bool orderBy = false,
  }) async {
    String? order = orderBy ? '&orderTypeCd=POPULAR' : '';

    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/mytag";
      if (filterCd.isEmpty) {
        response = await dio.get('?cursorId=$cursorId$order');
      } else {
        response =
            await dio.get('?cursorId=$cursorId&tagFilterCd=$filterCd$order');
      }
      return SubscribeTagResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 포스트 조회 프로바이더 핸들러
  /// [method] String
  /// [bool] orderBy
  /// [requestModel] dynamic
  Future<MyPostResponse> MYPOST({
    required String method,
    bool orderBy = false,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/mypost";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response = await dio.get(orderBy ? '?orderTypeCd=POPULAR' : '');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }

      return MyPostResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  Future<MyPostResponse> libraryPost({
    String tagId = '',
    String? cursorId,
    dynamic requestModel,
    String orderTypeCd = '',
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/mypost";

      tagId.isNotEmpty
          ? response = await dio
              .get('?tagId=$tagId&cursorId=$cursorId&orderTypeCd=$orderTypeCd')
          : response =
              await dio.get('?cursorId=$cursorId&orderTypeCd=$orderTypeCd');

      return MyPostResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 최근 조회 프로바이더 핸들러
  /// [method] String
  /// [cursorId] String?
  /// [requestModel] dynamic
  Future<RecentlyViewedResponse> RECENTLY({
    required String method,
    String? cursorId,
    dynamic requestModel,
  }) async {
    try {
      // dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/recently";
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/mypage/myRecently";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response =
              await dio.get(cursorId != null ? '?cursorId=$cursorId' : '');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }

      return RecentlyViewedResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 패스워드 변경 핸들러
  /// [method] String
  /// [requestModel] dynamic
  Future<GlobalBaseResponse> CHANGE_PASSWORD({
    required String method,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl =
          "${dotenv.env["APP_SERVER_API"]}/member/change_password";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response = await dio.get('');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }

      return GlobalBaseResponse.fromJson(
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 유저 이름 체크 프로바이더 핸들러
  /// [method] String
  /// [requestModel] dynamic

  Future<UserCheckResponse> USER_CHECK({
    required String method,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/member/user_check";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response = await dio.get('');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }

      return UserCheckResponse.fromJson(
        statusCode: response.statusCode!,
        data: response.data!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 회원 탈퇴 프로바이더 핸들러
  /// [method] String
  /// [requestModel] dynamic
  Future<bool> USER_WITHDRAWAL({
    required String method,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl =
          "${dotenv.env["APP_SERVER_API"]}/member/user_withdrawal";

      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);
          break;
        case 'GET':
          response = await dio.get('');
          break;
        case 'PUT':
          response = await dio.put('', data: requestModel);
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          response = await dio.delete('');
          break;
        default:
          throw Exception('Method Not Found');
      }

      if (response.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 회원정보 변경 프로바이더 핸들러
  /// [method] String
  /// [requestModel] dynamic
  Future<UserChangeResponse> USER({
    required String method,
    required dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/member/user";

      switch (method.toUpperCase()) {
        case 'POST':
          break;
        case 'GET':
          break;
        case 'PUT':
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          break;
        default:
          throw Exception('Method Not Found');
      }

      final responseModel = UserChangeResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );

      return responseModel;
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 회원정보 기본 이미지 프로바이더 핸들러
  /// [method] String
  /// [requestModel] dynamic
  Future<UserChangeResponse> DEFAULT_PROFILE_IMAGE({
    required String method,
    dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl =
          "${dotenv.env["APP_SERVER_API"]}/member/defalut_profile_image";

      switch (method.toUpperCase()) {
        case 'POST':
          break;
        case 'GET':
          break;
        case 'PUT':
          break;
        case 'PATCH':
          response = await dio.patch('', data: requestModel);
          break;
        case 'DELETE':
          break;
        default:
          throw Exception('Method Not Found');
      }

      return UserChangeResponse.fromJson(
        data: response.data!,
        statusCode: response.statusCode!,
      );
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 회원정보 기본 이미지 프로바이더 핸들러
  /// [method] String
  /// [requestModel] dynamic
  ADD_PROFILE_IMAGE({
    required String method,
    required dynamic requestModel,
  }) async {
    try {
      dio.options.baseUrl =
          "${dotenv.env["APP_SERVER_API"]}/member/add_profile_image";
      switch (method.toUpperCase()) {
        case 'POST':
          response = await dio.post('', data: requestModel);

          break;
        case 'GET':
          break;
        case 'PUT':
          break;
        case 'PATCH':
          break;
        case 'DELETE':
          break;
        default:
          throw Exception('Method Not Found');
      }
      return response;
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// 차단한 계정 가져오는 함수
  Future<List<UserModel>> getBlockedUser() async {
    try {
      dio.options.baseUrl = "${dotenv.env["APP_SERVER_API"]}/member/user/block";

      final response = await dio.get('');

      var model = BlockedUserResponseModel.fromJson(response.data);
      return model.data;
    } on DioError catch (e) {
      throw Exception(e);
    }
  }

  /// [userId] 차단 해제하려는 유저 아이디
  Future<void> UNBLOCK_USER(String userId) async {
    dio.options.baseUrl =
        "${dotenv.env["APP_SERVER_API"]}/member/user/block/$userId";

    final response = await dio.delete('');

    if (response.statusCode != 200) {
      throw Exception('Block User Error');
    }
  }
}

```



my_page_controller.dart

```dart
import 'dart:async';
import 'package:fas/app/data/models/user/user_model.dart';
import 'package:fas/app/data/service/auth_service.dart';
import 'package:fas/app/data/service/firebase_analytics_service.dart';
import 'package:fas/app/modules/my_page/widgets/my_page_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../custom_widgets/custom_toast.dart';
import '../../../data/models/mypage/filter_item_model.dart';
import '../../../data/models/mypage/mypost_response_model.dart';
import '../../../data/models/mypage/recent/recently_view_response_model.dart';
import '../../../data/models/mypage/subscribe/subscribe_tag_response.dart';
import '../../../data/models/post/post_data/post_model.dart';
import '../../../data/models/post/post_tag_data/post_tag_response_model.dart';
import '../../../data/provider/mypage/mypage_provider.dart';
import '../../../data/provider/post/post_provider.dart';
import '../../../data/service/data_service.dart';
import '../../../theme/color_path.dart';
import '../../../utils/system/image/cache_manager.dart';
import '../../main/controllers/main_controllers.dart';

class MyPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static MyPageController get to => Get.find();

  static MyPageController get register => Get.put(MyPageController());

  RxBool isBefore = true.obs;

  RxBool isVisible = true.obs;

  RxBool isLoading = false.obs;

  RxList<bool> isTabVisible = <bool>[true, false, false].obs;

  RxList<bool> isTabLoading = <bool>[true, true, true].obs;

  GlobalKey<MyPageFilterWidgetState> tagFilterKey =
      GlobalKey<MyPageFilterWidgetState>();

  GlobalKey<MyPageFilterWidgetState> libraryFilterKey =
      GlobalKey<MyPageFilterWidgetState>();

  RxList<PageStorageKey> pageKeys = [
    const PageStorageKey('최근 조회'),
    const PageStorageKey('관심 태그'),
    const PageStorageKey('라이브러리'),
  ].obs;

  TabController? tabBarController;

  Rx<ScrollController> myPageScrollController = ScrollController().obs;

  Rx<PageController> pageController = PageController(initialPage: 0).obs;

  Rx<ScrollController> libraryPageController = ScrollController().obs;

  Rx<ScrollController> tagPageController = ScrollController().obs;

  static bool isMyPageStatus = true;

  RxBool isRefresh = false.obs;

  Rx<RefreshController> refreshController =
      RefreshController(initialRefresh: false).obs;

  RxList<ScrollController> scrollController = <ScrollController>[
    ScrollController(initialScrollOffset: 0),
    ScrollController(initialScrollOffset: 0),
    ScrollController(initialScrollOffset: 0),
    ScrollController(initialScrollOffset: 0),
    ScrollController(initialScrollOffset: 0),
  ].obs;

  RxInt tabBarIndex = 0.obs;

  Rx<double> userInfoHeight = 121.w.obs;

  Rx<double> TabBarMarginTop = 0.0.obs;

  String imgPath = 'assets/icons/img_profileimg.webp';

  Rx<String> depth = ''.obs;

  Rx<int> libraryPage = 1.obs;

  Rx<bool> isPageEnd = false.obs;

  RxList<Post> seenToday = <Post>[].obs;

  RxList<Post> seenYesterday = <Post>[].obs;

  RxList<Post> seenLastWeek = <Post>[].obs;

  Rx<String> tagViewPostCount = ''.obs;

  Rx<String> libraryPostCount = ''.obs;

  RxList<Tag> tags = <Tag>[].obs;

  RxList<Tag> viewTags = <Tag>[].obs;

  RxList<FilterItemModel> tagFilters = <FilterItemModel>[].obs;

  Rx<String> selectedTagPick = '전체'.obs;

  Rx<String> tagOrderBy = '최근 순'.obs;

  RxList<String> tagOrderByList = ['최근 순', '인기 순'].obs;

  RxList<Post> posts = <Post>[].obs;

  RxList<Post> removePost = <Post>[].obs;

  RxList<Post> viewPosts = <Post>[].obs;

  RxBool stop = false.obs;

  RxList<FilterItemModel> categoryFilters = <FilterItemModel>[].obs;

  Rx<String> selectedCatePick = '전체'.obs;

  Rx<bool> editing = false.obs;

  Rx<String> postOrderBy = '최근 순'.obs;

  RxList<String> postOrderByList = ['최근 순', '인기 순'].obs;

  late Rx<UserModel?> userData;

  late RxList<ScrollController> scrollControllers;

  Rx<String> filterCd = ''.obs;

  Rx<String> tagId = ''.obs;

  Rx<double> lastScrollPosition = 0.0.obs;

  // RxList<TermData> termData = <TermData>[].obs;
  RxList<Post> postData = <Post>[].obs;

  Rx<String> cursorId = ''.obs;

  void onVisibilityGained() {
    isVisible.value = true;
  }

  void onVisibilityLost() {
    isVisible.value = false;
  }

  ///Update Profile Data
  Future<void> updateUserModel() async {
    userData = DataService.to.userData;
    update();
  }

  /// Move to Profile Page
  void handleProfileInfo(BuildContext context) {
    Get.toNamed(
      '/mypage/profile',
      id: MainController.to.bottomNavigationIndex.value,
    );
  }

  ///Data Init
  Future<void> onData() async {
    if (AuthService.to.isLogin.value) {
      await Future.wait([
        onRecentlyData(),
        onPostData(),
        onTagData(),
      ]);
    }
  }

  ///최근조회--------------------------------------------------------------------
  Future<void> onRecentlyData() async {
    isTabLoading[0] = true;
    RecentlyViewedResponse response = await MyPageProvider().RECENTLY(
      method: 'GET',
    );

    postData.assignAll(response.postsInfo.posts);
    Future.delayed(
        const Duration(
          milliseconds: 300,
        ), () {
      isTabLoading[0] = false;
    });
  }

  Future<void> onTagData() async {
    isTabLoading[1] = true;
    SubscribeTagResponse response = await MyPageProvider().MYTAG(
      method: 'GET',
    );

    await Future.value([
      selectedTagPick.value = '전체',
      tags.assignAll(response.data.tags),
      viewTags.assignAll(response.data.tags),
      tagFilters.assignAll(response.data.filterList),
      tagViewPostCount = response.data.totalCount!.obs,
      handleTagFilter(selectedTagPick.value),
    ]).then((value) {
      Future.value([
        tags.refresh(),
        viewTags.refresh(),
      ]);
    });

    Future.delayed(
        const Duration(
          milliseconds: 200,
        ), () {
      isTabLoading[1] = false;
    });
  }

  Future<void> onTagUpdate() async {
    isTabLoading[1] = true;
    if (filterCd.isEmpty) {
      SubscribeTagResponse response = await MyPageProvider().MYTAG(
        method: 'GET',
        orderBy: tagOrderBy.value == '인기 순',
      );
      viewTags.clear();
      viewTags.assignAll(response.data.tags);

      tagFilters.clear();
      tagFilters.assignAll(response.data.filterList);
      tagViewPostCount = response.data.totalCount!.obs;
    } else {
      SubscribeTagResponse response = await MyPageProvider().UpdateFilter(
        orderBy: tagOrderBy.value == '인기 순',
        tagFilterCd: filterCd.value,
      );
      viewTags.clear();
      viewTags.assignAll(response.data.tags);
      tagFilters.clear();
      tagFilters.assignAll(response.data.filterList);
      tagViewPostCount = response.data.totalCount!.obs;
    }

    await Future.value([]).then((value) {
      Future.value([
        viewTags.refresh(),
      ]);
    });
    Future.delayed(
        const Duration(
          milliseconds: 300,
        ), () {
      isTabLoading[1] = false;
    });
  }

  Future<void> onFilterUpdate(filterCd) async {
    isTabLoading[1] = true;
    SubscribeTagResponse response = selectedCatePick.value != '전체'
        ? await MyPageProvider().UpdateFilter(
            orderBy: tagOrderBy.value == '인기 순',
            tagFilterCd: filterCd,
          )
        : await MyPageProvider().MYTAG(
            method: 'GET',
            orderBy: tagOrderBy.value == '인기 순',
          );
    List<Tag> tags = response.data.tags
        .where((element) => element.tagFilterCd == filterCd)
        .toList();

    viewTags.assignAll(tags);
    tagViewPostCount = response.data.totalCount!.obs;

    isTabLoading[1] = false;
  }

  ///조회한 필터칩의 태그 갯수가 0이 아니면, 리스트만 재조회합니다.
  Future<void> onTagSubscripyChange() async {
    SubscribeTagResponse response = await MyPageProvider().UpdateFilter(
      orderBy: tagOrderBy.value == '인기 순',
      tagFilterCd: filterCd.value,
    );
    if (response.data.totalCount == '0') {
      onTagData();
      if (!isTabLoading[1]) {
        var state = tagFilterKey.currentState;
        state!.selectedIndex = null;
        state.triggerOnResetFilter();
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          var state = tagFilterKey.currentState;

          state!.selectedIndex = null;
          state.triggerOnResetFilter();
        });
      }
    } else {
      onFilterUpdate(filterCd.value);
    }
  }

  Future<void> onLibraryChange() async {
    SubscribeTagResponse response = await MyPageProvider().UpdateFilter(
      orderBy: tagOrderBy.value == '인기 순',
      tagFilterCd: filterCd.value,
    );
    if (response.data.totalCount == '0') {
      onTagData();
      if (!isTabLoading[2]) {
        var state = MyPageController.to.libraryFilterKey.currentState;
        state!.selectedIndex = null;
        state.triggerOnResetFilter();
      }
    } else {
      onPostUpdate();
    }
  }

  Future<void> handleTagFilter(String filterName) async {
    isTabLoading[1] = true;
    selectedTagPick.value = filterName;
    if (filterName == '전체') {
      SubscribeTagResponse response = await MyPageProvider().MYTAG(
        method: 'GET',
        orderBy: tagOrderBy.value == '인기 순',
      );
      tagViewPostCount = response.data.totalCount!.obs;
      filterCd.value = '';
      tags.assignAll(response.data.tags);
      viewTags.assignAll(tags);
    }
    isTabLoading[1] = false;
  }

  Future<void> addLoadedTags(String cursorId) async {
    isLoading.value = true;
    SubscribeTagResponse response = await MyPageProvider().loadMoreTags(
      cursorId: cursorId,
      filterCd: filterCd.value,
      orderBy: tagOrderBy.value == '인기 순',
    );

    await Future.delayed(const Duration(milliseconds: 500), () {
      viewTags.addAll(response.data.tags);
      isLoading.value = false;
    });
  }

  void handleTagOrderBy(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 184.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15.r),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 12.w, 15, 48.w), // 좌우 패딩 수정 15
          child: Column(
            children: [
              Container(
                width: 36.w,
                height: 4.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: ColorPath.HEX_C4C4C4,
                ),
              ),
              SizedBox(height: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  tagOrderByList.length,
                  (index) => GestureDetector(
                    onTap: () async {
                      // 데이터 posts  함수
                      await Future.value([
                        tagOrderBy.value = tagOrderByList[index],
                        onTagUpdate(),
                      ]).then((value) {
                        Get.back();
                      });
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 54.w,
                      alignment: Alignment.topLeft,
                      decoration: index == 0
                          ? const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: ColorPath.DISABLED_LINE,
                                  width: 1.0,
                                ),
                              ),
                            )
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tagOrderByList[index],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight:
                                    tagOrderBy.value == tagOrderByList[index]
                                        ? ColorPath.BOLD_WEIGHT
                                        : FontWeight.w400,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (tagOrderBy.value == tagOrderByList[index])
                            SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: Image.asset(
                                'assets/icons/ic_black_check.webp',
                                fit: BoxFit.fill,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onPostData() async {
    MyPostResponse response = await MyPageProvider().libraryPost(
      tagId: tagId.value,
    );
    libraryPostCount.value = response.data.totalCount.toString();
    await Future.value([
      posts.assignAll(response.data.posts),
      viewPosts.assignAll(response.data.posts),
      categoryFilters.assignAll(response.data.filterList),
    ]).then((value) {
      Future.value([
        posts.refresh(),
        viewPosts.refresh(),
        categoryFilters.refresh(),
        handlePostFilter(selectedCatePick.value),
      ]);
    });
    refreshController.value.refreshCompleted();
  }

  /// 포스트 업데이트
  Future<void> onPostUpdate() async {
    isTabLoading[2] = true;
    MyPostResponse response = await MyPageProvider().libraryPost(
      tagId: tagId.value,
      orderTypeCd: postOrderBy.value == '인기 순' ? 'SAVED' : '',
    );
    libraryPostCount.value = response.data.totalCount.toString();

    viewPosts.clear();
    viewPosts.addAll(response.data.posts);

    categoryFilters.clear();
    categoryFilters.assignAll(response.data.filterList);

    await Future.value([]).then((value) {
      Future.value([
        viewPosts.refresh(),
        categoryFilters.refresh(),
      ]);
    });
    Future.delayed(
        const Duration(
          milliseconds: 300,
        ), () {
      isTabLoading[2] = false;
    });
  }

  Future<void> addLoadedPosts({
    String? tagId = '',
  }) async {
    isTabLoading[2] = true;
    MyPostResponse response = await MyPageProvider().libraryPost(
      tagId: tagId!,
      orderTypeCd: postOrderBy.value == '인기 순' ? 'SAVED' : '',
    );
    libraryPostCount.value = response.data.totalCount.toString();

    viewPosts.clear();
    viewPosts.addAll(response.data.posts);
    viewPosts.refresh();

    isTabLoading[2] = false;
  }

  Future<void> addCursorItemPosts({
    String? cursorId = '',
  }) async {
    isLoading.value = true;
    MyPostResponse response = await MyPageProvider().libraryPost(
      tagId: tagId.value,
      cursorId: cursorId,
      orderTypeCd: postOrderBy.value == '인기 순' ? 'SAVED' : '',
    );
    downLoadImage(response.data.posts);

    Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        viewPosts.addAll(response.data.posts);
        isLoading.value = false;
      },
    );
  }

  Future<void> handlePostFilter(String filterName) async {
    if (filterName == '전체') {
      tagId.value = '';
      selectedCatePick.value = '전체';
      onPostUpdate();
    }
    isTabLoading[1] = false;
  }

  /// 포스터 우선 순위 변경
  void handlePostOrderBy(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 184.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15.w),
          ),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 12.w, 15, 48.w), // 좌우 패딩 수정 15
          child: Column(
            children: [
              Container(
                width: 36.w,
                height: 4.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: ColorPath.HEX_C4C4C4,
                ),
              ),
              SizedBox(height: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  tagOrderByList.length,
                  (index) {
                    return GestureDetector(
                      onTap: () async {
                        await Future.value([
                          postOrderBy.value = postOrderByList[index],
                          postOrderByList[index],
                          onPostUpdate(),
                        ]).then((value) {
                          Get.back();
                        });
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 54.w,
                        alignment: Alignment.topLeft,
                        decoration: index == 0
                            ? const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: ColorPath.DISABLED_LINE,
                                    width: 1.0,
                                  ),
                                ),
                              )
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                postOrderByList[index],
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: postOrderBy.value ==
                                          postOrderByList[index]
                                      ? ColorPath.BOLD_WEIGHT
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (postOrderBy.value == postOrderByList[index])
                              SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: Image.asset(
                                  'assets/icons/ic_black_check.webp',
                                  fit: BoxFit.fill,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handlePostLibraryRemove() async {
    try {
      if (removePost.isEmpty) {
        editing.value = false;
        return;
      }
      await PostProvider().SAVE_CANCEL(
        method: 'POST',
        requestModel: {
          'post_ids':
              removePost.map((element) => int.parse(element.postId)).toList(),
        },
      );
      await Future.value([
        DataService.to.postListUpdateAll(items: removePost.toList()),
        onPostUpdate(),
        CustomToast(message: '삭제에 성공하였습니다.', height: 106),
      ]);
    } catch (e) {
      CustomToast(message: '삭제에 실패하였습니다.', height: 106);
    } finally {
      Future.value([
        editing.value = false,
        removePost.clear(),
      ]);
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await Future.value(
        tabBarController = TabController(vsync: this, length: 3));
    onData();
    AnalyticsService.to.analytics.logEvent(
      name: 'open_page',
      parameters: {
        'page_type': 'mypage',
        'navigation_index': 3,
      },
    );
  }

  @override
  void onReady() async {
    super.onReady();
  }

  Future<void> downLoadImage(List<Post> posts) async {
    List<String> urls = getImageUrls(posts);
    for (var url in urls) {
      AppImageCacheManager.mainCacheManager.downloadFile(url);
    }
  }

  List<String> getImageUrls(List<Post> posts) {
    List<String> urls = [];
    for (var post in posts) {
      for (var image in post.postImages) {
        urls.add(image.postImageUrl);
      }
    }
    return urls;
  }
}

```

