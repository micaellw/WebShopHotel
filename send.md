Architecture
                ┌─────────────────┐
                │   Flutter Web   │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │  Presentation   │
                │ UI + Controller │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │     UseCase     │
                │  Business Logic │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │   Repository    │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │  API Services   │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │    ApiClient    │
                └────────┬────────┘
                         │
                    JWT Cookie
                         │
                ┌────────▼────────┐
                │   API Gateway   │
                └────────┬────────┘
                         │
       ┌─────────────────┼─────────────────┐
       ▼                 ▼                 ▼
 Auth Service      Booking Service   Restaurant Service
       │                 │                 │
       ▼                 ▼                 ▼
     DB/Auth          DB/Booking       DB/Restaurant

 หลักที่ควรกำหนดเป็นมาตรฐานของโปรเจกต์
ผมจะกำหนดกฎไว้ตั้งแต่เริ่มเขียนเลย:

UI
❌ ห้ามเรียก API โดยตรง
❌ ห้ามเขียน business logic
❌ ห้ามเข้าถึง database

Controller
❌ ห้ามเขียน SQL
❌ ห้ามเรียก Dio โดยตรง
❌ ห้ามมี business logic ขนาดใหญ่

UseCase
✅ Business Logic
✅ Validation
✅ Flow ของแต่ละ operation

Repository
✅ abstraction ของ data

Service
✅ ติดต่อ API
✅ serialize / deserialize

ApiClient
✅ HTTP
✅ authentication transport
✅ error handling

Backend
✅ authorization
✅ business rule
✅ transaction
✅ booking conflict

 Flow ทั้งระบบ
ภาพรวมที่ผมแนะนำให้ยึดเป็นมาตรฐาน:

                    FLUTTER WEB
                         │
                         ▼
                    Presentation
                         │
                         ▼
                    Controller
                         │
                         ▼
                      UseCase
                         │
                         ▼
                    Repository
                         │
                         ▼
                  API/Data Service
                         │
                         ▼
                      ApiClient
                         │
                         ▼
                    API Gateway
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
     Auth Service   Booking Service   Restaurant
          │              │              │
          ▼              ▼              ▼
       Database       Database       Database

Flutter Feature: Booking
แยกเป็น

features/bookings/

├── data/
│   ├── models/
│   │   ├── booking_model.dart
│   │   └── create_booking_request.dart
│   │
│   ├── datasources/
│   │   └── booking_remote_datasource.dart
│   │
│   └── repositories/
│       └── booking_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── booking_entity.dart
│   │
│   ├── repositories/
│   │   └── booking_repository.dart
│   │
│   └── usecases/
│       ├── create_booking.dart
│       ├── cancel_booking.dart
│       └── get_my_bookings.dart
│
└── presentation/
    ├── controllers/
    │   └── booking_controller.dart
    │
    ├── pages/
    │   ├── booking_page.dart
    │   ├── booking_detail_page.dart
    │   └── booking_history_page.dart
    │
    └── widgets/
        ├── table_selector.dart
        ├── booking_form.dart
        └── booking_summary.dart

นี่คือสิ่งที่ผมแนะนำมากกว่าการมี

controllers/
services/
models/
pages/
widgets/

สำคัญที่สุดของระบบจองโต๊ะ
ต้องป้องกัน

User A ──────┐
             ├── Table 05 ── 19:00
User B ──────┘

ไม่ให้เกิด booking ซ้อนกัน

ดังนั้น ห้ามให้ Flutter เป็นคนตัดสินว่าจองสำเร็จ

ต้องเป็น Backend:

POST /bookings
       │
       ▼
Booking Service
       │
       ├── ตรวจ restaurant
       ├── ตรวจ table
       ├── ตรวจเวลา
       ├── ตรวจ booking ซ้ำ
       ├── transaction
       │
       ▼
Database
       │
       ▼
Booking Confirmed

 Database Design
สำหรับ “กินดีถ่ายข้อง” เบื้องต้นควรมี

users
restaurants
hotels
restaurant_tables
table_seats
bookings
booking_items
payments
reviews
notifications

ความสัมพันธ์:

User
 │
 └──── Booking
          │
          ├──── Restaurant
          │
          └──── Table

Restaurant:

Restaurant
    │
    ├── Tables
    │     ├── Table 01
    │     ├── Table 02
    │     └── Table 03
    │
    └── Opening Hours


Microservice ฝั่ง Backend
ถ้าจะทำให้แยกแบบ microservice จริง ผมเสนอประมาณนี้

backend/
│
├── api-gateway/
│
├── auth-service/
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── model/
│   └── database/
│
├── user-service/
│
├── restaurant-service/
│
├── table-service/
│
├── booking-service/
│
├── hotel-service/
│
└── notification-service/

แต่มีข้อควรระวัง:

