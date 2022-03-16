import 'package:flutter/material.dart';
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
                ElevatedButton(
                  onPressed: () {
                    print("onpressed");
                  },
                  child: Text("tome una foto"),
                ),
                SizedBox(
                  height: 100,
                ),
                Container(
                  child: Text(texto + '$intento'),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
