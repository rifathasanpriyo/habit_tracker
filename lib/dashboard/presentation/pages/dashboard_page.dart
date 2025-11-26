import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:havit_tracker/theme/bloc/theme_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [ 
          Switch(value: context.read<ThemeBloc>().state== ThemeMode.dark , onChanged: (value){ 
        context.read<ThemeBloc>().add(ThemeChangeEvent(isDark: value));
          })
        ],
        
        ),
      body: Column(children: [ 
        Text("This is Dashboard Page"),
      ],),
    );
  }
}