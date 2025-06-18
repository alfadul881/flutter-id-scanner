
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: IDScannerPage(),
  ));
}

class IDScannerPage extends StatefulWidget {
  @override
  _IDScannerPageState createState() => _IDScannerPageState();
}

class _IDScannerPageState extends State<IDScannerPage> {
  File? _image;
  String extractedID = '';
  String extractedDOB = '';

  Future<void> scanText() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    _image = File(pickedFile.path);
    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    final fullText = recognizedText.text;

    final idMatch = RegExp(r'\b[12]\d{9}\b').firstMatch(fullText);
    final dobMatch = RegExp(r'\b(13|14|19|20)\d{2}[-/\.\s]?\d{1,2}[-/\.\s]?\d{1,2}\b').firstMatch(fullText);

    setState(() {
      extractedID = idMatch?.group(0) ?? '';
      extractedDOB = dobMatch?.group(0) ?? '';
    });

    textRecognizer.close();

    if (extractedID.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VehicleSelectionPage(id: extractedID, dob: extractedDOB)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Saudi ID")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: scanText, child: Text("Scan ID")),
            if (_image != null) Image.file(_image!, height: 200),
          ],
        ),
      ),
    );
  }
}

class VehicleSelectionPage extends StatefulWidget {
  final String id;
  final String dob;

  VehicleSelectionPage({required this.id, required this.dob});

  @override
  _VehicleSelectionPageState createState() => _VehicleSelectionPageState();
}

class _VehicleSelectionPageState extends State<VehicleSelectionPage> {
  final List<String> vehicles = [
    "345621 - Toyota Camry 2021",
    "487912 - Hyundai Sonata 2022",
    "518433 - Ford Explorer 2020"
  ];
  String? selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Vehicle")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("ID: ${widget.id}\nDOB: ${widget.dob}"),
            SizedBox(height: 20),
            ...vehicles.map((v) => RadioListTile(
              title: Text(v),
              value: v,
              groupValue: selectedVehicle,
              onChanged: (value) {
                setState(() {
                  selectedVehicle = value.toString();
                });
              },
            )),
            ElevatedButton(
              onPressed: selectedVehicle == null ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuotePage(vehicle: selectedVehicle!)),
                );
              },
              child: Text("Get Quote"),
            )
          ],
        ),
      ),
    );
  }
}

class QuotePage extends StatelessWidget {
  final String vehicle;

  QuotePage({required this.vehicle});

  String getQuote(String v) {
    if (v.contains("Toyota")) return "SAR 1,050";
    if (v.contains("Hyundai")) return "SAR 970";
    if (v.contains("Ford")) return "SAR 1,200";
    return "SAR 999";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Quote")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Selected Vehicle:\n$vehicle", textAlign: TextAlign.center),
              SizedBox(height: 20),
              Text("Estimated Quote:\n${getQuote(vehicle)}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
