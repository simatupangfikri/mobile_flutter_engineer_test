import 'package:get/get.dart';

class CourseModel {
  String courseName;
  String progress;
  List<CourseCurriculumModel> curriculum;

  CourseModel({
    required this.courseName,
    required this.progress,
    required this.curriculum,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseName: json['course_name'],
      progress: json['progress'],
      curriculum: List<CourseCurriculumModel>.from(
        json["curriculum"].map((x) => CourseCurriculumModel.fromJson(x)),
      ),
    );
  }
}

class CourseCurriculumModel {
  int? key;
  dynamic id;
  String? type;
  String? title;
  int? duration;
  String? content;
  int? status;
  RxInt statusDownload;
  String? onlineVideoLink;
  String? offlineVideoLink;

  CourseCurriculumModel({
    this.key,
    this.id,
    this.type,
    this.title,
    this.duration,
    this.content,
    this.status,
    this.onlineVideoLink,
    this.offlineVideoLink,
  }) : statusDownload = 0.obs;

  factory CourseCurriculumModel.fromJson(Map<String, dynamic> json) {
    return CourseCurriculumModel(
      key: json['key'],
      id: json['id'],
      type: json['type'],
      title: json['title'],
      duration: json['duration'],
      content: json['content'],
      status: json['status'],
      onlineVideoLink: json['online_video_link'],
      offlineVideoLink: json['offline_video_link'],
    );
  }
}