อย่าเริ่มด้วย microservice 10 ตัวทันทีถ้ายังเป็น MVP

เพราะจะเพิ่มภาระเรื่อง

Docker
Network
Service discovery
Logging
Monitoring
Authentication
Message queue
Database migration
Deployment

สำหรับ version แรก ผมแนะนำ:

Flutter Web
     ↓
API Gateway
     ↓
Modular Backend
     ├── Auth Module
     ├── Restaurant Module
     ├── Table Module
     ├── Booking Module
     └── User Module

แล้วเมื่อระบบโต ค่อยแยก Module → Microservice

API Client กลาง
เช่น

core/network/api_client.dart

รับผิดชอบ:

GET
POST
PUT
PATCH
DELETE
timeout
error
401
403
500
serialization

ตัวอย่างโครงสร้าง:

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) {
    return dio.post(
      path,
      data: data,
    );
  }
}

แล้ว service ทั้งหมดใช้ตัวนี้

BookingApiService ──┐
RestaurantApiService│
AuthApiService ─────┼──> ApiClient
TableApiService ────┤
HotelApiService ────┘

Flutter ไม่ควรอ่าน JWT โดยตรง
ข้อดีของ HttpOnly

JavaScript / Flutter Web
        │
        X
        │
ไม่สามารถอ่าน access_token

แต่ Browser จะส่ง Cookie ไปกับ request ตาม policy

Flutter
   │
   │ GET /api/bookings
   ▼
Browser
   │
   │ Cookie: access_token=...
   ▼
Backend

ดังนั้น Flutter ไม่จำเป็นต้องทำ:

final token = localStorage.getItem('jwt');

แต่ API client ควรจัดการ authentication ให้เหมาะกับ cookie-based auth

JWT + Cookie
ส่วนนี้ผมแนะนำให้ทำให้ถูกตั้งแต่แรก

ไม่ควรทำ:

localStorage
   ↓
JWT

สำหรับระบบ login บน Web ให้ใช้

Browser
   │
   │ HTTPS
   ▼
POST /auth/login
   │
   ▼
Backend
   │
   ├── ตรวจ username/password
   │
   └── สร้าง session/JWT
          │
          ▼
Set-Cookie

Cookie ควรมีแนวคิดประมาณ:

Set-Cookie:
access_token=xxxxx;
HttpOnly;
Secure;
SameSite=Lax;
Path=/

ถ้าต้องการความปลอดภัยสูงขึ้น สามารถออกแบบเป็น

Access Token
     +
Refresh Token

โดยเฉพาะ refresh token ควรเก็บใน HttpOnly + Secure cookie

Repository
abstract class BookingRepository {
  Future<BookingEntity> createBooking(
    CreateBookingRequest request,
  );

  Future<List<BookingEntity>> getMyBookings();

  Future<void> cancelBooking(String bookingId);
}

Implementation:

class BookingRepositoryImpl implements BookingRepository {
  final BookingApiService apiService;

  BookingRepositoryImpl(this.apiService);

  @override
  Future<BookingEntity> createBooking(
    CreateBookingRequest request,
  ) async {
    final result = await apiService.createBooking(request);

    return result.toEntity();
  }

  @override
  Future<List<BookingEntity>> getMyBookings() async {
    final result = await apiService.getMyBookings();

    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return apiService.cancelBooking(bookingId);
  }
}

ทำให้ Domain ไม่ต้องรู้ว่าใช้ Dio, HTTP หรืออะไร

Business Logic อยู่ใน UseCase
ตัวอย่าง:

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> execute(
    CreateBookingRequest request,
  ) async {
    if (request.guestCount <= 0) {
      throw Exception('จำนวนผู้เข้าร่วมไม่ถูกต้อง');
    }

    if (request.date.isBefore(DateTime.now())) {
      throw Exception('ไม่สามารถจองวันที่ผ่านมาแล้ว');
    }

    return repository.createBooking(request);
  }
}

ตรงนี้สำคัญมาก

Controller = ควบคุม state
UseCase    = Business Logic
Service    = API
Repository = Data abstraction
UI         = Presentation

Base Controller
Controller ไม่ควรมี business logic หนัก ๆ

สร้างตัวกลาง:

abstract class BaseController {
  bool isLoading = false;
  String? errorMessage;

  void setLoading(bool value) {
    isLoading = value;
  }

  void setError(String? message) {
    errorMessage = message;
  }

  void clearError() {
    errorMessage = null;
  }
}

ตัวอย่าง:

class BookingController extends BaseController {
  final CreateBookingUseCase createBookingUseCase;

  BookingController(this.createBookingUseCase);

