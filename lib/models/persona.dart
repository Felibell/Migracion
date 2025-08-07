class Person {
  final int? id;
  final String? name;
  final int age;
  final String? nationality;
  final String datetime;
  final String description;
  final String? photoPath;
  final String? audioPath;
  final String? gps;

  Person({
    this.id,
    this.name,
    required this.age,
    this.nationality,
    required this.datetime,
    required this.description,
    this.photoPath,
    this.audioPath,
    this.gps,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'age': age,
    'nationality': nationality,
    'datetime': datetime,
    'description': description,
    'photoPath': photoPath,
    'audioPath': audioPath,
    'gps': gps,
  };

  factory Person.fromMap(Map<String, dynamic> map) => Person(
    id: map['id'],
    name: map['name'],
    age: map['age'],
    nationality: map['nationality'],
    datetime: map['datetime'],
    description: map['description'],
    photoPath: map['photoPath'],
    audioPath: map['audioPath'],
    gps: map['gps'],
  );
}
