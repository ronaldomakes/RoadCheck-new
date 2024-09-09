import "dart:math";

import "package:camera/camera.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_vision/flutter_vision.dart";
import "package:geolocator/geolocator.dart";
import 'package:location/location.dart' as locationPackage;
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:location/location.dart";
import "package:yolo/screens/map_screen/map_screen.dart";


late List<CameraDescription> camerass;
class YoloVideo extends StatefulWidget {
  const YoloVideo({Key? key}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;

  int _imageHeight = 0;
  int _imageWidth = 0;

  double depth = 0;
  double width = 0;
  double height = 0;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  double confidenceThreshold = 0.5;
  int inferenceTime = 0;
  int preProcessingTime = 0;


  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    camerass = await availableCameras();
    vision = FlutterVision();
    controller = CameraController(camerass[0], ResolutionPreset.high);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
    });
  }






  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }
  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      yoloResults = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
      recognitions.forEach((element) {
        inferenceTime = element["inferenceTime"];
        preProcessingTime = element["preProcessingTime"];
        //print('Inference time is: $inferenceTime');
      });
    });
  }
  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/yolov8n-working-model.tflite',
        modelVersion: "yolov8",
        numThreads: 1,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }
  @override
  void dispose() async {
    super.dispose();
    controller.dispose();
    await vision.closeYoloModel();
  }
  @override
  Widget build(BuildContext context) {
    List<Object> potholes = [];
    Position? currentPosition;
    List<LatLng> routePoints = [];
    Set<Marker> potholeMarkers = {};
    Future<void> startDetection() async {
      setState(() {
        isDetecting = true;
      });
      if (controller.value.isStreamingImages) {
        return;
      }
      await controller.startImageStream((image) async {
        if (isDetecting) {
          cameraImage = image;
          yoloOnFrame(image);
          currentPosition = await Geolocator.getCurrentPosition();
          routePoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
          LatLng currentLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
          if (yoloResults.isNotEmpty) {
            Marker potholeMarker = Marker(
              markerId: MarkerId("pothole_${potholeMarkers.length}"),
              position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
              infoWindow: InfoWindow(title: "Pothole Detected",),
            );
            potholeMarkers.add(potholeMarker);
            await FirebaseFirestore.instance.collection('potholes').add({
              'latitude': currentLatLng.latitude,
              'longitude': currentLatLng.longitude,
              'detectionTime': Timestamp.now(),
            }).then((_) {
              print("Pothole marker saved to Firestore");
            }).catchError((error) {
              print("Failed to add marker: $error");
            });
          }
        }
      });
    }
    double calculateDistance(LatLng start, LatLng end) {
      const double earthRadius = 6371000; // in meters
      double dLat = (end.latitude - start.latitude) * (pi / 180);
      double dLng = (end.longitude - start.longitude) * (pi / 180);
      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(start.latitude * (pi / 180)) *
              cos(end.latitude * (pi / 180)) *
              sin(dLng / 2) *
              sin(dLng / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return earthRadius * c;
    }
    Future<void> stopDetection() async {
      setState(() {
        isDetecting = false;
        print("Results: $yoloResults");
        yoloResults.clear();
      });
    }
    List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
      if (yoloResults.isEmpty) return [];
      double factorX = screen.width / (cameraImage?.height ?? 1);
      double factorY = screen.height / (cameraImage?.width ?? 1);

      Color colorPick = const Color.fromARGB(255, 50, 233, 30);

      return yoloResults.map((result) {
        double objectX = result["box"][0] * factorX;
        double objectY = result["box"][1] * factorY;
        double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
        double objectHeight = (result["box"][3] - result["box"][1]) * factorY;


        return Positioned(
          left: objectX,
          top: objectY,
          width: objectWidth,
          height: objectHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.pink, width: 2.0),
            ),
            child: Text(
              "${result['tag']} ${(result['box'][4] * 100)}",
              style: TextStyle(
                background: Paint()..color = colorPick,
                color: const Color.fromARGB(255, 115, 0, 255),
                fontSize: 18.0,
              ),
            ),
          ),
        );
      }).toList();
    }
    final Size size = MediaQuery.of(context).size;

    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleMapFlutter()));
          }, icon: Icon(Icons.map))
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(
              controller,
            ),
          ),
          ...displayBoxesAroundRecognizedObjects(size),
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 5, color: Colors.white, style: BorderStyle.solid),
              ),
              child: isDetecting
                  ? IconButton(
                onPressed: () async {
                  stopDetection();
                },
                icon: const Icon(
                  Icons.stop,
                  color: Colors.red,
                ),
                iconSize: 50,
              )
                  : IconButton(
                onPressed: () async {
                  await startDetection();
                },
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
// Here we start writing our code.
}