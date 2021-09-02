/*
 *  Copyright (C), 2015-2021
 *  FileName: reset_button
 *  Author: Tonight丶相拥
 *  Date: 2021/8/26
 *  Description: 
 **/

part of furender;

class _ResetButton extends StatelessWidget {
  _ResetButton(this.valueReset);
  final VoidCallback? valueReset;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: 76,
      child: InkWell(
          onTap: valueReset,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Expanded(child: ),
                    Spacer(),
                    _RecoverImage(),
                    Spacer(),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white.withOpacity(0.2),
                    )
                  ],
                ),
                SizedBox(
                    height: 8
                ),
                Text("reset", style: TextStyle(
                    fontSize: 13,
                    color: Colors.white
                ))
              ]
          )
      ),
    );
  }
}