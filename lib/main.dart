import 'dart:io' as Io;
// import 'package:flutter/material.dart';
// import 'package:image/image.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:photo_view/photo_view.dart';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload and Processing',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const ImagePickerTutorial(),
    );
  }
}

class ImagePickerTutorial extends StatefulWidget {
  const ImagePickerTutorial({Key? key}) : super(key: key);

  @override
  _ImagePickerTutorialState createState() => _ImagePickerTutorialState();
}

class _ImagePickerTutorialState extends State<ImagePickerTutorial> {
  Io.File? pickedImage;
  bool isPicked = false;
  Uint8List? processedImageBytes; // Store processed image as Uint8List

  Future<void> sendImageToServer(Io.File imageFile) async {
    List<int> imageBase64 = imageFile.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    img.Image realImage = img.Image.memory(uint8list);

    img.Image thumbnail = copyResize(realImage, width: 256);
    final url = Uri.parse(
        'http://192.168.1.135:5000/upload'); // http://thechesstwo.pythonanywhere.com/upload
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      http.MultipartFile(
        'file',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: 'image.png',
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image sent successfully');
        final responseString = await response.stream.bytesToString();
        processedImageBytes =
            base64Decode(json.decode(responseString)['image']);
        setState(() {});
      } else {
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  Future<void> _showSaveImageDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Save Image"),
          content: Text("Do you want to save this image?"),
          actions: [
            TextButton(
              onPressed: () {
                // Add code here to save the image to the device.
                // You can use the processedImageBytes and save it to the device's storage.
                // Once saved, you can display a confirmation message.
                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pixaglow"),
      ),
      body: Stack(
        children: [
          Image.asset(
            'images/bg.jpg', // Replace with your image path
            fit: BoxFit.cover, // You can adjust the BoxFit as needed
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: GestureDetector(
              onLongPress: () {
                if (processedImageBytes != null) {
                  _showSaveImageDialog();
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: processedImageBytes != null
                          ? PhotoView(
                              imageProvider: MemoryImage(processedImageBytes!),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered,
                            )
                          : isPicked
                              ? PhotoView(
                                  imageProvider: FileImage(pickedImage!),
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale: PhotoViewComputedScale.covered,
                                )
                              : Container(
                                  color: Colors
                                      .transparent, // Make this container transparent
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width *
                                      (4 / 3),
                                ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        final XFile? imagem = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (imagem != null) {
                          pickedImage = Io.File(imagem.path);
                          setState(() {
                            isPicked = true;
                          });
                          await sendImageToServer(pickedImage!);
                        }
                      },
                      child: const Text("Pick Image"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
