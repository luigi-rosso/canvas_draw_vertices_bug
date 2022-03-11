import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

late ui.Image owl;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var bytes = await rootBundle.load('assets/owl.jpeg');

  var codec = await ui.instantiateImageCodec(Uint8List.view(bytes.buffer));
  var frameInfo = await codec.getNextFrame();
  owl = frameInfo.image;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _boundary = GlobalKey();
  ui.Image? _capturedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: RepaintBoundary(
                key: _boundary,
                child: CustomPaint(
                  painter: OwlMeshPainter(),
                ),
              ),
            ),
            if (_capturedImage != null)
              CustomPaint(
                painter: CapturedImagePainter(_capturedImage!),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final RenderRepaintBoundary boundary = _boundary.currentContext!
              .findRenderObject()! as RenderRepaintBoundary;

          final ui.Image image = await boundary.toImage();
          setState(() {
            _capturedImage = image;
          });
          // final ByteData? byteData =
          //     await image.toByteData(format: ui.ImageByteFormat.png);
          // final Uint8List pngBytes = byteData!.buffer.asUint8List();
          // print(pngBytes);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class OwlMeshPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    var vertices = ui.Vertices(
      VertexMode.triangles,
      <Offset>[
        const Offset(0, 0),
        Offset(size.width, 0),
        Offset(size.width, size.height),
        Offset(0, size.height),
      ],
      textureCoordinates: <Offset>[
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(1, 1),
        const Offset(0, 1),

        /// Comment these coords in and uncomment the previous 4 to see it work
        /// in the CapturedImagePainter, but not in the OwlMeshPainter.
        // const Offset(0, 0),
        // Offset(owl.width.toDouble(), 0),
        // Offset(owl.width.toDouble(), owl.height.toDouble()),
        // Offset(0, owl.height.toDouble()),
      ],
      indices: <int>[0, 1, 2, 2, 3, 0],
    );
    canvas.drawVertices(
      vertices,
      BlendMode.srcOver,
      Paint()
        ..shader = ui.ImageShader(
          owl,
          ui.TileMode.clamp,
          ui.TileMode.clamp,
          Float64List.fromList(
            <double>[
              1 / owl.width,
              0.0,
              0.0,
              0.0,
              0.0,
              1 / owl.height,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0,
              0.0,
              0.0,
              0.0,
              0.0,
              1.0
            ],
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CapturedImagePainter extends CustomPainter {
  final ui.Image image;

  CapturedImagePainter(this.image);
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawImage(image, Offset(-image.width / 2, 0), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
