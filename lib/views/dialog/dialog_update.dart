import 'dart:io';

import 'package:cube/core/constant.dart';
import 'package:cube/core/core.dart';
import 'package:cube/models/model_base.dart';
import 'package:cube/net/manager_api.dart';
import 'package:cube/net/requester.dart';
import 'package:cube/utils/utils_event.dart';
import 'package:cube/utils/utils_size.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

checkUpdate(BuildContext context, BoolCallback callback) async {
  Result<UpdateModel> result = await requestVersion();
  callback(result.result.force);
  if (int.parse(Global.CLIENT_C) < result.result.vCode) {
    return await showUpdateDialog(context, result.result);
  } else {
    return Future.value(result.result);
  }
}

showUpdateDialog(BuildContext context, UpdateModel model) async {
  return await showDialog(
      useSafeArea: false,
      barrierDismissible: !model.force,
      context: context,
      builder: (context) {
        return model.force
            ? WillPopScope(
                child: UpdateVersionDialog(
                  model: model,
                ),
                onWillPop: () async {
                  SystemNavigator.pop();
                  return false;
                })
            : UpdateVersionDialog(
                model: model,
              );
      });
}

class UpdateVersionDialog extends StatefulWidget {
  static final String sName = "UpdateVersionDialog";
  final UpdateModel model;

  UpdateVersionDialog({Key key, this.model}) : super(key: key);

  @override
  UpdateVersionDialogState createState() => new UpdateVersionDialogState();
}

class UpdateVersionDialogState extends State<UpdateVersionDialog> {
  UpdateModel model;
  var _downloadProgress = 0.0;
  bool isDownLoad = false;
  String updateText = 'CommonUpdate'.tr;

  @override
  void initState() {
    super.initState();
    model = widget.model;
    eventBus.on<UpdateDownProgress>().listen((updateDownProgress) {
      if (updateDownProgress != null) {
        progress(updateDownProgress.progress);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(SizeUtil.width(10))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: Image.asset("assets/images/img_update_version.jpg"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(SizeUtil.width(10)), bottomRight: Radius.circular(SizeUtil.width(10)))),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: SizeUtil.padding(left: 14, right: 14),
                                width: double.infinity,
                                child: Text(
                                  "CommonFindNew".tr + '(v${model.vName})',
                                  style: TextStyle(color: Color(0xFF262536), fontWeight: FontWeight.normal, fontSize: SizeUtil.sp(18)),
                                ),
                              ),
                              SizedBox(height: SizeUtil.height(14)),
                              Container(
                                padding: SizeUtil.padding(left: 14, right: 14, top: 4, bottom: 4),
                                width: double.infinity,
                                child: Text(
                                  model.vNote,
                                  style: TextStyle(color: Color(0xFF2A2A3C), fontWeight: FontWeight.normal, fontSize: SizeUtil.sp(12)),
                                  strutStyle: StrutStyle(),
                                ),
                              ),
                              SizedBox(height: SizeUtil.height(10)),
                              Divider(
                                height: 1,
                                color: Color(0xFFE9E9E9),
                              ),
                              SizedBox(height: SizeUtil.height(10)),
                              InkWell(
                                onTap: () async {
                                  if (model.url.contains(".apk") && Platform.isAndroid) {
                                    if (!isDownLoad) {
                                      await _downLoad(
                                        model.url,
                                      );
                                      isDownLoad = true;
                                    }
                                  } else {
                                    _openUrl(model.url);
                                  }
                                },
                                child: Text(
                                  updateText,
                                  style: TextStyle(color: BeeColors.blue, fontWeight: FontWeight.normal, fontSize: SizeUtil.sp(16)),
                                ),
                              ),
                              SizedBox(height: SizeUtil.height(10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(height: SizeUtil.height(30)),
                      IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white60,
                          ),
                          onPressed: () {
                            if (model.force) {
                              SystemNavigator.pop();
                            } else {
                              Navigator.pop(context);
                            }
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void progress(_progress) {
    if (mounted) {
      setState(() {
        _downloadProgress = _progress;
        updateText = "CommonDownloading".tr + ' ${_progress.toString()}%';
        if (_downloadProgress == 1) {
          Navigator.of(context).pop();
          _downloadProgress = 0.0;
        }
      });
    }
  }
}

_downLoad(String url) async {
  var directory = await getTemporaryDirectory();
  String path = "${directory.path}/app.apk";
  File savePath = File(path);
  if (!await savePath.exists()) {
    savePath.create(recursive: true);
  }
  bool isFinish = false;
  await downLoad(savePath, url, path, onReceiveProgress: (int count, int total) {
    var _progress = count / total * 100;

    UpdateDownProgress updateDownProgress = UpdateDownProgress();
    updateDownProgress.progress = NumUtil.getNumByValueDouble(_progress, 2);
    eventBus.fire(updateDownProgress);

    if (total != -1) {
      if (total == count) {
        isFinish = true;
      }
    }
  });
  if (isFinish) {
    OpenFile.open(path);
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

void _openUrl(String url) async {
  if (Platform.isAndroid && await canLaunch(url)) {
    await (launch(url));
  } else {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
