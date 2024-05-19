import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mobile_flutter_engineer_test/app/widgets/shimmer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_player/video_player.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DefaultTabController(
        initialIndex: homeController.currentIndex.value,
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: const Icon(
              Icons.arrow_back,
            ),
            title: Obx(
              () {
                return Text(
                  homeController.courseModel.value.courseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            actions: [
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Center(
                    child: CircularPercentIndicator(
                      radius: 15.0,
                      lineWidth: 4.0,
                      animation: true,
                      percent: double.parse(
                          "0.${homeController.courseModel.value.progress}"),
                      center: Text(
                        "${homeController.courseModel.value.progress}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Obx(
            () {
              return CustomScrollView(
                controller: homeController.scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    expandedHeight:
                        homeController.selectedVideo.value == false ? 0 : 250.0,
                    title: homeController.selectedVideo.value == false
                        ? const Center(
                            child: Text(
                              "Silahkan pilih video",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                        : null,
                    flexibleSpace: homeController.selectedVideo.value == false
                        ? const SizedBox()
                        : FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Obx(
                              () {
                                if (!homeController.isInitialized.value) {
                                  return const Column(
                                    children: [
                                      Center(
                                        child: Skelton(
                                          width: double.infinity,
                                          height: 40,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Stack(
                                    children: [
                                      Container(
                                        color: Colors.black,
                                        child: AspectRatio(
                                          aspectRatio: homeController
                                              .videoPlayerController
                                              .value
                                              .aspectRatio,
                                          child: GestureDetector(
                                            onTap: () {
                                              homeController.pause();
                                            },
                                            child: VideoPlayer(homeController
                                                .videoPlayerController),
                                          ),
                                        ),
                                      ),
                                      if (!homeController.isPlaying.value)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 70,
                                          child: IconButton(
                                            iconSize: 64.0,
                                            icon: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: List.filled(
                                                  10,
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withAlpha(15),
                                                    spreadRadius: 5,
                                                  ),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.blue,
                                                size: 30,
                                              ),
                                            ),
                                            onPressed: () {
                                              homeController.play();
                                            },
                                          ),
                                        ),
                                      if (homeController.isBuffering.value)
                                        const Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 80,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 40,
                                        left: 10.0,
                                        right: 10.0,
                                        child: VideoProgressIndicator(
                                          homeController.videoPlayerController,
                                          allowScrubbing: true,
                                          padding: const EdgeInsets.all(8.0),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 20,
                                        right: 0,
                                        child: Text(
                                          HtmlUnescape().convert(
                                              homeController.videoName.value),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                  ),
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    title: TabBar(
                      indicatorColor: Colors.blue,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      overlayColor: MaterialStatePropertyAll(
                        Colors.blue.withAlpha(10),
                      ),
                      onTap: (index) {
                        homeController.changeTabIndex(index);
                      },
                      tabs: const [
                        Tab(
                          text: 'Kurikulum',
                        ),
                        Tab(
                          text: 'Ikhtisar',
                        ),
                        Tab(
                          text: 'Lampiran',
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Obx(
                        () {
                          var courseModel = homeController.courseModel.value;
                          var curriculumItem = courseModel.curriculum[index];
                          if (homeController.isLoading.value == true) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            if (curriculumItem.type == "section") {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(5),
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                      width: 0.5,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                height: 70,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${courseModel.curriculum[index].title}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "${courseModel.curriculum[index].duration} menit",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Slidable(
                                enabled:
                                    curriculumItem.statusDownload.value == 1
                                        ? true
                                        : false,
                                key: ValueKey(curriculumItem.id),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                insetPadding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor: Colors.white,
                                                surfaceTintColor: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        "Apakah anda yakin ingin menghapus video dari penyimpanan?",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      const Text(
                                                        "Note: Setelah anda menghapus video ini, maka anda harus menonton video secara streaming atau mendownload ulang video",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              homeController.deleteVideo(
                                                                  courseModel
                                                                      .curriculum[
                                                                          index]
                                                                      .id);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Iya",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            style:
                                                                const ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStatePropertyAll(
                                                                      Colors
                                                                          .white),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Tidak",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: "Hapus",
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.white),
                                    overlayColor: MaterialStatePropertyAll(
                                      Colors.grey.withAlpha(20),
                                    ),
                                    surfaceTintColor:
                                        const MaterialStatePropertyAll(
                                            Colors.white),
                                    foregroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.black),
                                    side: const MaterialStatePropertyAll(
                                      BorderSide.none,
                                    ),
                                    padding: const MaterialStatePropertyAll(
                                      EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                    ),
                                    shape: const MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (curriculumItem.statusDownload.value ==
                                        1) {
                                      homeController.initializeVideoOffline(
                                          "${homeController.dirPath}/${courseModel.curriculum[index].id}");
                                      homeController.changeVideoName(
                                          courseModel.curriculum[index].title ??
                                              "");
                                      homeController.scrollToTop();
                                      homeController.changeselectedVideo();
                                    } else {
                                      homeController.initializeVideoOnline(
                                          homeController.courseModel.value
                                              .curriculum[index].onlineVideoLink
                                              .toString());
                                      homeController.changeVideoName(
                                          courseModel.curriculum[index].title ??
                                              "");
                                      homeController.scrollToTop();
                                      homeController.changeselectedVideo();
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: courseModel.curriculum[index]
                                                      .status ==
                                                  1
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              HtmlUnescape().convert(courseModel
                                                  .curriculum[index].title
                                                  .toString()),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "${courseModel.curriculum[index].duration} Menit",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Obx(
                                        () {
                                          bool isDownloading = homeController
                                                  .downloading[index] ??
                                              false;
                                          double downloadProgress =
                                              homeController.progress[index] ??
                                                  0.0;

                                          if (isDownloading) {
                                            return Column(
                                              children: [
                                                CircularPercentIndicator(
                                                  radius: 20.0,
                                                  lineWidth: 4.0,
                                                  percent: downloadProgress,
                                                  center: Text(
                                                    '${(downloadProgress * 100).toStringAsFixed(0)}%',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  circularStrokeCap:
                                                      CircularStrokeCap.round,
                                                  progressColor: Colors.blue,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                if (curriculumItem
                                                        .statusDownload.value ==
                                                    0) {
                                                  homeController.downloadVideo(
                                                    curriculumItem
                                                            .offlineVideoLink ??
                                                        "",
                                                    curriculumItem.id,
                                                    index,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: curriculumItem
                                                              .statusDownload
                                                              .value ==
                                                          1
                                                      ? Colors.white
                                                      : Colors.blue,
                                                  border: curriculumItem
                                                              .statusDownload
                                                              .value ==
                                                          1
                                                      ? Border.all(
                                                          color: Colors.grey
                                                              .withAlpha(50),
                                                        )
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: curriculumItem
                                                            .statusDownload
                                                            .value ==
                                                        1
                                                    ? const Row(
                                                        children: [
                                                          Text(
                                                            "Tersimpan",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .check_circle_outline_outlined,
                                                            color: Colors.blue,
                                                            size: 15,
                                                          ),
                                                        ],
                                                      )
                                                    : const Text(
                                                        "Tonton Offline",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      childCount:
                          homeController.courseModel.value.curriculum.length,
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.keyboard_double_arrow_left),
                    Text("Sebelumnya"),
                  ],
                ),
                Row(
                  children: [
                    Text("Selanjutnya"),
                    Icon(Icons.keyboard_double_arrow_right),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }
}
