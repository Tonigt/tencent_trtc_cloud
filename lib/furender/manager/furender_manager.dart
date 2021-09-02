/*
 *  Copyright (C), 2015-2021
 *  FileName: furender_manager
 *  Author: Tonight丶相拥
 *  Date: 2021/9/1
 *  Description: 
 **/

part of furender;

class FuRenderManager {
  static FuRenderManager? _manager;
  static FuRenderManager get manager => _manager ?? _getInstance();

  static FuRenderManager _getInstance(){
    if (_manager == null) {
      _manager = FuRenderManager._();
    }
    return _manager!;
  }

  // 禁止外部初始化
  FuRenderManager._();

  /// 数据源
  _FuRenderDatasource _datasource = _FuRenderDatasource();

  /// 启动furender
  Future<void> setUp(dynamic authPack, {int? maxFace, ValueChangeListener? listener}) async{
    if (listener != null) {
      Map<String, dynamic> value = {};
      _datasource.listener = listener;
      value = await listener.getOriginalValue();
      _datasource.settingParameter(value);
    }
    TRTCCloud.sharedInstance().then((value) {
      value!._setUpFuRender(authPack,
          maxFaces: maxFace ?? 4,
          parameter: _datasource.toJson());
    });
  }
}