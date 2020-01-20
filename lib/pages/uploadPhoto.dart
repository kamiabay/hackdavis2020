import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;


class UploadRoute extends CupertinoPageRoute<Null>{
  String uid;
  UploadRoute(this.uid) : super (builder: (BuildContext context){
    return new Upload(uid);
  });
}

class Upload extends StatefulWidget {
  String uid;
  Upload(this.uid);
  @override
  _UploadState createState() => _UploadState(uid);
}



class _UploadState extends State<Upload> {
  String uid;
  _UploadState(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Update your profile picture",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.9),
      ),
      body: ImageCapture(uid),
    );
  }
}

/// Widget to capture and crop the image
class ImageCapture extends StatefulWidget {
  String uid;
  ImageCapture(this.uid);
  createState() => _ImageCaptureState(uid);
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  File _imageFile;
  String uid2;
  _ImageCaptureState(this.uid2);

  /// Cropper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source,maxHeight: 450,maxWidth: 450);
    setState(() {
      _imageFile = selected;
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(17.0),
        child: FloatingActionButton(
          child: IconButton(
            icon: Icon(
              Icons.photo_library,
              size: 30,
            ),
            onPressed: () => _pickImage(ImageSource.gallery),
            color: Colors.white,
          ),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ),
//        bottomNavigationBar: BottomAppBar(
//          child: Row(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            children: <Widget>[
////              IconButton(
////                icon: Icon(
////                  Icons.photo_camera,
////                  size: 30,
////                ),
////                onPressed: () => _pickImage(ImageSource.camera),
////                color: Colors.blue,
////              ),
//              IconButton(
//                icon: Icon(
//                  Icons.photo_library,
//                  size: 35,
//                ),
//                onPressed: () => _pickImage(ImageSource.gallery),
//                color: Colors.green,
//              ),
//            ],
//          ),
//        ),
      body: ListView(
        children: <Widget>[
          if (_imageFile != null)

            ...[
              Container(
                  height: MediaQuery.of(context).size.height* 0.6,
                  width: MediaQuery.of(context).size.width,
                  // color: Colors.yellow,
                  padding: EdgeInsets.all(0),
                  child: Image.file(_imageFile)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ButtonTheme(
                    height: 50,
                    minWidth: 115,
                    child: RaisedButton(
                      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: Colors.black,
                      child: Icon(Icons.crop,color: Colors.white,),
                      onPressed: _cropImage,
                    ),
                  ),
                  ButtonTheme(
                    height: 50,
                    minWidth: 115,
                    child: FlatButton(
                      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.black,
                      child: Icon(Icons.refresh,color: Colors.white,),
                      onPressed: _clear,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Uploader(
                  image: _imageFile,
                  uid: uid2,
                ),
              )
            ]
        ],
      ),
    );
  }
}

/// Widget used to handle the management of
class Uploader extends StatefulWidget {
  File image;
  String uid;


  Uploader({Key key, this.image,this.uid}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {

  final StorageReference storageReference = FirebaseStorage().ref();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://hackdavis2020-263302.appspot.com/');
  StorageUploadTask _uploadTask;
  var firestore = Firestore.instance;


  void initState() {
    super.initState();
  }


  Future uploadAvatarImage(BuildContext context) async {
    String fileName = p.basename(widget.image.path);
    var store = storageReference.child(widget.uid);
    StorageUploadTask storageUploadTask = store.putFile(widget.image);
  }
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 30,
    );
    return result;
  }
  Future getImage() async {
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery,maxHeight: 400,maxWidth: 400);
    //var image = await testCompressAndGetFile(widget.image,  widget.image.path);
    setState(() {
      widget.image = widget.image;
    });
    uploadAvatarImage(context);
  }




  _startUpload() async {
    String filePath = 'publicPhoto/${widget.uid}';
    //File newimage = await testCompressAndGetFile(widget.image,widget.image.path);
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.image);
    });
    var downurl = await (await _uploadTask.onComplete).ref.getDownloadURL();
    String url = downurl.toString();
  }



  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null ? event.bytesTransferred / event.totalByteCount : 0;

            return Container(
              height: 80,
              // color:Colors.indigoAccent,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_uploadTask.isComplete)
                      Text("Done!!",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                              height: 1,
                              fontSize: 30)),

                    if (_uploadTask.isPaused)
                      FlatButton(
                        child: Icon(Icons.play_arrow, size: 50),
                        onPressed: _uploadTask.resume,
                      ),
                    if (_uploadTask.isInProgress)
                      FlatButton(
                        child: Icon(Icons.pause, size: 50),
                        onPressed: _uploadTask.pause,
                      ),


//              LinearProgressIndicator(value: progressPercent),
//              Text(
//              '${(progressPercent * 100).toStringAsFixed(2)} % ',
//              style: TextStyle(fontSize: 50),
//               ),
                  ]
              ),
            );
          });
    } else {
      return ButtonTheme(
        minWidth: 80.0,
        height: 50.0,
        child: FlatButton(
            shape: RoundedRectangleBorder(side: BorderSide(
                color: Colors.green,
                width: 1,
                style: BorderStyle.solid
            ), borderRadius: BorderRadius.circular(50)),
            color: Colors.green,

            child: Text('Update',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 22
              ),
            ),
            // icon: Icon(Icons.cloud_upload,color: Colors.white,),
            onPressed: _startUpload
        ),
      );
    }
  }
}