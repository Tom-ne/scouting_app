abstract class ConstDictionary {
  Map<String, dynamic> get keysDefaultValues {
    throw UnimplementedError();
  }

  late final Map<String, dynamic> _data = Map.fromEntries(keysDefaultValues.entries);

  ConstDictionary() {
    for (String key in keysDefaultValues.keys) {
      _data[key] = keysDefaultValues[key];
    }
  }

  ConstDictionary.fromJson(Map<String, dynamic> json) {
    for (String key in keysDefaultValues.keys) {
      _data[key] = json[key] ?? keysDefaultValues[key];
    }
  }

  Map<String, dynamic> toJson() {
    return _data;
  }

  bool containsKey(Object? key) {
    return _data.containsKey(key);
  }

  dynamic operator[](Object? key) {
    return _data[key];
  }

  void operator[]=(String key, dynamic value) {
    _data[key] = value;
  }

  @override
  bool operator ==(Object other) {
    if (other is! ConstDictionary) return false;
    if (other.runtimeType != runtimeType) return false;
    Map<String, dynamic> thisMap = toJson();
    Map<String, dynamic> otherMap = other.toJson();

    if (thisMap.length != otherMap.length) return false;
    for (String key in thisMap.keys) {
      if (thisMap[key] != otherMap[key]) return false;
    }

    return true;
  }
  
  @override
  int get hashCode => Object.hash(_data, keysDefaultValues);
}