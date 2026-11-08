class JsonParser {
  List<T> parseList<T>(
      Map<String, dynamic> json,
      String key,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final data = json[key];

    if (data is! List) {
      throw FormatException(
        'Поле "$key" не містить списку',
      );
    }

    return data.map((item) {
      if (item is! Map) {
        throw FormatException(
          'Елемент у "$key" не є JSON-об’єктом',
        );
      }

      return fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
  
}