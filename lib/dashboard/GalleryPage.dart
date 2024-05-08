import 'package:cached_network_image/cached_network_image.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'FullScreenImage.dart';
import 'controller/ImageController.dart';
import 'model/ImagesModel.dart';

class GalleryPage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer =
      Debouncer(const Duration(milliseconds: 500), initialValue: '');

  late ImageController imageController;

  @override
  Widget build(BuildContext context) {
    imageController = Get.put(ImageController());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        imageController.loadImages();
      }
    });
    imageController.searchController.addListener(() {
      _debouncer.onChanged!(() {
        imageController.page = 1;
        imageController.images = <Hits>[].obs;
        imageController.loadImages();
      });
    });

    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0,bottom: 15.0),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                  imageController.page = 1;
                  imageController.images.clear();
                  imageController.images = <Hits>[].obs;
                  imageController.loadImages();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the TextField
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: imageController.searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if(value.isNotEmpty){
                            imageController.isSeach.value = true;
                          }else{
                            imageController.isSeach.value = false;
                          }
                        },
                      ),
                    ),
                  Obx(() => imageController.isSeach.value?  IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        imageController.searchController.clear();
                        imageController.page = 1;
                        imageController.images.clear();
                        imageController.images = <Hits>[].obs;
                        imageController.isSeach.value=false;
                        imageController.loadImages();
                      },
                    ):const Text("")
                  )
                  ],
                ),
              ),
            ),
          ),
        ),

        body: Obx(
          () => Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                imageController.images.isNotEmpty
                    ? Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width ~/ 200,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: imageController.images.length + 1,
                          // +1 for loading indicator
                          itemBuilder: (context, index) {
                            if (index < imageController.images.length) {
                              final image = imageController.images[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenImage(
                                          imageUrl:
                                              image.webformatURL.toString()),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                  AspectRatio(
                                  aspectRatio: 1.0, // 1:1 aspect ratio (square)
                                  child:CachedNetworkImage(
                                      imageUrl: image.webformatURL.toString(),
                                      fit: BoxFit.fill,
                                    )),
                                    Positioned(
                                      bottom:0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50
                                        ),
                                        child: Center(child: Text('Likes: ${image.likes} Views: ${image.views}')),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return  (const Text(""));
                            }
                          },
                        ),
                      )
                    :   Padding(
                      padding: const EdgeInsets.only(top:80.0),
                      child: Center(
                          child: LoadingAnimationWidget.hexagonDots(
                            color: Colors.blue,
                            size: 100,
                          ),// Loading indicator at the end of the list
                        ),
                    ),
              ],
            ),
          ),
        ));
  }
}
