import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_flutter_engineer_test/app/models/course_model.dart';

class ApiService {
  static const String url =
      'https://engineer-test-eight.vercel.app/course-status.json';

  static Future<CourseModel> fetchCourseStatus() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return CourseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course status');
    }
  }
}
