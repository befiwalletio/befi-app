import 'package:cube/core/constant.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';
import 'package:get/get.dart';

class ScanCodePage extends StatefulWidget {
  final ValueChanged<String> callback;

  ScanCodePage({Key key, @required this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ScanCodePageState();
  }
}

class ScanCodePageState extends State<ScanCodePage> {
  List<RScanCameraDescription> rScanCameras;

  RScanCameraController controller;
  bool isFirst = true;

  void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    print('权限状态$status');
    if (status.isGranted) {
      rScanCameras = await availableRScanCameras();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {}
  }

  void initCamera() async {
    if (rScanCameras == null || rScanCameras.length == 0) {
      Permission permission = Permission.camera;
      PermissionStatus status = await permission.status;
      print('检测权限$status');
      if (status.isGranted) {
        rScanCameras = await availableRScanCameras();
      } else if (status.isDenied) {
        await requestPermission(permission);
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else if (status.isRestricted) {
        await openAppSettings();
      } else {
        await requestPermission(permission);
      }
    }
    if (rScanCameras != null && rScanCameras.length > 0) {
      controller = RScanCameraController(rScanCameras[0], RScanCameraResolutionPreset.high)
        ..addListener(() {
          final result = controller.result;
          if (result != null) {
            if (isFirst) {
              Navigator.of(context).pop(result);
              isFirst = false;
              Future.delayed(Duration(milliseconds: 500), () {
                if (widget.callback != null) {
                  widget.callback(result.message);
                }
              });
            }
          }
        })
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = SizeUtil.screenWidth();
    var screenHeight = SizeUtil.screenHeight();

    if (rScanCameras == null || rScanCameras.length == 0) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Text("Scan_Code_Tip3".tr),
        ),
      );
    }
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        // height: screenHeight,
        child: Stack(
          children: <Widget>[
            Container(
              height: screenHeight,
              child: ScanImageView(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: RScanCamera(controller),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 20,
              width: 44,
              height: 44,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.close,
                    size: SizeUtil.width(25),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 100, top: 20, right: 100),
              height: 44,
              width: screenWidth - 200,
              child: Center(
                  child: Text("Scan_Code".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeUtil.sp(18),
                      ),
                      textAlign: TextAlign.center)),
            ),
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30, top: (screenHeight - 180 - (screenWidth * 2 / 3)) / 2 + (screenWidth * 2 / 3) + 36, right: 30),
                  width: screenWidth - 60,
                  height: 20,
                  child: Center(

                  ),
                ),
                SizedBox(
                  height: 36,
                ),
                InkWell(
                  onTap: () {
                    manageFlash();
                  },
                  child: Image(
                    image: AssetImage(Constant.Assets_Image + "home_scan_light.png"),
                    width: 48,
                    height: 48,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, top: 12, right: 30),
                  width: screenWidth - 60,
                  height: 20,
                  child: Center(
                      child: Text("Scan_Code_Tip2".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeUtil.sp(12),
                          ),
                          textAlign: TextAlign.center)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> canOpenCameraView() async {
    var status = await Permission.camera;
    if (status != PermissionStatus.granted) {
      var future = await Permission.camera.status;
      if (future != PermissionStatus.granted) {
        return false;
      }
    } else {
      return true;
    }
    return true;
  }

  void manageFlash() async {
    bool isOpen = await controller.getFlashMode();
    if (isOpen) {
      await controller.setFlashMode(false);
    } else {
      await controller.setFlashMode(true);
    }
  }

  void closeFlash() async {
    bool isOpen = await controller.getFlashMode();
    if (isOpen) {
      await controller.setFlashMode(false);
    }
  }

  void openFlash() async {
    bool isOpen = await controller.getFlashMode();
    if (!isOpen) {
      await controller.setFlashMode(true);
    }
  }
}

class ScanImageView extends StatefulWidget {
  final Widget child;

  const ScanImageView({Key key, this.child}) : super(key: key);

  @override
  _ScanImageViewState createState() => _ScanImageViewState();
}

class _ScanImageViewState extends State<ScanImageView> with TickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) => CustomPaint(
              foregroundPainter: _ScanPainter(controller.value, Colors.white, Colors.green),
              child: widget.child,
              willChange: true,
            ));
  }
}

class _ScanPainter extends CustomPainter {
  final double value;
  final Color borderColor;
  final Color scanColor;

  _ScanPainter(this.value, this.borderColor, this.scanColor);

  Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paint == null) {
      initPaint();
    }
    double width = size.width;
    double height = size.height;

    double boxWidth = size.width * 2 / 3;
    double boxHeight = boxWidth;

    double left = (width - boxWidth) / 2;
    double top = (height - 180 - boxWidth) / 2;
    double bottom = boxHeight + top;
    double right = left + boxWidth;
    _paint.color = borderColor;
    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    canvas.drawRect(rect, _paint);

    _paint.strokeWidth = 3;

    Path path1 = Path()
      ..moveTo(left, top + 10)
      ..lineTo(left, top)
      ..lineTo(left + 10, top);
    canvas.drawPath(path1, _paint);
    Path path2 = Path()
      ..moveTo(left, bottom - 10)
      ..lineTo(left, bottom)
      ..lineTo(left + 10, bottom);
    canvas.drawPath(path2, _paint);
    Path path3 = Path()
      ..moveTo(right, bottom - 10)
      ..lineTo(right, bottom)
      ..lineTo(right - 10, bottom);
    canvas.drawPath(path3, _paint);
    Path path4 = Path()
      ..moveTo(right, top + 10)
      ..lineTo(right, top)
      ..lineTo(right - 10, top);
    canvas.drawPath(path4, _paint);

    _paint.color = scanColor;

    final scanRect = Rect.fromLTWH(left + 10, top + 10 + (value * (boxHeight - 20)), boxWidth - 20, 3);

    _paint.shader = LinearGradient(colors: <Color>[
      Colors.white54,
      Colors.white,
      Colors.white54,
    ], stops: [
      0.0,
      0.5,
      1,
    ]).createShader(scanRect);
    canvas.drawRect(scanRect, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void initPaint() {
    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }
}
