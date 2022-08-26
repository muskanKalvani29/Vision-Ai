import 'package:camera/camera.dart';

import 'package:flutter/material.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'camera_view.dart';
import 'language.dart';
import 'painters/object_detector_painter.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ObjectDetectorView extends StatefulWidget {
  @override
  _ObjectDetectorView createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  final _languageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();

  late String translateLang;

  late int sharedLanguage = 1;

  late var _onDeviceTranslator;

  //LocalModel model = LocalModel("yolov4-416-fp32.tflite");
  LocalModel model = LocalModel("object_labeler.tflite");
  late ObjectDetector objectDetector;
  List<String> labelsToSpeak = [];
  List<String> objects = [];

  //Text to speech object creation
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    getLang();

    if (sharedLanguage == 1) {
      translateLang = TranslateLanguage.ENGLISH;
      print('TRASLATE LANUAFEJVJ-----------?>> : $translateLang');
    } else if (sharedLanguage == 2) {
      translateLang = TranslateLanguage.HINDI;
      print('TRASLATE LANUAFEJVJ-----------?>> : $translateLang');
    } else if (sharedLanguage == 3) {
      translateLang = TranslateLanguage.GUJARATI;
      print('TRASLATE LANUAFEJVJ-----------?>> : $translateLang');
    }

    _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
        sourceLanguage: TranslateLanguage.ENGLISH,
        targetLanguage: translateLang);

    objectDetector = GoogleMlKit.vision.objectDetector(
        CustomObjectDetectorOptions(model,
            trackMutipleObjects: false, classifyObjects: true));
    super.initState();
    tts.setLanguage(translateLang);
    // tts.setVolume(0.9);
    tts.setSpeechRate(0.5);
    tts.setPitch(1);
    // tts.setVoice({"name": "en-in-x-enc-local", "locale": "en-IN"});
  }

  getLang() async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    if (instance.getInt('lang') == null) {
      await instance.setInt("lang", 1);
    }
    sharedLanguage = instance.getInt("lang")!;
  }

  Future<void> downloadModel() async {
    var result = await _languageModelManager.downloadModel('en');
    print('Model downloaded: $result');
    result = await _languageModelManager.downloadModel(translateLang);
    print('Model downloaded: $result');
  }

  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void dispose() {
    objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getLang();
    if (sharedLanguage == 1) {
      translateLang = TranslateLanguage.ENGLISH;
      // print('TRASLATE Build-----------?>> : $translateLang');
      _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
          sourceLanguage: TranslateLanguage.ENGLISH,
          targetLanguage: translateLang);
      tts.setLanguage(translateLang);
      // tts.setVolume(0.9);
      tts.setSpeechRate(0.9);
      tts.setPitch(1);


    } else if (sharedLanguage == 2) {


      translateLang = TranslateLanguage.HINDI;

      _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
          sourceLanguage: TranslateLanguage.ENGLISH,
          targetLanguage: translateLang);

      tts.setLanguage(translateLang);
      // tts.setVolume(0.9);
      tts.setSpeechRate(0.5);
      tts.setPitch(1);
      // print('TRASLATE Build-----------?>> : $translateLang');



    } else if (sharedLanguage == 3) {


      translateLang = TranslateLanguage.GUJARATI;

      _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
          sourceLanguage: TranslateLanguage.ENGLISH,
          targetLanguage: translateLang);
      // print('TRASLATE Build-----------?>> : $translateLang');
      tts.setLanguage(translateLang);
      // tts.setVolume(0.9);
      tts.setSpeechRate(0.5);
      tts.setPitch(1);
    }

    setState(() {});
    return CameraView(
      title: 'Object Detector',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.back,
    );
  }

  Future<void> translateText(String text) async {
    print("TRANSLATION INSIDE");
    //  const MethodChannel _channel = const MethodChannel('flutter_tts');
    //  final voices = await _channel.invokeMethod('getVoices');
    // final languages = await _channel.invokeMethod('getLanguages');
    // print(voices);
    // print(languages);

    // var voice = await tts1.getVoiceByLang('hi-IN');
    // print(voice);
    var result = await _onDeviceTranslator.translateText(text);
    setState(() {
      print("TRANSLATION $result");
      print('TRANSLATE LANG $translateLang');
      tts.speak(result);
    });
  }

  Future<void> processImage(InputImage inputImage) async {
    // print('INPUT IMAGE $inputImage');
    if (isBusy) return;
    downloadModel();
    isBusy = true;
    final result = await objectDetector.processImage(inputImage);

    //Returns detected objects
    print('RESULT $result');

    //Logic of speaking albel once
    result.forEach((element) {
      DetectedObject d = element;

      //Getting labels from detected objects to store it in objects list
      List<Label> ls = d.getLabels();

      //If list is not empty and label is there then we last label to
      //object lists

      if (ls.length != 0) {
        String str = ls[ls.length - 1].getText();

        if (objects.contains(str) == false) {
          //If detected object name not found in a objects list then we add last label
          //Clear the labelsToSpeak list
          objects.add(ls[ls.length - 1].getText());
          labelsToSpeak = [];
        }
      }

      //get labels to speak
      var labels = d.getLabels();

      //add labels to labelsToSpeack list
      for (var i = 0; i < labels.length; i++) {
        var text = labels[i].getText();
        print(labels[i].getText());

        if (!labelsToSpeak.contains(text)) {
          labelsToSpeak.add(labels[i].getText());
          // speak label only once
          print("TRANSLATION ----------------------");
          translateText(labels[i].getText());
        }
      }
    });
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        result.length > 0) {
      final painter = ObjectDetectorPainter(
          result,
          inputImage.inputImageData!.imageRotation,
          inputImage.inputImageData!.size);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
