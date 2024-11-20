import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'contacts_screen.dart';

// Клас для університету
class University {
  final int id;
  final String name;
  final String address;
  final int studentCount;
  final int webometrics;

  University({
    required this.id,
    required this.name,
    required this.address,
    required this.studentCount,
    required this.webometrics,
  });

  // Метод для перетворення об'єкта у мапу
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'student_count': studentCount,
      'webometrics': webometrics,
    };
  }
}

// Клас для роботи з базою даних університетів
class UniversityDatabase {
  // Метод для отримання доступу до бази даних
  Future<Database> get database async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'universities.db'),
      onCreate: (db, version) async {
        // Створення таблиці в базі даних
        await db.execute('''
          CREATE TABLE universities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            student_count INTEGER,
            webometrics INTEGER
          );
        ''');
      },
      version: 1,
    );
  }

  // Метод для вставки університету в базу даних
  Future<void> insertUniversity(University university) async {
    final db = await database;
    await db.insert(
      'universities',
      university.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Метод для вставки кількох університетів
  Future<void> insertUniversities(List<University> universities) async {
    final db = await database;
    for (var university in universities) {
      await db.insert(
        'universities',
        university.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Метод для отримання університетів, що не знаходяться в Києві та мають webometrics < 5000
  Future<List<Map<String, dynamic>>> getUniversitiesNotInKyiv() async {
    final db = await database;
    return await db.query(
      'universities',
      where: 'address != ? AND webometrics < ?',
      whereArgs: ['Київ', 5000],
    );
  }

  // Метод для отримання максимальних і мінімальних значень Webometrics
  Future<Map<String, dynamic>> getWebometricsMinMax() async {
    final db = await database;
    var resultMax =
        await db.rawQuery('SELECT MAX(webometrics) AS max FROM universities');
    var resultMin =
        await db.rawQuery('SELECT MIN(webometrics) AS min FROM universities');

    return {
      'max': resultMax.first['max'],
      'min': resultMin.first['min'],
    };
  }
}

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Про мене')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ваше фото (замість цього використовуйте свій файл)
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(
                    'assets/images/myphoto.jpeg'), // Використовуйте своє фото
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ім\'я: Наталія Грицишин',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Опис: Група ТТП-41',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Екран зі списком університетів
class UniversityListScreen extends StatefulWidget {
  const UniversityListScreen({super.key});

  @override
  _UniversityListScreenState createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  final UniversityDatabase database = UniversityDatabase();
  List<Map<String, dynamic>> universities = [];
  Map<String, dynamic> webometricsData = {};
  bool showFiltered = true; // Флаг для фільтрації або показу всіх університетів

  // Ініціалізація даних
  @override
  void initState() {
    super.initState();
    loadData(); // Завантажуємо дані після ініціалізації
  }

  loadData() async {
    final db = await database.database; // Отримуємо доступ до бази даних
    if (showFiltered) {
      universities = await db.query(
        'universities',
        where: 'address != ? AND webometrics < ?',
        whereArgs: ['Київ', 5000],
      );
      print('Filtered Universities: $universities');
    } else {
      universities = await db.rawQuery('SELECT * FROM universities');
      print('All Universities: $universities');
      webometricsData = await database.getWebometricsMinMax();
    }
    setState(() {});
  }

  // Метод для додавання університетів в базу
  addUniversities() async {
    List<University> universitiesList = [
      University(
        id: 0,
        name: 'Львівський національний університет імені Івана Франка',
        address: 'Львів',
        studentCount: 20000,
        webometrics: 4000,
      ),
      University(
        id: 1,
        name: 'Харківський національний університет',
        address: 'Харків',
        studentCount: 18000,
        webometrics: 2000,
      ),
      University(
        id: 2,
        name: 'Одеський національний університет',
        address: 'Одеса',
        studentCount: 15000,
        webometrics: 3500,
      ),
      University(
        id: 3,
        name: 'Київський національний університет імені Тараса Шевченка',
        address: 'Київ',
        studentCount: 30000,
        webometrics: 4500,
      ),
      University(
        id: 4,
        name: 'Дніпропетровський національний університет',
        address: 'Дніпро',
        studentCount: 22000,
        webometrics: 6000,
      ),
      University(
        id: 5,
        name: 'Черкаський національний університет',
        address: 'Черкаси',
        studentCount: 12000,
        webometrics: 4000,
      ),
      University(
        id: 6,
        name: 'Запорізький національний університет',
        address: 'Запоріжжя',
        studentCount: 14000,
        webometrics: 4500,
      ),
      University(
        id: 7,
        name: 'Миколаївський національний університет',
        address: 'Миколаїв',
        studentCount: 11000,
        webometrics: 1200,
      ),
      University(
        id: 8,
        name: 'Вінницький національний університет',
        address: 'Вінниця',
        studentCount: 13000,
        webometrics: 4800,
      ),
      University(
        id: 9,
        name: 'Івано-Франківський національний університет',
        address: 'Івано-Франківськ',
        studentCount: 10000,
        webometrics: 2300,
      ),
      University(
        id: 10,
        name: 'Київський політехнічний інститут',
        address: 'Київ',
        studentCount: 10000,
        webometrics: 3600,
      ),
    ];

    // Додаємо університети до бази даних
    await database.insertUniversities(universitiesList);
    loadData(); // Перезавантажуємо дані після додавання
  }

  // Перемикання між фільтрацією та переглядом всіх університетів
  toggleFilter() {
    setState(() {
      showFiltered = !showFiltered;
      loadData(); // Перезавантажуємо дані
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Університети України')),
      body: Column(
        children: [
          // Виведення максимального і мінімального Webometrics
          Text('Max Webometrics: ${webometricsData['max']}'),
          Text('Min Webometrics: ${webometricsData['min']}'),

          // Кнопка з відступом
          ElevatedButton(
            onPressed: toggleFilter,
            child: Text(showFiltered
                ? 'Показати всі університети'
                : 'Показати тільки не з Києва та Webometrics < 5000'),
          ),

          // Додаємо SizedBox для відстані між кнопками
          const SizedBox(
              height: 16), // Встановлюємо висоту відступу між кнопками

          // Інша кнопка з відступом
          ElevatedButton(
            onPressed: addUniversities, // Додати університети
            child: const Text('Додати університети'),
          ),

          // Відстань між кнопками та списком
          const SizedBox(height: 16),

          Expanded(
            // Список університетів
            child: ListView.builder(
              itemCount: universities.length,
              itemBuilder: (context, index) {
                final university = universities[index];
                return ListTile(
                  title: Text(university['name'] ?? 'No name'),
                  subtitle: Text(
                      '${university['address'] ?? 'No address'} - Webometrics: ${university['webometrics']}'),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                  context, '/contacts'); // Go to contacts screen
            },
            child: const Text('Go to Contacts'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutMeScreen()),
              );
            },
            child: const Text('Про себе'),
          ),
        ],
      ),
    );
  }
}

// Головний клас програми
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const UniversityListScreen(), // Початковий екран університетів
      routes: {
        '/contacts': (context) => const ContactListScreen(),
        '/universities': (context) => const UniversityListScreen(),
      },
    );
  }
}

class ContactService {
  static const platform = MethodChannel('com.example.contacts');

  Future<void> requestContactsPermission() async {
    try {
      final bool result =
          await platform.invokeMethod('requestContactsPermission');
      print('Permissions granted: $result');
    } on PlatformException catch (e) {
      print('Failed to get contacts permission: ${e.message}');
    }
  }
}

void main() {
  runApp(const MyApp());
}
