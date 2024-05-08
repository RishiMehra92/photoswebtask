import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/ImagesModel.dart';

class ImageController extends GetxController {
  RxList<Hits> images = <Hits>[].obs;

  int page = 1;
  bool loading = false;
  final TextEditingController searchController = TextEditingController();
  var isSeach = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadImages();
  }

  Future<void> loadImages() async {
    if (loading) return;
    loading = true;
    update();
    var encodedInput = Uri.encodeComponent(searchController.text.trim());
    var url = 'https://pixabay.com/api/?key=43766976-c60d1830c9e8f00fe6ad38860&q=${encodedInput}&per_page=20&page=$page';
    print("url== $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imagesModel = ImagesModel.fromJson(data);
      images.addAll(imagesModel.hits ?? []);
      page++;
    }

    loading = false;
    update();
  }

}
