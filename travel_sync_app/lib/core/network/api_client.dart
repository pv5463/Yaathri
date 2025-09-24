import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

import '../config/app_config.dart';
import '../../data/models/user_model.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/expense_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  // Authentication endpoints
  @POST('/auth/login')
  Future<ApiResponse<UserModel>> login(@Body() Map<String, dynamic> loginData);

  @POST('/auth/register')
  Future<ApiResponse<UserModel>> register(@Body() Map<String, dynamic> registerData);

  @POST('/auth/social-login')
  Future<ApiResponse<UserModel>> socialLogin(@Body() Map<String, dynamic> socialData);

  @POST('/auth/phone-login')
  Future<ApiResponse<String>> phoneLogin(@Body() Map<String, dynamic> phoneData);

  @POST('/auth/verify-otp')
  Future<ApiResponse<UserModel>> verifyOtp(@Body() Map<String, dynamic> otpData);

  @POST('/auth/forgot-password')
  Future<ApiResponse<String>> forgotPassword(@Body() Map<String, dynamic> emailData);

  @POST('/auth/reset-password')
  Future<ApiResponse<String>> resetPassword(@Body() Map<String, dynamic> resetData);

  @POST('/auth/logout')
  Future<ApiResponse<String>> logout();

  @GET('/auth/me')
  Future<ApiResponse<UserModel>> getCurrentUser();

  // User endpoints
  @PUT('/users/{id}')
  Future<ApiResponse<UserModel>> updateUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> userData,
  );

  @DELETE('/users/{id}')
  Future<ApiResponse<String>> deleteUser(@Path('id') String userId);

  // Trip endpoints
  @GET('/trips')
  Future<ApiResponse<List<TripModel>>> getTrips(
    @Query('user_id') String userId,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
    @Query('status') String? status,
  );

  @GET('/trips/{id}')
  Future<ApiResponse<TripModel>> getTripById(@Path('id') String tripId);

  @POST('/trips')
  Future<ApiResponse<TripModel>> createTrip(@Body() Map<String, dynamic> tripData);

  @PUT('/trips/{id}')
  Future<ApiResponse<TripModel>> updateTrip(
    @Path('id') String tripId,
    @Body() Map<String, dynamic> tripData,
  );

  @DELETE('/trips/{id}')
  Future<ApiResponse<String>> deleteTrip(@Path('id') String tripId);

  @POST('/trips/{id}/locations')
  Future<ApiResponse<TripModel>> addLocationPoint(
    @Path('id') String tripId,
    @Body() Map<String, dynamic> locationData,
  );

  @POST('/trips/{id}/media')
  Future<ApiResponse<TripModel>> addTripMedia(
    @Path('id') String tripId,
    @Body() Map<String, dynamic> mediaData,
  );

  @DELETE('/trips/{id}/media')
  Future<ApiResponse<TripModel>> removeTripMedia(
    @Path('id') String tripId,
    @Query('media_url') String mediaUrl,
  );

  @POST('/trips/sync')
  Future<ApiResponse<List<TripModel>>> syncTrips(
    @Body() Map<String, dynamic> syncData,
  );

  // Expense endpoints
  @GET('/expenses')
  Future<ApiResponse<List<ExpenseModel>>> getExpenses(
    @Query('user_id') String userId,
    @Query('trip_id') String? tripId,
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  );

  @GET('/expenses/{id}')
  Future<ApiResponse<ExpenseModel>> getExpenseById(@Path('id') String expenseId);

  @POST('/expenses')
  Future<ApiResponse<ExpenseModel>> createExpense(@Body() Map<String, dynamic> expenseData);

  @PUT('/expenses/{id}')
  Future<ApiResponse<ExpenseModel>> updateExpense(
    @Path('id') String expenseId,
    @Body() Map<String, dynamic> expenseData,
  );

  @DELETE('/expenses/{id}')
  Future<ApiResponse<String>> deleteExpense(@Path('id') String expenseId);

  @GET('/expenses/categories')
  Future<ApiResponse<List<String>>> getExpenseCategories();

  // Budget endpoints
  @GET('/budgets')
  Future<ApiResponse<List<BudgetModel>>> getBudgets(
    @Query('user_id') String userId,
    @Query('trip_id') String? tripId,
  );

  @POST('/budgets')
  Future<ApiResponse<BudgetModel>> createBudget(@Body() Map<String, dynamic> budgetData);

  @PUT('/budgets/{id}')
  Future<ApiResponse<BudgetModel>> updateBudget(
    @Path('id') String budgetId,
    @Body() Map<String, dynamic> budgetData,
  );

  @DELETE('/budgets/{id}')
  Future<ApiResponse<String>> deleteBudget(@Path('id') String budgetId);

  // Analytics endpoints
  @GET('/analytics/travel-insights')
  Future<ApiResponse<Map<String, dynamic>>> getTravelInsights(
    @Query('user_id') String userId,
    @Query('period') String period,
  );

  @GET('/analytics/expense-summary')
  Future<ApiResponse<Map<String, dynamic>>> getExpenseSummary(
    @Query('user_id') String userId,
    @Query('period') String period,
  );

  // Media upload endpoints
  @POST('/media/upload')
  @MultiPart()
  Future<ApiResponse<Map<String, dynamic>>> uploadMedia(
    @Part() File file,
    @Part() String type,
    @Part() String? tripId,
  );

  @DELETE('/media/{id}')
  Future<ApiResponse<String>> deleteMedia(@Path('id') String mediaId);

  // Sync endpoints
  @POST('/sync/data')
  Future<ApiResponse<Map<String, dynamic>>> syncData(
    @Body() Map<String, dynamic> syncData,
  );

  @GET('/sync/status')
  Future<ApiResponse<Map<String, dynamic>>> getSyncStatus(
    @Query('user_id') String userId,
  );
}

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

// Dio interceptor for authentication
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authentication token to headers
    final token = _getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle authentication errors
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      _handleAuthError();
    }
    
    super.onError(err, handler);
  }

  String? _getAuthToken() {
    // TODO: Get token from secure storage
    return null;
  }

  void _handleAuthError() {
    // TODO: Navigate to login screen or refresh token
  }
}

// Dio interceptor for logging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Message: ${err.message}');
    if (err.response?.data != null) {
      print('Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

// Dio configuration
Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  // Add interceptors
  dio.interceptors.addAll([
    AuthInterceptor(),
    LoggingInterceptor(),
  ]);

  return dio;
}
