import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter_engineer_test/app/models/course_model.dart';
import 'package:mobile_flutter_engineer_test/app/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  var courseModel =
      CourseModel(curriculum: [], courseName: '', progress: '').obs;
  var filesInDevice = <String>[].obs;
  var isLoading = true.obs;
  late VideoPlayerController videoPlayerController;
  var isPlaying = false.obs;
  var isPaused = false.obs;
  var isBuffering = false.obs;
  var isEnded = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isInitialized = false.obs;
  var downloading = <int, bool>{}.obs;
  var progress = <int, double>{}.obs;
  var downloadPath = <int, String>{}.obs;
  var currentIndex = 0.obs;
  var bab = 1.obs;
  var dirPath = ''.obs;
  var videoName = ''.obs;
  var selectedVideo = false.obs;

  @override
  void onInit() {
    fetchCourse();
    fetchFilesFromDevice();
    getPath();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void fetchCourse() async {
    try {
      isLoading(true);
      var status = await ApiService.fetchCourseStatus();
      var fetchedCourse = status;
      for (var curriculum in fetchedCourse.curriculum) {
        if (filesInDevice.contains(curriculum.id)) {
          curriculum.statusDownload.value = 1;
        } else {
          curriculum.statusDownload.value = 0;
        }
      }
      courseModel.value = fetchedCourse;
    } catch (e) {
      print("Error fetching course status: $e");
    } finally {
      isLoading(false);
    }
  }

  void fetchFilesFromDevice() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    List<String> fileNames = dir
        .listSync()
        .where((element) => element is File)
        .map((e) => (e as File).path.split('/').last)
        .toList();
    filesInDevice.addAll(fileNames);
  }

  void downloadVideo(String url, String filename, int index) async {
    downloading[index] = true;
    progress[index] = 0.0;

    try {
      Dio dio = Dio();
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$filename';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress[index] = received / total;
          }
        },
      );

      downloadPath[index] = savePath;
      updateCurriculumDownloadStatus(filename, 1);
    } catch (e) {
      Get.snackbar('Error', "Tidak bisa menyimpan");
    } finally {
      downloading[index] = false;
    }
  }

  Future<void> deleteVideo(String fileName) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File file = File('${appDocDir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        Get.snackbar('Success', 'Video deleted successfully');
        updateCurriculumDownloadStatus(fileName, 0);
      } else {
        Get.snackbar('Error', 'File does not exist');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void updateCurriculumDownloadStatus(String curriculumId, int status) {
    var course = courseModel.value;
    for (var curriculum in course.curriculum) {
      if (curriculum.id == curriculumId) {
        curriculum.statusDownload.value = status;
        break;
      }
    }
    courseModel.value = course;
  }

  void initializeVideoOnline(String url) async {
    if (url.isEmpty) {
      Get.snackbar('Error', "Video tidak ada");
    } else {
      isInitialized.value = false;
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      )..initialize().then(
          (_) {
            isInitialized.value = true;
            update();
            videoPlayerController.addListener(() {
              isPlaying.value = videoPlayerController.value.isPlaying;
              isPaused.value = !videoPlayerController.value.isPlaying &&
                  !videoPlayerController.value.isBuffering;
              isBuffering.value = videoPlayerController.value.isBuffering;
              isEnded.value = videoPlayerController.value.position ==
                  videoPlayerController.value.duration;
              duration.value = videoPlayerController.value.duration;
              position.value = videoPlayerController.value.position;
            });
          },
        );
    }
  }

  void initializeVideoOffline(String dir) async {
    isInitialized.value = false;
    videoPlayerController = VideoPlayerController.file(File(dir))
      ..initialize().then((value) {
        isInitialized.value = true;
        update();
        videoPlayerController.addListener(() {
          isPlaying.value = videoPlayerController.value.isPlaying;
          isPaused.value = !videoPlayerController.value.isPlaying &&
              !videoPlayerController.value.isBuffering;
          isBuffering.value = videoPlayerController.value.isBuffering;
          isEnded.value = videoPlayerController.value.position ==
              videoPlayerController.value.duration;
          duration.value = videoPlayerController.value.duration;
          position.value = videoPlayerController.value.position;
        });
      });
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void play() {
    videoPlayerController.play();
  }

  void pause() {
    videoPlayerController.pause();
  }

  void seekTo(Duration position) {
    videoPlayerController.seekTo(position);
  }

  Future<void> getPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    dirPath.value = appDocDir.path;
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void changeVideoName(String name) {
    videoName.value = name;
  }

  void changeselectedVideo() {
    selectedVideo.value = true;
  }
}
