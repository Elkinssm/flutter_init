import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Servicio para uploads autenticados (fotos).
class UploadApiService {
  UploadApiService(this._dio);

  final Dio _dio;

  /// POST /api/upload/foto — Sube foto y retorna url/path.
  Future<Map<String, dynamic>> uploadFoto(MultipartFile foto) async {
    final form = FormData.fromMap({'foto': foto});
    final response = await _dio.post<Map<String, dynamic>>(
      '/upload/foto',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data ?? {};
  }
}

final uploadApiServiceProvider = Provider<UploadApiService>((ref) {
  return UploadApiService(ref.read(apiClientProvider));
});
