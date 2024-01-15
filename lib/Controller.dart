import 'package:api_practice/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HttpWithDioGetx extends GetxController {
  final Dio _dio = Dio();
  ScrollController scrollController = ScrollController();

  List<PiscumPhotoModel> photos = [];

  int currentPageNo = 1;
  bool isAdd = false;

  Future<void> started() async {
    await _getPhotos();
  }

  Future<void> _getPhotos() async {
    photos = await _fetchPost(pageNo: currentPageNo);
    currentPageNo = 2;
    update();
  }

  Future<void> _morePhoto() async {
    if (!isAdd) {
      isAdd = true;
      update();
      List<PiscumPhotoModel> data = await _fetchPost(pageNo: currentPageNo);
      Future.delayed(const Duration(microseconds: 1000), () {
        photos.addAll(data);
        currentPageNo += 1;
        isAdd = false;
        update();
      });
    }
  }

  Future<List<PiscumPhotoModel>> _fetchPost({
    required int pageNo,
  }) async {
    try {
      final response =
          await _dio.get("https://picsum.photos/v2/list?page=$pageNo&limit=10");
      if (response.statusCode == 200) {
        List<dynamic> fromData = response.data as List<dynamic>;
        List<PiscumPhotoModel> data = fromData
            .map((e) => PiscumPhotoModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return data;
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent * 0.85 <
          scrollController.position.pixels) {
        _morePhoto();
      }
    });
    super.onInit();
  }
}
