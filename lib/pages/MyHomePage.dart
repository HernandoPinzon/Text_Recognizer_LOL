import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlkit_text_recognition/mlkit_text_recognition.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int intento = 0;
  String texto = "";

  PictureDataModel? _pictureDataModel;

  @override
  void initState() {
    _pictureDataModel = PictureDataModel();
    _pictureDataModel!.inputClickState.add([]);
    super.initState();
  }

  

  getRecognisedTextFromPath(String path) async {
    print("entre1");
    final inputImage = InputImage.fromFilePath(path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    String scannedText2 = recognizedText.toString();
    print('texto.totext: $scannedText2');
    scannedText2 = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText2 = scannedText2 + line.text + "\n";
      }
    }
    setState(() {
      texto = scannedText2;
      intento++;
    });
    print('texto: $scannedText2');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                StreamBuilder<List<String>>(
                  stream: _pictureDataModel!.outputResult,
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20.0),
                      child: snapshot.hasData
                          ? snapshot.data!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.file(
                                    File(snapshot.data![0]),
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const SizedBox.shrink()
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    print("onpressed");
                    openCamera.then(
                      (List<String> data) {
                        getRecognisedTextFromPath(data.first);
                        _pictureDataModel!.inputClickState.add(data);
                      },
                      onError: (e) {
                        _pictureDataModel!.inputClickState.add([]);
                      },
                    );
                  },
                  child: const Text("tome una foto"),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(texto + '$intento'),
              ],
            ),
          ),
        )
      ),
    );
  }



  
}

class PictureDataModel {
  final StreamController<List<String>> _streamController =
      StreamController<List<String>>.broadcast();

  Sink<List<String>> get inputClickState => _streamController;

  Stream<List<String>> get outputResult =>
      _streamController.stream.map((data) => data);

  dispose() => _streamController.close();
}



Future<List<String>> get openCamera async {
  const MethodChannel _channel = MethodChannel("take_picture_native");
  return await _channel.invokeMethod("open_camera").then((data) =>  List<String>.from(data));
}