import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Predictor',
      home: ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String _imagePath;
  String _prediction = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Load the TFLite model
  void loadModel() async {
    await Tflite.loadModel(
      model: "assets/your_model.tflite",
      labels: "assets/labels.txt", // if you have a labels file
    );
  }

  // Function to pick an image and predict
  void pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      predictImage(image.path);
    }
  }

  // Function to run prediction on the image
  void predictImage(String path) async {
    var recognitions = await Tflite.runModelOnImage(path: path);
    setState(() {
      _prediction = recognitions.isNotEmpty ? recognitions[0]['label'] : 'No number detected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Predictor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imagePath != null ? Image.file(File(_imagePath)) : Container(),
            Text(_prediction),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
