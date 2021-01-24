import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("测试"),
            ),
            body: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Container(
                        height: 180.0,
                        child: BannerView(
                          children: <Widget>[
                            Image.network(
                                "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=226239534,3003769231&fm=26&gp=0.jpg",
                                fit: BoxFit.cover),
                            Image.network(
                                "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=169187743,1587801836&fm=11&gp=0.jpg",
                                fit: BoxFit.cover),
                            Image.network(
                                "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2960543624,4209728984&fm=26&gp=0.jpg",
                                fit: BoxFit.cover),
                            Image.network(
                                "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1076451669,827930234&fm=26&gp=0.jpg",
                                fit: BoxFit.cover),
                            Image.network(
                                "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=358876052,3398760074&fm=26&gp=0.jpg",
                                fit: BoxFit.cover),
                            Image.network(
                                "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3674427685,3881867419&fm=26&gp=0.jpg",
                                fit: BoxFit.cover),
                          ],
                        ));
                  } else {
                    return InkWell(child: Listener(child: Text("我是条目咯") ,onPointerDown: (_){
                      print("点了一下");
                    },)) ;
                  }
                })));
  }
}

class BannerView extends StatefulWidget {
  final List<Widget> children;

  ///切换时间
  final Duration switchDuration;

  BannerView(
      {this.children = const <Widget>[],
      this.switchDuration = const Duration(seconds: 3)});

  @override
  _BannerViewState createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  int _curPageIndex;

  static const Duration animateDuration = const Duration(milliseconds: 500);

  Timer _timer;

  List<Widget> children = [];

  @override
  void initState() {
    super.initState();
    _curPageIndex = 0;
    _tabController = TabController(length: widget.children.length, vsync: this);

    children.addAll(widget.children);
    // 定时器完成自动翻页
    if (widget.children.length > 1) {
      children.insert(0, widget.children.last);
      children.add(widget.children.first);
      //如果大于一页，则会在前后都加一页， 初始页要是 1
      _curPageIndex = 1;
      _timer = Timer.periodic(widget.switchDuration, _nextBanner);
    }

    ///初始页面 指定
    _pageController = PageController(initialPage: _curPageIndex);
  }

  void _nextBanner(Timer timer) {
    _curPageIndex++;
    _curPageIndex = _curPageIndex == children.length ? 0 : _curPageIndex;

    //curve:和android一样 动画插值
    _pageController.animateToPage(_curPageIndex,
        duration: animateDuration, curve: Curves.linear);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Listener(
            onPointerDown: (_) {
              _timer?.cancel();
            },
            onPointerUp: (_) {
              if (widget.children.length > 1) {
                _timer = Timer.periodic(widget.switchDuration, _nextBanner);
              }
            },
            child: NotificationListener(
              onNotification: (notification) {
                /// start、update、end
                if (notification is ScrollUpdateNotification) {
                  ScrollUpdateNotification n = notification;
                  //是一个完整页面的偏移
                  if (n.metrics.atEdge) {
                    //判断滑动更新的时候 是不是已经到达了一个新界面 到了新界面再执行下面的逻辑
                    if (_curPageIndex == children.length - 1) {
                      _pageController.jumpToPage(1);
                    } else if (_curPageIndex == 0) {
                      _pageController.jumpToPage(children.length - 2);
                    }
                  }
                }
              },
              child: PageView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: children[index],
                      onTap: () {
                        print("点击item!");
                      },
                    );
                  },
                  controller: _pageController,

                  ///要到新页面的时候 把新页面的index给我们
                  onPageChanged: (index) {
                    _curPageIndex = index;
                    //如果是最后一页 ，让pageview jump到第1页
                    if (index == children.length - 1) {
//                  _pageController.jumpToPage(1);
                      //指示器只有两页
                      _tabController.animateTo(0);
                    } else if (index == 0) {
                      ///第1页回滑， 滑到第0页。第0页的内容是倒数第二页，是所有真实页面的最后一页的内容
                      ///指示器 到 tab的最后一个
                      _tabController.animateTo(_tabController.length - 1);
//                  _pageController.jumpToPage(children.length - 2);
                    } else {
                      _tabController.animateTo(index - 1);
                    }
                  }),
            )),
        Positioned(
          child: TabPageSelector(
            controller: _tabController,
            color: Colors.white,
            selectedColor: Colors.grey,
          ),
          bottom: 8.0,
          right: 8.0,
        )
      ],
    );
  }
}
