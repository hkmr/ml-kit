import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mlkit/screens/object-detection/models.dart';
import 'package:mlkit/screens/object-detection/bndbox.dart';
import 'package:mlkit/screens/object-detection/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

class ObjectDetector extends StatefulWidget {

  List<CameraDescription> cameras;
  ObjectDetector({@required this.cameras});

  @override
  _ObjectDetectorState createState() => _ObjectDetectorState();
}

class _ObjectDetectorState extends State<ObjectDetector> {

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt");
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
        backgroundColor: Colors.black,
      ),
      body: _model == ""
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select Model to Detect Object', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),),
            RaisedButton(
              child: const Text(ssd),
              onPressed: () => onSelect(ssd),
            ),
            RaisedButton(
              child: const Text(yolo),
              onPressed: () => onSelect(yolo),
            ),
            RaisedButton(
              child: const Text(mobilenet),
              onPressed: () => onSelect(mobilenet),
            ),
            RaisedButton(
              child: const Text(posenet),
              onPressed: () => onSelect(posenet),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          Camera(
            widget.cameras,
            _model,
            setRecognitions,
          ),
          BndBox(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              _model),
        ],
      ),
    );
  }
}
