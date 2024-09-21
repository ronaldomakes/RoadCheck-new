import 'package:flutter/material.dart';

import 'live_detection/live_camera.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Widget buttonContainer(String title, VoidCallback onTap, Color color, String assetName) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 20),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(assetName),
                )
              ),
            ),
            SizedBox(height: 5,),
            Text(title, style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),)
          ],
        ),
      ),
    ),
  );
}

class _HomeScreenState extends State<HomeScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buttonContainer('Сделать фото', () {

                }, Colors.green.shade400, 'assets/images/video.png'),
                SizedBox(height: 15,),
                buttonContainer('Начать видеопоток', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => YoloVideo()));
                }, Colors.blue.shade400, 'assets/images/maxresdefault.jpg')
              ]
            ),
          ),
        ),
      ),
    );
  }
}

