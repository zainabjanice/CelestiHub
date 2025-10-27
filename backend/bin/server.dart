// File: backend/bin/server.dart
import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// DATABASE CONFIGURATION
final settings = ConnectionSettings(
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'Hello@zjanice1',
  db: 'astronomy_db',
);

// Connection Pool
late MySqlConnection _pool;

// Initialize database connection pool
Future<void> initDatabase() async {
  try {
    _pool = await MySqlConnection.connect(settings);
    print('✅ Connected to MySQL database (Connection Pool)');

    // Create table
    await _pool.query('''
      CREATE TABLE IF NOT EXISTS celestial_objects (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        type VARCHAR(50) NOT NULL,
        distance_ly DOUBLE,
        magnitude DOUBLE,
        constellation VARCHAR(50),
        description TEXT,
        discovered_year INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Table created/verified');

    // Check if table is empty
    var result =
        await _pool.query('SELECT COUNT(*) AS count FROM celestial_objects');
    int count = result.isNotEmpty ? (result.first['count'] as int) : 0;

    if (count == 0) {
      print('⚙️ Inserting initial sample data...');
      final samples = [
        {
          'name': 'Andromeda Galaxy',
          'type': 'Galaxy',
          'distance_ly': 2537000.0,
          'magnitude': 3.44,
          'constellation': 'Andromeda',
          'description': 'The nearest major galaxy to the Milky Way',
          'discovered_year': 964
        },
        {
          'name': 'Orion Nebula',
          'type': 'Nebula',
          'distance_ly': 1344.0,
          'magnitude': 4.0,
          'constellation': 'Orion',
          'description': 'A diffuse nebula in the Milky Way',
          'discovered_year': 1610
        },
        {
          'name': 'Sirius',
          'type': 'Star',
          'distance_ly': 8.6,
          'magnitude': -1.46,
          'constellation': 'Canis Major',
          'description': 'The brightest star in the night sky',
          'discovered_year': -1000
        },
      ];

      for (var obj in samples) {
        try {
          await _pool.query('''
            INSERT INTO celestial_objects
            (name, type, distance_ly, magnitude, constellation, description, discovered_year)
            VALUES (?, ?, ?, ?, ?, ?, ?)
          ''', [
            obj['name'],
            obj['type'],
            obj['distance_ly'],
            obj['magnitude'],
            obj['constellation'],
            obj['description'],
            obj['discovered_year'],
          ]);
        } catch (e) {
          print('⚠️ Failed to insert ${obj['name']}: $e');
        }
      }
      print('✅ Sample data inserted');
    } else {
      print('✅ Database already contains $count objects');
    }

    print('✅ Database initialized successfully\n');
  } catch (e) {
    print('❌ Database error: $e');
    rethrow;
  }
}

// API CLASS
class AstronomyAPI {
  // CORS headers
  Map<String, String> get corsHeaders => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json',
      };

  // GET all objects
  Future<Response> getAllObjects(Request req) async {
    try {
      var results = await _pool
          .query('SELECT * FROM celestial_objects ORDER BY created_at DESC');

      var objects = results
          .map((row) => {
                'id': row['id'],
                'name': row['name'],
                'type': row['type'],
                'distance_ly': (row['distance_ly'] as num?)?.toDouble(),
                'magnitude': (row['magnitude'] as num?)?.toDouble(),
                'constellation': row['constellation'],
                'description': row['description']?.toString() ?? '',
                'discovered_year': row['discovered_year'],
              })
          .toList();

      return Response.ok(jsonEncode(objects), headers: corsHeaders);
    } catch (e) {
      print('❌ Error in getAllObjects: $e');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Database error: $e'}),
          headers: corsHeaders);
    }
  }

  // GET single object
  Future<Response> getObject(Request req, String id) async {
    try {
      var results = await _pool.query(
        'SELECT * FROM celestial_objects WHERE id = ?',
        [int.parse(id)],
      );

      if (results.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Object not found'}),
          headers: corsHeaders,
        );
      }

      var row = results.first;
      var object = {
        'id': row['id'],
        'name': row['name'],
        'type': row['type'],
        'distance_ly': (row['distance_ly'] as num?)?.toDouble(),
        'magnitude': (row['magnitude'] as num?)?.toDouble(),
        'constellation': row['constellation'],
        'description': row['description'],
        'discovered_year': row['discovered_year'],
      };

      return Response.ok(jsonEncode(object), headers: corsHeaders);
    } catch (e) {
      print('❌ Error in getObject: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Database error: $e'}),
        headers: corsHeaders,
      );
    }
  }

  // POST new object
  Future<Response> createObject(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      print('🔹 Creating object: ${data['name']}');

      if (data['name'] == null || data['type'] == null) {
        return Response(400,
            body: jsonEncode({'error': 'Name and type are required fields.'}),
            headers: corsHeaders);
      }

      final distanceLy = data['distance_ly'] != null
          ? (data['distance_ly'] is num
              ? (data['distance_ly'] as num).toDouble()
              : double.tryParse(data['distance_ly'].toString()))
          : null;

      final magnitude = data['magnitude'] != null
          ? (data['magnitude'] is num
              ? (data['magnitude'] as num).toDouble()
              : double.tryParse(data['magnitude'].toString()))
          : null;

      final constellation = data['constellation']?.toString();

      String description = data['description']?.toString() ?? '';
      if (description.length > 1000000) {
        description = description.substring(0, 1000000);
        print('⚠️ Description truncated to 1,000,000 characters');
      }

      final discoveredYear = data['discovered_year'] != null
          ? int.tryParse(data['discovered_year'].toString())
          : null;

      try {
        await _pool.query('''
        INSERT INTO celestial_objects
        (name, type, distance_ly, magnitude, constellation, description, discovered_year)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
          data['name'],
          data['type'],
          distanceLy,
          magnitude,
          constellation,
          description,
          discoveredYear
        ]);

        print('✅ Object created: ${data['name']}');
        return Response.ok(
            jsonEncode({'message': 'Object created successfully!'}),
            headers: corsHeaders);
      } on MySqlException catch (e) {
        if (e.errorNumber == 1062) {
          return Response(409,
              body: jsonEncode(
                  {'error': 'Object with this name already exists.'}),
              headers: corsHeaders);
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      print('❌ Error in createObject: $e');
      print(stackTrace);
      return Response.internalServerError(
          body: jsonEncode(
              {'error': 'Failed to save object.', 'details': e.toString()}),
          headers: corsHeaders);
    }
  }

  // PUT update object
  Future<Response> updateObject(Request request, String id) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      print('🔹 Updating object $id: ${data['name']}');

      if (data['name'] == null || data['type'] == null) {
        return Response(400,
            body: jsonEncode({'error': 'Name and type are required fields.'}),
            headers: corsHeaders);
      }

      final distanceLy = data['distance_ly'] != null
          ? (data['distance_ly'] is num
              ? (data['distance_ly'] as num).toDouble()
              : double.tryParse(data['distance_ly'].toString()))
          : null;

      final magnitude = data['magnitude'] != null
          ? (data['magnitude'] is num
              ? (data['magnitude'] as num).toDouble()
              : double.tryParse(data['magnitude'].toString()))
          : null;

      final constellation = data['constellation']?.toString();

      String description = data['description']?.toString() ?? '';
      if (description.length > 1000000) {
        description = description.substring(0, 1000000);
      }

      final discoveredYear = data['discovered_year'] != null
          ? int.tryParse(data['discovered_year'].toString())
          : null;

      try {
        var results = await _pool.query(
          'SELECT id FROM celestial_objects WHERE id = ?',
          [int.parse(id)],
        );

        if (results.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Object not found'}),
            headers: corsHeaders,
          );
        }

        await _pool.query('''
        UPDATE celestial_objects
        SET name = ?, type = ?, distance_ly = ?, magnitude = ?, 
            constellation = ?, description = ?, discovered_year = ?
        WHERE id = ?
      ''', [
          data['name'],
          data['type'],
          distanceLy,
          magnitude,
          constellation,
          description,
          discoveredYear,
          int.parse(id)
        ]);

        print('✅ Object updated: ${data['name']}');
        return Response.ok(
            jsonEncode({'message': 'Object updated successfully!'}),
            headers: corsHeaders);
      } on MySqlException catch (e) {
        if (e.errorNumber == 1062) {
          return Response(409,
              body: jsonEncode(
                  {'error': 'Object with this name already exists.'}),
              headers: corsHeaders);
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      print('❌ Error in updateObject: $e');
      print(stackTrace);
      return Response.internalServerError(
          body: jsonEncode(
              {'error': 'Failed to update object.', 'details': e.toString()}),
          headers: corsHeaders);
    }
  }

  // DELETE object
  Future<Response> deleteObject(Request request, String id) async {
    try {
      print('🔹 Deleting object $id');

      var results = await _pool.query(
        'SELECT id FROM celestial_objects WHERE id = ?',
        [int.parse(id)],
      );

      if (results.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Object not found'}),
          headers: corsHeaders,
        );
      }

      await _pool.query(
        'DELETE FROM celestial_objects WHERE id = ?',
        [int.parse(id)],
      );

      print('✅ Object deleted: $id');
      return Response.ok(
          jsonEncode({'message': 'Object deleted successfully!'}),
          headers: corsHeaders);
    } catch (e, stackTrace) {
      print('❌ Error in deleteObject: $e');
      print(stackTrace);
      return Response.internalServerError(
          body: jsonEncode(
              {'error': 'Failed to delete object.', 'details': e.toString()}),
          headers: corsHeaders);
    }
  }

  // CORS handler
  Response corsHandler(Request req) => Response.ok('', headers: corsHeaders);
}

// MAIN SERVER
void main() async {
  print('\n🚀 Starting Astronomy Database Server...\n');

  try {
    await initDatabase();

    final api = AstronomyAPI();
    final router = Router()
      ..get('/api/objects', api.getAllObjects)
      ..get('/api/objects/<id>', api.getObject)
      ..post('/api/objects', api.createObject)
      ..put('/api/objects/<id>', api.updateObject)
      ..delete('/api/objects/<id>', api.deleteObject)
      ..options('/api/objects', api.corsHandler)
      ..options('/api/objects/<id>', api.corsHandler);

    final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

    final server = await shelf_io.serve(handler, 'localhost', 8081);
    print('🌌 Server running at http://localhost:${server.port}');
  } catch (e) {
    print('❌ Failed to start server: $e');
  }
}
