import 'package:api_practice/Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HttpWithDioGetx>(
      init: HttpWithDioGetx()..started(),
      builder: (controller) {
        return Scaffold(
            appBar: AppBar(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('here'),
                  Text('Practice'),
                ],
              ),
            ),
            body: ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.photos.length,
              itemBuilder: ((context, index) {
                return Column(
                  children: [
                    // Text('${controller.photos}',
                    //     style: const TextStyle(color: Colors.black)),
                    Text(controller.photos[index].author),
                    Text('${controller.photos[index].downloadUrl}')
                  ],
                );
              }),
            ));
      },
    );
  }
}
