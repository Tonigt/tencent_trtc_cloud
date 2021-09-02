/*
 *  Copyright (C), 2015-2021
 *  FileName: fu_image_view
 *  Author: Tonight丶相拥
 *  Date: 2021/8/25
 *  Description: 
 **/

part of furender;



const String _baseAddress = "assets/images/";
class _FuRenderImageView extends StatelessWidget {
  _FuRenderImageView(this.image);
  final String image;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Image.asset(_baseAddress + image, package: "tencent_trtc_cloud");
  }
}

class _RecoverImage extends _FuRenderImageView {
  _RecoverImage(): super("recover.png");
}