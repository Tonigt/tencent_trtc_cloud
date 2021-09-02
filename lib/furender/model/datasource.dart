/*
 *  Copyright (C), 2015-2021
 *  FileName: datasource
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class _FuRenderDatasource {

  _FuRenderDatasource() {
    datas = [
      _SkinModel(_setState),
      _ShapeModel(_setState),
      _BeautyFilterModel(_setState),
      // _StickerModel(),
      _MakeUpModel(_setState),
      _BodyModel(_setState)
    ];
  }

  /// 监听者
  ValueChangeListener? listener;

  /// 位置
  _FuType type = _FuType.unknown;
  /// 更新状态
  late void Function(VoidCallback) updateState;

  /// 当前设置项
  FuRenderModelAbstract? get currentSettingItem =>
      type == _FuType.unknown ? null : datas.firstWhere((element) => element.type == type);

  /// 是否有滑动条
  bool get hasSlider {
    var model = currentSettingItem;
    if (model == null)
      return false;
    return model.hasSelected && (model.recover || model.index != 0);
  }

  /// 数据源
  late final List<FuRenderModelAbstract> datas;

  /// 工具bar 隐藏
  void onBarHide(){
    _indexReset();
  }

  /// 页面销毁
  void onPageDispose(){
    _indexReset();
    datas.forEach((element) {
      element._indexReset();
    });
  }

  /// 选中文件
  void onSelect(_FuType type){
    this.type = type;
    _setState();
  }

  /// 重置数据
  void _indexReset(){
    type = _FuType.unknown;
  }

  void onChangeValue(double value){
    currentSettingItem?.onChangeValue(value);
  }

  void onChangeEnd(double value){
    notifyValueChange();
  }

  void itemValueReset(){
    currentSettingItem?.resetValue();
    notifyValueChange();
  }

  void onSelectIndex(int index){
    currentSettingItem?.onSelectIndex(index);
  }

  void _setState(){
    updateState((){});
  }

  void notifyValueChange(){
    listener?.valueChange(this.toJson());
  }

  /// 参数集合
  Map<String, dynamic> toJson(){
    Map<String, dynamic> dic = {};
    Iterable<MapEntry<String, dynamic>> values = datas.map((e) => MapEntry(e.type.rawValue, e.toJson()));
    return dic..addEntries(values);
  }

  /// 初始化
  void settingParameter(Map<String, dynamic> map){
    datas.forEach((element) {
      element.settingParameter(map[element.type.rawValue]);
    });
  }
}