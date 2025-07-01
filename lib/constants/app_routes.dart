import 'package:flutter/material.dart';
import 'package:jobhub_app/screens/job/edit_job_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/role_selection_screen.dart';

import '../screens/home/jobseeker_home.dart';
import '../screens/home/employer_home.dart';

import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/view_profile_screen.dart';

import '../screens/job/job_list_screen.dart';
import '../screens/job/job_detail_screen.dart';
import '../screens/job/create_job_screen.dart';

import '../screens/application/application_list_screen.dart';
import '../screens/application/application_detail_screen.dart';

import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';

import '../screens/common/splash_screen.dart';
import '../screens/common/not_found_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/select_role':
        return MaterialPageRoute(builder: (_) => RoleSelectionScreen());
      case '/jobseeker_home':
        return MaterialPageRoute(builder: (_) => JobSeekerMainScreen());
      case '/employer_home':
        return MaterialPageRoute(builder: (_) => EmployerHomeScreen());
      case '/edit_profile':
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      case '/view_profile':
        return MaterialPageRoute(builder: (_) => ViewProfileScreen());
      case '/job_list':
        return MaterialPageRoute(builder: (_) => JobListScreen());
      case '/edit_job':
        return MaterialPageRoute(builder: (_) => EditJobScreen(jobId:settings.arguments as String)); 
      case '/job_detail':
        final jobId = settings.arguments as String; // ✅ Правильно!
        return MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: jobId));
        
      case '/create_job':
        return MaterialPageRoute(builder: (_) => CreateJobScreen());
      case '/application_list':
        return MaterialPageRoute(builder: (_) => ApplicationListScreen());
      case '/application_detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(applicationId: args['applicationId']),
        );
      case '/chat_list':
        return MaterialPageRoute(builder: (_) => ChatListScreen());
      case '/chat':
      final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: args['chatId']),
        );
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
}
