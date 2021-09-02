/*
 *  Copyright (C), 2015-2021
 *  FileName: furender_implement
 *  Author: Tonight丶相拥
 *  Date: 2021/9/1
 *  Description: 
 **/

part of furender;

mixin FurenderImplement {
  late MethodChannel _channel;

  void setChannel(MethodChannel channel){
    _channel = channel;
  }

  /// 相芯启动
  Future _setUpFuRender(dynamic value, {int maxFaces: 4, Map<String, dynamic> parameter = const {}}) async{
    await _channel.invokeMethod("FUSetUp",
        {
          "authPack": value,
          "maxFace": maxFaces
        }..addAll(parameter));
    return null;
  }

  /// 值改变
  Future _furenderValueChange({List<MapEntry<String, double>>? values, required String method}) async{
    Map<String, double> m = {};
    if (values != null && values.length > 0) {
      m.addEntries(values);
    }else {
      return;
    }

    await _channel.invokeMethod(method, m);
    return;
  }

  /// 补妆改变
  Future _makeUpChange({String? imageName, required double value}) async{
    Map<String, dynamic> dic = {
      "imageName": imageName,
      "intensity": value
    };
    await _channel.invokeMethod("makeUp", dic);
    return;
  }

  /// 滤镜改变
  Future _filterChange({required String imageName, required double value}) async{
    Map<String, dynamic> dic = {
      "imageName": imageName,
      "filterLevel": value
    };
    await _channel.invokeMethod("filter", dic);
    return;
  }
}