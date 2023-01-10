class APIManager {
  static final APIManager _shared = APIManager._internal();

  APIManager._internal();
  factory APIManager() {
    return _shared;
  }

  Future fetchData(int currentPage) async {
    await new Future.delayed(new Duration(seconds: 2));
    List<String> _list = [];
    int startIndex = currentPage * 10;
    for (int i = startIndex; i < startIndex + 10; i++) {
      _list.add("Item #$i");
    }
    return _list;
  }
}
