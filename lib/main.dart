import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pagination_provider/ListController.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataListView(),
    );
  }
}

class DataListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
      create: (context) => ListController(),
      child: Consumer<ListController>(builder:
          (BuildContext context, ListController controller, Widget? _) {
        switch (controller.dataState) {
          case DataState.Uninitialized:
            Future(() {
              controller.fetchData();
            });
            return _ListViewWidget(controller.dataList, true);
          case DataState.Initial_Fetching:
            return Container();
          case DataState.More_Fetching:
          case DataState.Refreshing:
            return _ListViewWidget(controller.dataList, true);
          case DataState.Fetched:
          case DataState.Error:
          case DataState.No_More_Data:
            return _ListViewWidget(controller.dataList, false);
        }
      }),
    ));
  }
}

class _ListViewWidget extends StatelessWidget {
  final List<String> _data;
  bool _isLoading;
  _ListViewWidget(this._data, this._isLoading);
  late DataState _dataState;
  late BuildContext _buildContext;
  @override
  Widget build(BuildContext context) {
    _dataState = Provider.of<ListController>(context, listen: false).dataState;
    _buildContext = context;
    return SafeArea(child: _scrollNotificationWidget());
  }

  Widget _scrollNotificationWidget() {
    return Column(
      children: [
        Expanded(
            child: NotificationListener<ScrollNotification>(
                onNotification: _scrollNotification,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _onRefresh();
                  },
                  child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_data[index],
                                    style: TextStyle(fontSize: 15)),
                              )));
                    },
                  ),
                ))),
        if (_dataState == DataState.More_Fetching)
          Center(child: CircularProgressIndicator()),
      ],
    );
  }

  bool _scrollNotification(ScrollNotification scrollInfo) {
    if (!_isLoading &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      _isLoading = true;
      Provider.of<ListController>(_buildContext, listen: false).fetchData();
    }
    return true;
  }

  _onRefresh() async {
    if (!_isLoading) {
      _isLoading = true;
      Provider.of<ListController>(_buildContext, listen: false)
          .fetchData(isRefresh: true);
    }
  }
}
