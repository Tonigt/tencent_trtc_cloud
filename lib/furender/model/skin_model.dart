/*
 *  Copyright (C), 2015-2021
 *  FileName: skin_model
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class _SkinModel extends FuRenderModelAbstract with _SettingMixin {
  _SkinModel(VoidCallback updateState) : super(_FuType.skin, updateState, true);

  @override
  // TODO: implement recover
  bool get recover => true;

  @override
  // TODO: implement datas
  final List<ItemModel> datas = [
    ItemModel(title: "blur_level", image: "blur_level", value: 4.2, maxValue: 6.0, key: "blurLevel"),
    ItemModel(title: "color_level", image: "color_level", value: 0.3, maxValue: 1.0, key: "colorLevel"),
    ItemModel(title: "red_level", image: "red_level", value: 0.3, maxValue: 1.0, key: "redLevel"),
    ItemModel(title: "sharpen", image: "sharpen", value: 0.2, maxValue: 1.0, key: "sharpen"),
    ItemModel(title: "eye_bright", image: "eye_bright", value: 0, maxValue: 1.0, key: "eyeBright"),
    ItemModel(title: "tooth_whiten", image: "tooth_whiten", value: 0, maxValue: 1.0, key: "toothWhiten"),
    ItemModel(title: "remove_pouch_strength", image: "remove_pouch_strength", value: 0, maxValue: 1.0, key: "removePouchStrength"),
    ItemModel(title: "remove_nasolabial_folds_strength", image: "remove_nasolabial_folds_strength", value: 0, maxValue: 1.0, key: "removeNasolabialFoldsStrength")
  ];

  @override
  void onChangeValue(double value) {
    // TODO: implement onChangeValue
    super.onChangeValue(value);
    if(currentItem != null)
      TRTCCloud.sharedInstance().then((value) {
        value!._furenderValueChange(values: [
          MapEntry(currentItem!.key, currentItem!.value)
        ], method: type.rawValue);
      });
  }

  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    Map<String, dynamic> dic = {};
    Iterable<MapEntry<String, dynamic>> entrys = datas.map((e) => MapEntry(e.key, e.value));
    return dic..addEntries(entrys);
  }
}