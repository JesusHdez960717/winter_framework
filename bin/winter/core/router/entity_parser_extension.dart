import 'dart:async';

import 'package:shelf/shelf.dart';

import '../../http/http.dart';

extension RequestExt on Request {
  FutureOr<RequestEntity> toEntity() async {
    return RequestEntity(
      method: HttpMethod.valueOf(method),
      headers: HttpHeaders.fromSingleValues(headers),
      requestedUri: requestedUri,
      url: url,
      handlerPath: handlerPath,
      protocolVersion: protocolVersion,
      body: contentLength != null
          ? await readAsString()
          : null, //TODO: 123456789 aplicar la conversion/mapeo
    );
  }
}

extension ResponseExt on ResponseEntity {
  FutureOr<Response> toResponse() {
    return Response(
      status.value,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }
}
