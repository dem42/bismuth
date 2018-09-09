class Group {
  String name;
  int order;

  static Group DEFAULT_GROUP = new Group(name: "default", order: 1);

  Group({this.name, this.order});

  Group.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        order = json['order'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'order': order,
      };

  bool isValid() => name != null && name.isNotEmpty;
}