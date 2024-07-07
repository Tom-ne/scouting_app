class Preference<T> {
  final String key;
  final T defaultValue;
  const Preference({required this.key, required this.defaultValue});

  Type get targetType => T;
}

class PreferencesList extends Iterable<Preference>{
  final List<Preference> preferences;

  const PreferencesList({required this.preferences});
  
  Iterable<String> get keys => preferences.map((e) => e.key);
  get defaultValues => preferences.map((e) => e.defaultValue);

  Preference operator[](String key) => preferences.firstWhere((element) => element.key == key);
  
  @override
  Iterator<Preference> get iterator => preferences.iterator;
}