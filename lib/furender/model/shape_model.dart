/*
 *  Copyright (C), 2015-2021
 *  FileName: shape_model
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class _ShapeModel extends FuRenderModelAbstract with _SettingMixin {
  _ShapeModel(VoidCallback updateState): super(_FuType.shape, updateState, true);

  @override
  // TODO: implement recover
  bool get recover => true;

  @override
  // TODO: implement datas
  final List<ItemModel> datas = [
    ItemModel(title: "cheek_thinning", image: "cheek_thinning", value: 0, maxValue: 1.0, key: "cheekThinning"),
    ItemModel(title: "cheek_v", image: "cheek_v", value: 0.5, maxValue: 1.0, key: "cheekV"),
    ItemModel(title: "cheek_narrow", image: "cheek_narrow", value: 0, maxValue: 0.5, key: "cheekNarrow"),
    ItemModel(title: "cheek_small", image: "cheek_small", value: 0, maxValue: 0.5, key: "cheekSmall"),
    ItemModel(title: "intensity_cheekbones", image: "intensity_cheekbones", value: 0, maxValue: 1.0, key: "intensityCheekbones"),
    ItemModel(title: "intensity_lower_jaw", image: "intensity_lower_jaw", value: 0, maxValue: 1.0, key: "intensityLowerJaw"),
    ItemModel(title: "eye_enlarging", image: "eye_enlarging", value: 0.4, maxValue: 1.0, key: "eyeEnlarging"),
    ItemModel(title: "intensity_eye_circle", image: "intensity_eye_circle", value: 0, maxValue: 1.0, key: "intensityEyeCircle"),
    ItemModel(title: "intensity_chin", image: "intensity_chin", value: 0.3, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityChin"),
    ItemModel(title: "intensity_forehead", image: "intensity_forehead", value: 0.3, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityForehead"),
    ItemModel(title: "intensity_nose", image: "intensity_nose", value: 0.5, maxValue: 1.0, key: "intensityNose"),
    ItemModel(title: "intensity_mouth", image: "intensity_mouth", value: 0.4, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityMouth"),
    ItemModel(title: "intensity_canthus", image: "intensity_canthus", value: 0, maxValue: 1.0, key: "intensityCanthus"),
    ItemModel(title: "intensity_eye_space", image: "intensity_eye_space", value: 0.5, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityEyeSpace"),
    ItemModel(title: "intensity_eye_rotate", image: "intensity_eye_rotate", value: 0.5, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityEyeRotate"),
    ItemModel(title: "intensity_long_nose", image: "intensity_long_nose", value: 0.5, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityLongNose"),
    ItemModel(title: "intensity_philtrum", image: "intensity_philtrum", value: 0.5, maxValue: 1.0, style01: true, minValue: -1.0, key: "intensityPhiltrum"),
    ItemModel(title: "intensity_smile", image: "intensity_smile", value: 0, maxValue: 1.0, key: "intensitySmile")
  ];

  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
  }

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
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    Map<String, dynamic> dic = {};
    Iterable<MapEntry<String, dynamic>> entrys = datas.map((e) => MapEntry(e.key, e.value));
    return dic..addEntries(entrys);
  }
}