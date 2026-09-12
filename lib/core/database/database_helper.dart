import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'db_factory.dart';

class DatabaseHelper {
  static const String dbName = 'workshop_database_v2.db';
  static const int dbVersion = 1;

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    await initDatabaseFactory();

    String path;
    try {
      if (kIsWeb) {
        path = dbName;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        path = join(dir.path, dbName);
      }
    } catch (_) {
      path = dbName;
    }

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT DEFAULT 'user',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        tagline TEXT,
        description TEXT,
        address TEXT,
        phone TEXT,
        email TEXT,
        image_url TEXT,
        cuisine TEXT,
        rating REAL DEFAULT 4.9,
        price_level INTEGER DEFAULT 2,
        open_time TEXT DEFAULT '11:00',
        close_time TEXT DEFAULT '22:30',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE hotels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        address TEXT,
        phone TEXT,
        image_url TEXT,
        star_rating INTEGER DEFAULT 5,
        price_per_night REAL DEFAULT 4500,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE restaurant_tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurant_id INTEGER NOT NULL,
        table_number TEXT NOT NULL,
        name TEXT NOT NULL,
        zone_id TEXT NOT NULL,
        seat_count INTEGER NOT NULL DEFAULT 4,
        shape TEXT NOT NULL DEFAULT 'rect',
        status TEXT DEFAULT 'available',
        x REAL DEFAULT 0,
        y REAL DEFAULT 0,
        width REAL DEFAULT 18,
        height REAL DEFAULT 14,
        features TEXT,
        photo_url TEXT,
        min_spend REAL,
        description TEXT,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        restaurant_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        name_en TEXT,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        calories INTEGER DEFAULT 0,
        description TEXT,
        digestive_benefit TEXT,
        image TEXT,
        tags TEXT,
        is_recommended INTEGER DEFAULT 0,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_code TEXT UNIQUE,
        user_id INTEGER NOT NULL,
        restaurant_id INTEGER NOT NULL,
        table_id INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        booking_time TEXT NOT NULL,
        period TEXT DEFAULT 'lunch',
        guest_count INTEGER NOT NULL DEFAULT 1,
        status TEXT DEFAULT 'confirmed',
        customer_name TEXT,
        customer_phone TEXT,
        customer_email TEXT,
        occasion TEXT DEFAULT 'general',
        dietary_restrictions TEXT,
        special_request TEXT,
        total_amount REAL DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
        FOREIGN KEY (table_id) REFERENCES restaurant_tables(id) ON DELETE CASCADE,
        UNIQUE(table_id, booking_date, booking_time)
      )
    ''');

    await db.execute('''
      CREATE TABLE booking_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL,
        menu_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        price REAL NOT NULL,
        note TEXT,
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT,
        status TEXT DEFAULT 'pending',
        paid_at TEXT,
        FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        restaurant_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    const pw = '123456';
    final batch = db.batch();

    // 1. Users
    batch.rawInsert('''
      INSERT INTO users (email, password, name, phone, role) VALUES
      ('user@demo.com', '$pw', 'คุณสุทัศน์ พิทักษ์ธรรม', '0812345678', 'user'),
      ('admin@demo.com', '$pw', 'ผู้ดูแลระบบ กินดีถ่ายข้อง', '0800000000', 'admin')
    ''');

    // 2. Primary Restaurant: กินดีถ่ายข้อง (Kin Dee Thai Khong)
    batch.rawInsert('''
      INSERT INTO restaurants (id, name, tagline, description, address, phone, email, image_url, cuisine, rating, price_level, open_time, close_time) VALUES
      (1, 'กินดีถ่ายข้อง (Kin Dee Thai Khong)',
       'ร้านอาหารและห้องรับประทานอาหาร โรงแรมเวลเนสรีสอร์ต',
       'อาหารไทยร่วมสมัยเพื่อสุขภาพ รสเลิศ ย่อยง่าย สบายท้อง ดีต่อระบบขับถ่าย คัดสรรวัตถุดิบไฟเบอร์สูงและจุลินทรีย์มีชีวิต ปรับสมดุลระบบย่อย ในบรรยากาศรีสอร์ตริมน้ำ',
       '88/9 หมู่ 4 ถนนสุขุมวิท ริมแม่น้ำบางปะกง ต.บางปะกง ฉะเชิงเทรา 24130',
       '02-899-7788',
       'booking@kindeethaikhong.com',
       'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&auto=format&fit=crop&q=80',
       'Thai Wellness & Herbal',
       4.9,
       3,
       '11:00',
       '22:30')
    ''');

    // 3. Hotel info
    batch.rawInsert('''
      INSERT INTO hotels (id, name, description, address, phone, image_url, star_rating, price_per_night) VALUES
      (1, 'กินดีถ่ายข้อง เวลเนส รีสอร์ต & สปา',
       'รีสอร์ตระดับ 5 ดาวเพื่อการฟื้นฟูสุขภาพแบบองค์รวม ริมแม่น้ำบางปะกง พร้อมโปรแกรมดีท็อกซ์และห้องอาหารเฉพาะทาง',
       '88/9 หมู่ 4 ถนนสุขุมวิท ริมแม่น้ำบางปะกง ฉะเชิงเทรา',
       '02-899-7788',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&auto=format&fit=crop&q=80',
       5,
       4800)
    ''');

    // 4. Tables in 4 Zones (matching INITIAL_TABLES from demo)
    final tables = [
      // Glasshouse Pavilion
      {
        'table_number': 'GH-01',
        'name': 'โต๊ะ GH-01 (ริมสระบัว)',
        'zone_id': 'glasshouse',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 18.0,
        'y': 28.0,
        'width': 14.0,
        'height': 14.0,
        'features': 'วิวสระบัวเต็มตา,แสงธรรมชาติสวย,มุมถ่ายรูปยอดนิยม',
        'photo_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะกลมสำหรับ 2 ท่าน ติดกระจกบานใหญ่ ชมปลาคราฟแหวกว่ายในสระบัว',
      },
      {
        'table_number': 'GH-02',
        'name': 'โต๊ะ GH-02 (ริมกระจก)',
        'zone_id': 'glasshouse',
        'seat_count': 4,
        'shape': 'rect',
        'status': 'available',
        'x': 42.0,
        'y': 26.0,
        'width': 18.0,
        'height': 14.0,
        'features': 'วิวสวนเฟิร์น,เก้าอี้หวายเบาะนุ่ม,มีปลั๊กไฟบริการ',
        'photo_url': 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะสี่เหลี่ยม 4 ที่นั่ง บรรยากาศโปร่งสบาย เหมาะสำหรับเพื่อนฝูงหรือมื้อครอบครัวเล็ก',
      },
      {
        'table_number': 'GH-03',
        'name': 'โต๊ะ GH-03 (บูธโซฟาเขียว)',
        'zone_id': 'glasshouse',
        'seat_count': 4,
        'shape': 'booth',
        'status': 'reserved',
        'x': 74.0,
        'y': 28.0,
        'width': 20.0,
        'height': 16.0,
        'features': 'โซฟาเบาะนุ่มหนานั่งสบาย,เป็นสัดส่วน,ใกล้เคาน์เตอร์เครื่องดื่ม',
        'photo_url': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'ที่นั่งแบบโซฟาสไตล์คาเฟ่โมเดิร์น โอบล้อมด้วยไม้ประดับฟอกอากาศ',
      },
      {
        'table_number': 'GH-04',
        'name': 'โต๊ะ GH-04 (เซ็นเตอร์พาวิลเลียน)',
        'zone_id': 'glasshouse',
        'seat_count': 6,
        'shape': 'rect',
        'status': 'available',
        'x': 24.0,
        'y': 65.0,
        'width': 22.0,
        'height': 16.0,
        'features': 'โต๊ะใหญ่รับรอง 6 ท่าน,วิวสวน 360 องศา,รองรับวีลแชร์',
        'photo_url': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะไม้โอ๊คตัวใหญ่ โดดเด่นกลางกลาสเฮ้าส์ เหมาะสำหรับมื้อรวมญาติหรือครอบครัว',
      },
      {
        'table_number': 'GH-05',
        'name': 'โต๊ะ GH-05 (มุมสวนสมุนไพร)',
        'zone_id': 'glasshouse',
        'seat_count': 4,
        'shape': 'rect',
        'status': 'available',
        'x': 56.0,
        'y': 65.0,
        'width': 18.0,
        'height': 14.0,
        'features': 'กลิ่นอายสมุนไพรออร์แกนิก,เงียบสงบ,แสงละมุนช่วงบ่าย',
        'photo_url': 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะนั่งสบายติดมุมแปลงสมุนไพรสด เช่น สะระแหน่ โหระพา เลมอนบาล์ม',
      },
      {
        'table_number': 'GH-06',
        'name': 'โต๊ะ GH-06 (มุมสงบส่วนตัว)',
        'zone_id': 'glasshouse',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 82.0,
        'y': 65.0,
        'width': 14.0,
        'height': 14.0,
        'features': 'มุมสงบโรแมนติก,วิวต้นไม้ใหญ่,ความสว่างกำลังดี',
        'photo_url': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะคู่มุมสงบ ไร้คนเดินผ่าน เหมาะสำหรับการสนทนาลึกซึ้งและมื้อพิเศษ',
      },

      // Garden Waterside
      {
        'table_number': 'GD-01',
        'name': 'โต๊ะ GD-01 (ชานไม้ริมน้ำ)',
        'zone_id': 'garden',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 20.0,
        'y': 30.0,
        'width': 14.0,
        'height': 14.0,
        'features': 'ยื่นเหนือน้ำ 1 เมตร,ลมเย็นตลอดทั้งวัน,ให้อาหารปลาได้',
        'photo_url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะคู่ชานไม้ระแนงริมสายธารจำลอง ลมพัดเย็นสบายสดชื่นตลอดบ่าย',
      },
      {
        'table_number': 'GD-02',
        'name': 'โต๊ะ GD-02 (ใต้ต้นจามจุรี)',
        'zone_id': 'garden',
        'seat_count': 4,
        'shape': 'rect',
        'status': 'available',
        'x': 48.0,
        'y': 28.0,
        'width': 18.0,
        'height': 14.0,
        'features': 'ร่มเงาต้นไม้ใหญ่ 50 ปี,พื้นสนามหญ้าเขียวชอุ่ม,บรรยากาศปิกนิกหรู',
        'photo_url': 'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะไม้ธรรมชาติใต้ร่มเงาไม้ใหญ่ อากาศสดชื่นและมีออกซิเจนบริสุทธิ์เต็มปอด',
      },
      {
        'table_number': 'GD-03',
        'name': 'โต๊ะ GD-03 (ศาลาไม้น้อยริมบ่อ)',
        'zone_id': 'garden',
        'seat_count': 6,
        'shape': 'booth',
        'status': 'reserved',
        'x': 78.0,
        'y': 32.0,
        'width': 20.0,
        'height': 16.0,
        'features': 'หลังคากันแดดกันฝน,เบาะนั่งสไตล์ไทยโมเดิร์น,บรรยากาศเป็นส่วนตัว',
        'photo_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'ศาลาโปร่งทรงไทยร่วมสมัย นั่งสบายได้ตั้งแต่บ่ายจรดค่ำ มีพัดลมไอเย็นส่วนตัว',
      },
      {
        'table_number': 'GD-04',
        'name': 'โต๊ะ GD-04 (ลานหินน้ำตก)',
        'zone_id': 'garden',
        'seat_count': 4,
        'shape': 'rect',
        'status': 'available',
        'x': 26.0,
        'y': 68.0,
        'width': 18.0,
        'height': 14.0,
        'features': 'เสียงน้ำตกผ่อนคลาย,พัดลมไอหมอก,มุมโคมไฟอบอุ่น',
        'photo_url': 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'ใกล้แนวน้ำตกหินธรรมชาติ ได้ยินเสียงน้ำไหลเบาๆ ช่วยให้เจริญอาหารและจิตใจสงบ',
      },
      {
        'table_number': 'GD-05',
        'name': 'โต๊ะ GD-05 (การ์เด้นแฟมิลี่)',
        'zone_id': 'garden',
        'seat_count': 8,
        'shape': 'rect',
        'status': 'available',
        'x': 62.0,
        'y': 68.0,
        'width': 24.0,
        'height': 16.0,
        'features': 'โต๊ะยาว 8 ท่าน,พื้นที่กว้างขวางสำหรับเด็กวิ่งเล่น,ใกล้ห้องสุขา',
        'photo_url': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะยาวไม้จริงกลางลานสวนหิน เหมาะสำหรับรวมตัวครอบครัวใหญ่หรือเพื่อนเก่า',
      },
      {
        'table_number': 'GD-06',
        'name': 'โต๊ะ GD-06 (ริมแปลงดอกไม้)',
        'zone_id': 'garden',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 88.0,
        'y': 70.0,
        'width': 12.0,
        'height': 12.0,
        'features': 'แปลงกุหลาบมอญและมะลิหอม,มุมสงบโรแมนติก,แสงเทียนยามค่ำ',
        'photo_url': 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะกลมเล็กน่ารัก โอบล้อมด้วยดอกไม้ไทยส่งกลิ่นหอมผ่อนคลายยามพลบค่ำ',
      },

      // VIP Chamber
      {
        'table_number': 'VIP-01',
        'name': 'ห้อง VIP 1 "กาสะลอง" (Grand Suite)',
        'zone_id': 'vip',
        'seat_count': 10,
        'shape': 'rect',
        'status': 'available',
        'x': 28.0,
        'y': 35.0,
        'width': 32.0,
        'height': 22.0,
        'features': 'สมาร์ททีวี 75 นิ้ว,ห้องน้ำส่วนตัว,คาราโอเกะ Hi-End,บัตเลอร์ประจำห้อง',
        'photo_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80',
        'min_spend': 5000.0,
        'description': 'ห้องจัดเลี้ยงส่วนตัวระดับเพรสซิเดนท์ ตกแต่งด้วยงานไม้สักทองและหินอ่อน สำหรับแขกพิเศษ',
      },
      {
        'table_number': 'VIP-02',
        'name': 'ห้อง VIP 2 "จำปา" (Executive Room)',
        'zone_id': 'vip',
        'seat_count': 6,
        'shape': 'round',
        'status': 'available',
        'x': 70.0,
        'y': 32.0,
        'width': 26.0,
        'height': 20.0,
        'features': 'โต๊ะกลมหมุนไฟฟ้า,วิวสวนผ่านมู่ลี่ไม้,แอร์ปรับระดับไมโคร',
        'photo_url': 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80',
        'min_spend': 3500.0,
        'description': 'ห้องส่วนตัวขนาดกลาง 6 ท่าน โต๊ะกลมพร้อมจานหมุน สะดวกสำหรับมื้ออาหารแบ่งปัน',
      },
      {
        'table_number': 'VIP-03',
        'name': 'ห้อง VIP 3 "พุดตาล" (Family Suite)',
        'zone_id': 'vip',
        'seat_count': 8,
        'shape': 'rect',
        'status': 'reserved',
        'x': 48.0,
        'y': 70.0,
        'width': 28.0,
        'height': 20.0,
        'features': 'โซนโซฟาพักผ่อนแยกส่วน,เก้าอี้เด็กเพื่อสุขภาพ,แสงไฟปรับ Mood ได้',
        'photo_url': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
        'min_spend': 4000.0,
        'description': 'ห้องส่วนตัวอบอุ่นสไตล์บ้านพักตากอากาศ มีมุมโซฟาสำหรับผู้สูงอายุหรือเด็กน้อยพักผ่อน',
      },

      // Rooftop Sunset Deck
      {
        'table_number': 'RT-01',
        'name': 'โต๊ะ RT-01 (ฟรอนต์โรว์วิวเขา)',
        'zone_id': 'rooftop',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 18.0,
        'y': 30.0,
        'width': 14.0,
        'height': 14.0,
        'features': 'วิวขอบฟ้าแบบไร้สิ่งบดบัง,พระอาทิตย์ตกหน้าโต๊ะตรงๆ,แชมเปญบาร์ใกล้เคียง',
        'photo_url': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะคู่แถวหน้าสุดริมระเบียงกระจกใส ปราศจากสิ่งบดบังสายตา เหมาะกับการขอแต่งงานหรือเดตพิเศษ',
      },
      {
        'table_number': 'RT-02',
        'name': 'โต๊ะ RT-02 (เดคเลานจ์)',
        'zone_id': 'rooftop',
        'seat_count': 4,
        'shape': 'booth',
        'status': 'available',
        'x': 46.0,
        'y': 28.0,
        'width': 20.0,
        'height': 16.0,
        'features': 'เดย์เบดเบาะหนานุ่ม,โต๊ะเตี้ยสไตล์เลานจ์,รับลมเย็นสบาย',
        'photo_url': 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'ที่นั่งทรงกลมพร้อมหมอนอิงขนาดใหญ่ นอนเอนชมดวงดาวและจิบม็อกเทลเพื่อสุขภาพ',
      },
      {
        'table_number': 'RT-03',
        'name': 'โต๊ะ RT-03 (ซันเซ็ตวิสต้า)',
        'zone_id': 'rooftop',
        'seat_count': 4,
        'shape': 'rect',
        'status': 'reserved',
        'x': 78.0,
        'y': 30.0,
        'width': 18.0,
        'height': 14.0,
        'features': 'มุมถ่ายภาพยอดฮิต,ร่มผ้าใบกันน้ำค้าง,แสงไฟแอลอีดีอุ่นตา',
        'photo_url': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะไม้สังเคราะห์โมเดิร์น แสงไฟซ่อนใต้โต๊ะสร้างบรรยากาศหรูหรา',
      },
      {
        'table_number': 'RT-04',
        'name': 'โต๊ะ RT-04 (รูฟท็อปปาร์ตี้)',
        'zone_id': 'rooftop',
        'seat_count': 6,
        'shape': 'rect',
        'status': 'available',
        'x': 32.0,
        'y': 68.0,
        'width': 22.0,
        'height': 16.0,
        'features': 'รองรับกลุ่ม 6 ท่าน,ใกล้โซนบาร์เครื่องดื่มผลไม้สด,มีพัดลมระบายอากาศ',
        'photo_url': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'โต๊ะใหญ่สำหรับสังสรรค์แก๊งเพื่อน บรรยากาศสนุกสนาน มีชีวิตชีวาพร้อมดีเจเพลงเบาๆ',
      },
      {
        'table_number': 'RT-05',
        'name': 'โต๊ะ RT-05 (มุมเงียบชมดาว)',
        'zone_id': 'rooftop',
        'seat_count': 2,
        'shape': 'round',
        'status': 'available',
        'x': 75.0,
        'y': 68.0,
        'width': 14.0,
        'height': 14.0,
        'features': 'ห่างจากโซนเสียงเพลง,มองเห็นหมู่ดาวชัดเจน,ความโรแมนติกระดับสูงสุด',
        'photo_url': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&auto=format&fit=crop&q=80',
        'min_spend': null,
        'description': 'มุมสงบด้านทิศตะวันออก ลมโกรกสบาย มองเห็นแสงไฟเมืองและดวงดาวระยิบระยับ',
      },
    ];

    for (var t in tables) {
      batch.rawInsert('''
        INSERT INTO restaurant_tables (restaurant_id, table_number, name, zone_id, seat_count, shape, status, x, y, width, height, features, photo_url, min_spend, description)
        VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        t['table_number'],
        t['name'],
        t['zone_id'],
        t['seat_count'],
        t['shape'],
        t['status'],
        t['x'],
        t['y'],
        t['width'],
        t['height'],
        t['features'],
        t['photo_url'],
        t['min_spend'],
        t['description'],
      ]);
    }

    // 5. Healthy Wellness Menu (8 items)
    final menuItems = [
      {
        'id': 'M-01',
        'name': 'แกงเลียงผักหวานกุ้งสดปลาย่างรมควัน',
        'name_en': 'Herbal Liang Soup with Fresh Prawns & Smoked Fish',
        'category': 'soup',
        'price': 320.0,
        'calories': 145,
        'digestive_benefit': 'ใยอาหารสูง 8.5g • พริกไทยสดและกระชายช่วยขับลม อุ่นท้อง เบาสบาย',
        'description': 'สูตรชาววังดั้งเดิม ปรุงด้วยผักหวานป่า บวบเหลี่ยม ฟักทอง ตำลึง และใบแมงลักสด ปราศจากผงชูรส',
        'image': 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&auto=format&fit=crop&q=80',
        'tags': 'ไฟเบอร์สูง,ขับลมในกระเพาะ,อุ่นสบายท้อง,ไร้ผงชูรส',
        'is_recommended': 1,
      },
      {
        'id': 'M-02',
        'name': 'น้ำพริกมะขามป้อมออร์แกนิก & สำรับผักอินทรีย์ 12 ชนิด',
        'name_en': 'Organic Indian Gooseberry Relish with 12 Steamed Garden Veggies',
        'category': 'main',
        'price': 280.0,
        'calories': 180,
        'digestive_benefit': 'วิตามินซีสูงลิ่ว • พรีไบโอติกส์จากผักกูด ดอกแค และขมิ้นขาว ช่วยลำไส้ขับถ่ายลื่นไหล',
        'description': 'มะขามป้อมสดตำคู่เนื้อปลาช่อนย่าง เสิร์ฟเคียงผักพื้นบ้านนึ่งสุกหวานกรอบ ปรับสมดุลระบบขับถ่าย',
        'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
        'tags': 'พรีไบโอติกส์สูง,ช่วยขับถ่ายสะดวก,แคลอรีต่ำ,Signature',
        'is_recommended': 1,
      },
      {
        'id': 'M-03',
        'name': 'ยำส้มโอทับทิมสยามกุ้งลายเสือสะดุ้งไฟ',
        'name_en': 'Siamese Ruby Pomelo Salad with Seared Tiger Prawns',
        'category': 'appetizer',
        'price': 350.0,
        'calories': 175,
        'digestive_benefit': 'เอนไซม์ธรรมชาติจากส้มโอช่วยย่อยโปรตีน พร้อมใยอาหารชนิดละลายน้ำ',
        'description': 'ส้มโอทับทิมสยามหวานฉ่ำ คลุกเคล้าน้ำยำสมุนไพรมะนาวสด พริกคั่วหอม และกุ้งลายเสือตัวโต',
        'image': 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=600&auto=format&fit=crop&q=80',
        'tags': 'ช่วยย่อยโปรตีน,รสชาติสดชื่น,บำรุงทางเดินอาหาร',
        'is_recommended': 0,
      },
      {
        'id': 'M-04',
        'name': 'ปลากะพงนึ่งสมุนไพรตรีผลาและขิงซอย',
        'name_en': 'Steamed Sea Bass with Triphala Herbs & Young Ginger',
        'category': 'main',
        'price': 490.0,
        'calories': 260,
        'digestive_benefit': 'สารสกัดตรีผลา (สมอไทย, สมอพิเภก, มะขามป้อม) ปรับสมดุลธาตุ ล้างสารพิษในลำไส้ใหญ่',
        'description': 'ปลากะพงทะเลสดคัดพิเศษ เนื้อนุ่มหวาน นึ่งด้วยน้ำซุปสมุนไพร 3 กษัตริย์ ทานง่าย ย่อยเร็วที่สุด',
        'image': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&auto=format&fit=crop&q=80',
        'tags': 'ปรับสมดุลธาตุ,โปรตีนย่อยง่าย,ล้างพิษลำไส้',
        'is_recommended': 1,
      },
      {
        'id': 'M-05',
        'name': 'ข้าวกล้องสังข์หยดอบธัญพืช 5 มงคล',
        'name_en': 'Organic Sung Yod Brown Rice Baked with 5 Grains & Seeds',
        'category': 'main',
        'price': 150.0,
        'calories': 190,
        'digestive_benefit': 'ไฟเบอร์ไม่ละลายน้ำจากข้าวกล้องงอก เมล็ดเจีย และลูกเดือย ช่วยให้อุจจาระนิ่ม ขับถ่ายสบายไร้กังวล',
        'description': 'ข้าวกล้องพันธุ์พื้นเมืองพัทลุง หุงอบด้วยน้ำสต็อกผัก เม็ดบัว ถั่วแระญี่ปุ่น และเมล็ดฟักทอง',
        'image': 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&auto=format&fit=crop&q=80',
        'tags': 'ไฟเบอร์เชิงซ้อน,ดัชนีน้ำตาลต่ำ,บำรุงระบบย่อย',
        'is_recommended': 0,
      },
      {
        'id': 'M-06',
        'name': 'ชาหมักคอมบูชะออร์แกนิก ลิ้นจี่กุหลาบมอญ (Probiotic Sparkler)',
        'name_en': 'Artisan Kombucha - Wild Lychee & Organic Rose',
        'category': 'drink',
        'price': 160.0,
        'calories': 45,
        'digestive_benefit': 'จุลินทรีย์มีชีวิตกว่า 5,000 ล้าน CFU ฟื้นฟูจุลินทรีย์ดีในลำไส้ ลดอาการท้องอืด ท้องผูกอย่างได้ผล',
        'description': 'หมักบ่มนาน 21 วันด้วยชาเขียวอินทรีย์ ผสานน้ำลิ้นจี่สดและกลีบกุหลาบมอญออร์แกนิก ซ่าสดชื่นเบาๆ',
        'image': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&auto=format&fit=crop&q=80',
        'tags': 'โพรไบโอติกส์แท้,ลดกรดไหลย้อน,ซ่าสดชื่น,Signature',
        'is_recommended': 1,
      },
      {
        'id': 'M-07',
        'name': 'น้ำตรีผลาอุ่นน้ำผึ้งชันโรงแท้',
        'name_en': 'Warm Triphala Elixir with Wild Stingless Bee Honey',
        'category': 'drink',
        'price': 130.0,
        'calories': 60,
        'digestive_benefit': 'ยาระบายธรรมชาติชั้นเลิศตามศาสตร์การแพทย์แผนไทย ขับเมือกมันในลำไส้ หลับสบายสบายท้อง',
        'description': 'ต้มเคี่ยวสดใหม่ทุกเช้า รสชาติกลมกล่อมหอมละมุนด้วยน้ำผึ้งชันโรงป่าธรรมชาติ',
        'image': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&auto=format&fit=crop&q=80',
        'tags': 'สูตรโบราณ,ขับของเสียสะสม,บำรุงธาตุทั้ง 4',
        'is_recommended': 1,
      },
      {
        'id': 'M-08',
        'name': 'พุดดิ้งเมล็ดเจียนมข้าวโอ๊ต ราดซอสเสาวรสหมักลูกฟิก',
        'name_en': 'Chia Seed Oat Pudding with Wild Fig & Passionfruit Compote',
        'category': 'dessert',
        'price': 190.0,
        'calories': 160,
        'digestive_benefit': 'มูซิเลจ (Mucilage) จากเมล็ดเจียเคลือบกระเพาะ เสริมการบีบตัวของลำไส้ นุ่มละมุนท้อง',
        'description': 'ขนมหวานสูตรวีแกน ไร้นมวัว ไร้น้ำตาลทรายขาว ความหวานละมุนจากเนื้อลูกฟิกธรรมชาติและเสาวรสสด',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
        'tags': 'วีแกน 100%,เคลือบกระเพาะ,ไร้น้ำตาลขัดสี',
        'is_recommended': 0,
      },
    ];

    for (var m in menuItems) {
      batch.rawInsert('''
        INSERT INTO menu_items (id, restaurant_id, name, name_en, category, price, calories, description, digestive_benefit, image, tags, is_recommended)
        VALUES (?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        m['id'],
        m['name'],
        m['name_en'],
        m['category'],
        m['price'],
        m['calories'],
        m['description'],
        m['digestive_benefit'],
        m['image'],
        m['tags'],
        m['is_recommended'],
      ]);
    }

    // 6. Initial Sample Reservation (Matching demo UX for rich first experience)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    batch.rawInsert('''
      INSERT INTO bookings (
        id, booking_code, user_id, restaurant_id, table_id, booking_date, booking_time,
        period, guest_count, status, customer_name, customer_phone, customer_email,
        occasion, dietary_restrictions, special_request, total_amount, created_at
      ) VALUES (
        1, 'KDK-2026-8801', 1, 1, 3, '$tomorrowStr', '18:30',
        'dinner', 4, 'confirmed', 'คุณสุทัศน์ พิทักษ์ธรรม', '081-234-5678', 'sutas@example.com',
        'family', 'ไม่ใส่ผงชูรส (No MSG)', 'ขอมุมสงบใกล้ไม้ประดับฟอกอากาศ', 600.0, CURRENT_TIMESTAMP
      )
    ''');

    batch.rawInsert('''
      INSERT INTO booking_items (booking_id, menu_id, name, quantity, price, note) VALUES
      (1, 'M-01', 'แกงเลียงผักหวานกุ้งสดปลาย่างรมควัน', 1, 320.0, 'เผ็ดน้อย'),
      (1, 'M-02', 'น้ำพริกมะขามป้อมออร์แกนิก & สำรับผักอินทรีย์ 12 ชนิด', 1, 280.0, NULL)
    ''');

    await batch.commit(noResult: true);
  }
}
