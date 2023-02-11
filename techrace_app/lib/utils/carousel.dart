

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:techrace/utils/MStyles.dart';

import 'package:carousel_slider/carousel_slider.dart';


class CarouselApp2 extends StatelessWidget {
  CarouselApp2({super.key});
  final RxBool isScrolling = true.obs;
  final List<String> images = [
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F1.png?alt=media&token=b478d745-43cd-41c5-9013-a8d4c42fe700",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F2.png?alt=media&token=2dd218e3-32fc-4d74-b9e9-04c2f4ecc3d2",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F3.png?alt=media&token=2be7c055-425c-420c-964a-4caa769cff59",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F4.png?alt=media&token=de53b059-9ec9-4cc4-8774-945b2559f46f",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F5.png?alt=media&token=45da8d31-6028-4752-9db1-17d42578eab6",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F6.png?alt=media&token=a907a636-40b4-4c2d-a715-709423db3580",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F7.png?alt=media&token=8bb35a6c-70cb-4e03-97a8-f4b953c3070b",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F8.png?alt=media&token=d6120989-6bb7-40ab-b68b-8247dfd82e5e",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F9.png?alt=media&token=2ad120e0-e0b4-406e-9409-91bd6f52c923",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F10.png?alt=media&token=be796004-e0c3-468d-b4ba-c54b01500a24",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F11.png?alt=media&token=5decdd82-9339-4ac0-a007-425beb8c9ace",
    "https://firebasestorage.googleapis.com/v0/b/dummy.appspot.com/o/app_ss%2F12.png?alt=media&token=1274c83e-be34-4a37-97fe-d25534a988a0"
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Obx(() {
        return CarouselSlider.builder(
            itemCount: images.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                // child: Image.network(
                //   images[itemIndex],

                //   // fit: BoxFit.cover,
                //   // width: MediaQuery.of(context).size.width,
                // ),
                child: CachedNetworkImage(
                  imageUrl: images[itemIndex],
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: MStyles.pColor, size: 100),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.75,
              aspectRatio: 16 / 9,
              viewportFraction: 0.9,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: isScrolling.value,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 2500),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              scrollDirection: Axis.horizontal,
              onScrolled: (value) => isScrolling.value = false,
            ));
      }),
    );
  }
}
