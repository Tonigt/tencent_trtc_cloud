/*
 *  Copyright (C), 2015-2021
 *  FileName: type_abstract
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

abstract class FuRenderModelAbstract {
  FuRenderModelAbstract(this.type, this.updateState, [this.notifyValueChange = false]);

  /// 位置
  int index = -1;
  bool get hasSelected => index != -1;
  /// 类型
  _FuType type;
  bool notifyValueChange;
  /// 数据源
  List<ItemModel> datas = [];
  bool recover = false;

  VoidCallback updateState;

  ItemModel? get currentItem {
    if (!hasSelected) {
      return null;
    }
    return datas[index];
  }

  /// 选中
  @mustCallSuper
  void onSelectIndex(int index){
    this.index = index;
    this.updateState();
  }

  /// 更改值
  @mustCallSuper
  void onChangeValue(double value){
    currentItem?.value = value * (currentItem?.maxValue ?? 1);
    // if (currentItem?.style01 ?? true)
    //   return;
    this.updateState();
  }

  void resetValue(){
    if (!hasSelected)
      return;
    datas[index].resetValue();
    this.updateState();
    if(currentItem != null)
      TRTCCloud.sharedInstance().then((value) {
        value!._furenderValueChange(values: [
          MapEntry(currentItem!.key, currentItem!.value)
        ], method: type.rawValue);
      });
  }

  dynamic toJson();

  void settingParameter(Map<String, dynamic> map);

  /// 重置
  void _indexReset(){
    index = -1;
  }
}


class ItemModel {
  ItemModel({required this.title,
    required this.image,
    required this.value,
    required this.maxValue,
    this.minValue: 0,
    this.style01: false,
    this.hasStatus: true,
    this.key = ""
  }): this.defaultValue = value;
  /// 标题
  final String title;
  /// 图标
  final String image;
  final String key;
  /// 值
  double value;
  final double defaultValue;
  final double minValue;
  final double maxValue;
  /// 恢复
  final bool style01;
  final bool hasStatus;

  bool get valueIsNotDefault => value != defaultValue;

  void resetValue(){
    value = defaultValue;
  }
}