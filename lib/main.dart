import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:field_force_2/provider/chat_provider.dart';
import 'package:field_force_2/provider/journey_provider.dart';
import 'package:field_force_2/provider/leave_provider.dart';
import 'package:field_force_2/provider/project_provider.dart';
import 'package:field_force_2/provider/task_provider.dart';
import 'package:field_force_2/repo/chat_repository.dart';
import 'package:field_force_2/repo/journey_repository.dart';
import 'package:field_force_2/repo/leave_repository.dart';
import 'package:field_force_2/repo/memory_chat_repository.dart';
import 'package:field_force_2/repo/project_repository.dart';
import 'package:field_force_2/repo/task_repository.dart';
import 'package:field_force_2/view/dashboard.dart';
import 'package:field_force_2/view/login.dart';
import 'package:flutter/material.dart';
import 'package:field_force_2/provider/all_employee_provider.dart';
import 'package:field_force_2/provider/attendance_provider.dart';
import 'package:field_force_2/provider/auth_provider.dart';
import 'package:field_force_2/provider/customer_provider.dart';
import 'package:field_force_2/provider/employee_provider.dart';
import 'package:field_force_2/provider/product_provider.dart';
import 'package:field_force_2/repo/all_employee_repository.dart';
import 'package:field_force_2/repo/attendance_repository.dart';
import 'package:field_force_2/repo/customer_repository.dart';
import 'package:field_force_2/repo/product_repository.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';









Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();



  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),

          ),

          ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
            create: (_) => EmployeeProvider(null),
            update: (_, auth, __) => EmployeeProvider(auth),
          ),
          ChangeNotifierProvider(
            create: (_) => JourneyProvider(
              JourneyRepository(baseUrl: 'https://demo.kendroo.io',),
            ),
          ),

          ChangeNotifierProxyProvider<AuthProvider, AllEmployeeProvider>(
            create: (_) => AllEmployeeProvider(
              AllEmployeeRepository(baseUrl: 'https://demo.kendroo.com', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                AllEmployeeProvider(AllEmployeeRepository(
                  baseUrl: 'https://demo.kendroo.com',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),

          ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
            create: (_) => AttendanceProvider(
              AttendanceRepository(baseUrl: 'https://demo.kendroo.io', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                AttendanceProvider(AttendanceRepository(
                  baseUrl: 'https://demo.kendroo.io',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),

          ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
            create: (_) => ChatProvider(
              MemoryChatRepository(baseUrl: 'https://demo.kendroo.io', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                ChatProvider(MemoryChatRepository(
                  baseUrl: 'https://demo.kendroo.io',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),

          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
            create: (_) => ProductProvider(
              ProductRepository(baseUrl: 'https://demo.kendroo.com', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                ProductProvider(ProductRepository(
                  baseUrl: 'https://demo.kendroo.com',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),

          ChangeNotifierProxyProvider<AuthProvider, CustomerProvider>(
            create: (_) => CustomerProvider(
              CustomerRepository(baseUrl: 'https://demo.kendroo.com', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                CustomerProvider(CustomerRepository(
                  baseUrl: 'https://demo.kendroo.com',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),
          ChangeNotifierProxyProvider<AuthProvider, LeaveProvider>(
            create: (_) => LeaveProvider(
              LeaveRepository(baseUrl: 'https://demo.kendroo.com', sessionCookie: ''),
            ),
            update: (_, auth, provider) =>
                LeaveProvider(LeaveRepository(
                  baseUrl: 'https://demo.kendroo.com',
                  sessionCookie: auth.sessionCookie ?? '',
                )),
          ),



          ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
            create: (_) => TaskProvider(
              repository: TaskRepository(baseUrl: "", sessionCookie: ""),
            ),
            update: (_, auth, previous) => TaskProvider(
              repository: TaskRepository(
                baseUrl: 'https://demo.kendroo.com',
                sessionCookie: auth.sessionCookie ?? "",
              ),
            ),
          ),


          ChangeNotifierProxyProvider<AuthProvider, ProjectProvider>(
            create: (_) => ProjectProvider(
              repository: ProjectRepository(baseUrl: "", sessionCookie: ""),
            ),
            update: (_, auth, previous) => ProjectProvider(
              repository: ProjectRepository(
                baseUrl: 'https://demo.kendroo.com',
                sessionCookie: auth.sessionCookie ?? "",
              ),
            ),
          ),
        ],
        child: const MyApp(), )
     );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const OdooLoginPage(),
    );
  }
}