  Future<void> createBooking(
    CreateBookingRequest request,
  ) async {
    try {
      setLoading(true);
      clearError();

      await createBookingUseCase.execute(request);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

สังเกตว่า Controller ไม่ได้ยิง HTTP เอง

Base Service
ตามที่คุณต้องการให้มี service กลาง แล้ว service อื่นสืบทอดไปใช้ สามารถออกแบบประมาณนี้

abstract class BaseService {
  final ApiClient apiClient;

  BaseService(this.apiClient);

  Future<T> execute<T>(
    Future<T> Function() request,
  ) async {
    try {
      return await request();
    } catch (e) {
      throw handleError(e);
    }
  }

  Exception handleError(Object error) {
    return Exception(error.toString());
  }
}

แล้ว service เฉพาะด้าน:

class BookingApiService extends BaseService {
  BookingApiService(super.apiClient);

  Future<BookingModel> createBooking(
    CreateBookingRequest request,
  ) async {
    return execute(() async {
      final response = await apiClient.post(
        '/bookings',
        data: request.toJson(),
      );

      return BookingModel.fromJson(response.data);
    });
  }
}

Restaurant:

class RestaurantApiService extends BaseService {
  RestaurantApiService(super.apiClient);

  Future<List<RestaurantModel>> getRestaurants() async {
    return execute(() async {
      final response = await apiClient.get('/restaurants');

      return (response.data as List)
          .map((e) => RestaurantModel.fromJson(e))
          .toList();
    });
  }
}

Auth:

class AuthApiService extends BaseService {
  AuthApiService(super.apiClient);

  Future<UserModel> login(LoginRequest request) async {
    return execute(() async {
      final response = await apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      return UserModel.fromJson(response.data);
    });
  }
}

ทำให้ service แต่ละตัวมีหน้าที่ของตัวเอง

แยก UI ออกจาก Logic
ตัวอย่างการจองโต๊ะ

อย่าเขียนแบบนี้:

onPressed: () async {
  final response = await dio.post(
    '/booking',
    data: {
      'tableId': tableId,
      'date': date,
    },
  );

  if (response.statusCode == 200) {
    ...
  }
}

ใน Widget

ให้เป็น:

BookingPage
     │
     ▼
BookingController
     │
     ▼
CreateBookingUseCase
     │
     ▼
BookingRepository
     │
     ▼
BookingApiService
     │
     ▼
ApiClient
     │
     ▼
Backend

ดังนั้น UI มีหน้าที่ แสดงผลและรับ interaction

Controller มีหน้าที่ จัดการ state/UI event

UseCase มีหน้าที่ business logic

Service มีหน้าที่ ติดต่อ API

Repository มีหน้าที่ เป็น abstraction ของ data

โครงสร้าง Flutter Web
ผมแนะนำให้แยกเป็น feature + layer แบบนี้

lib/
│
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   └── route_guard.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   │
│   └── config/
│       ├── app_config.dart
│       └── environment.dart
│
├── core/
│   │
│   ├── base/
│   │   ├── base_controller.dart
│   │   ├── base_service.dart
│   │   ├── base_api_service.dart
│   │   └── base_usecase.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_response.dart
│   │   ├── api_exception.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── error_interceptor.dart
│   │
│   ├── auth/
│   │   ├── auth_manager.dart
│   │   ├── auth_state.dart
│   │   └── auth_user.dart
│   │
│   ├── storage/
│   │   └── cookie_storage.dart
│   │
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   │
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── validator.dart
│   │   └── formatter.dart
│   │
│   └── errors/
│       ├── failure.dart
│       └── result.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   │
│   │   └── presentation/
│   │       ├── controllers/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── restaurants/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── tables/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── bookings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── hotels/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── users/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── admin/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

จุดสำคัญคือ feature หนึ่งไม่ควรไปยุ่งกับ implementation ภายในของ feature อื่นโดยตรง

Architecture ที่แนะนำ
ใช้แนวคิดประมาณนี้:

                         ┌──────────────────────┐
                         │      Flutter Web     │
                         │        Frontend      │
                         └──────────┬───────────┘
                                    │
                              HTTPS / JWT Cookie
                                    │
                         ┌──────────▼───────────┐
                         │       API Gateway    │
                         └──────────┬───────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
       ┌──────▼──────┐       ┌──────▼──────┐       ┌──────▼──────┐
       │ Auth Service│       │Booking Svc  │       │Restaurant   │
       │             │       │             │       │Service      │
       └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
              │                     │                     │
              └─────────────────────┼─────────────────────┘
                                    │
                              Database Layer
                                    │
                              ┌─────▼─────┐
                              │  SQLite   │
                              │ / Prod DB │
                              └───────────┘

หลักสำคัญคือ

UI
 ↓
Controller
 ↓
UseCase / Logic
 ↓
Service
 ↓
API Client
 ↓
Backend
 ↓
Database

ไม่ควรเป็น

Widget
  ↓
HTTP
  ↓
SQL
  ↓
Business Logic

เพราะจะทำให้แก้ไขระบบภายหลังยากมาก