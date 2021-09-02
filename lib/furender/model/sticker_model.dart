/*
 *  Copyright (C), 2015-2021
 *  FileName: sticker_model
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;


class _StickerModel extends FuRenderModelAbstract {
  _StickerModel(VoidCallback updateState):super(_FuType.sticker, updateState);

  @override
  // TODO: implement recover
  bool get recover => super.recover;

  @override
  // TODO: implement datas
  List<ItemModel> get datas => super.datas;

  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
  }

  @override
  void onChangeValue(double value) {
    // TODO: implement onChangeValue
    super.onChangeValue(value);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    Map<String, dynamic> dic = {};
    Iterable<MapEntry<String, dynamic>> entrys = datas.map((e) => MapEntry(e.key, e.value));
    return dic..addEntries(entrys);
  }

  @override
  void settingParameter(Map<String, dynamic> map) {
    // TODO: implement settingParameter
  }
}