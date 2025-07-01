import 'package:flutter/material.dart';
import '../job/job_list_screen.dart';
import '../application/application_list_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/view_profile_screen.dart';

class JobSeekerMainScreen extends StatefulWidget {
  const JobSeekerMainScreen({Key? key}) : super(key: key);

  @override
  State<JobSeekerMainScreen> createState() => _JobSeekerMainScreenState();
}

class _JobSeekerMainScreenState extends State<JobSeekerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    JobListScreen(),
    ApplicationListScreen(),
    ChatListScreen(),
    const ViewProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Вакансии'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Отклики'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чаты'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
