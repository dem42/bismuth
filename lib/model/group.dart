class Group {
  final String name;
  final int order;

  Group({this.name, this.order});

  Group.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        order = json['order'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'order': order,
      };
}