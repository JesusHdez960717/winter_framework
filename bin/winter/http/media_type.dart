import 'package:http_parser/src/scan.dart';
import 'package:string_scanner/string_scanner.dart';

class MediaType {
  static MediaType ALL = MediaType(
    '*',
    '*',
  );
  static MediaType APPLICATION_ATOM_XML = MediaType(
    "application",
    "atom+xml",
  );
  static MediaType APPLICATION_CBOR = MediaType(
    "application",
    "cbor",
  );
  static MediaType APPLICATION_FORM_URLENCODED = MediaType(
    "application",
    "x-www-form-urlencoded",
  );
  static MediaType APPLICATION_GRAPHQL = MediaType(
    "application",
    "graphql+json",
  );
  static MediaType APPLICATION_GRAPHQL_RESPONSE = MediaType(
    "application",
    "graphql-response+json",
  );
  static MediaType APPLICATION_JSON = MediaType(
    "application",
    "json",
  );
  static MediaType APPLICATION_NDJSON = MediaType(
    "application",
    "x-ndjson",
  );
  static MediaType APPLICATION_OCTET_STREAM = MediaType(
    "application",
    "octet-stream",
  );
  static MediaType APPLICATION_PDF = MediaType(
    "application",
    "pdf",
  );
  static MediaType APPLICATION_PROBLEM_JSON = MediaType(
    "application",
    "problem+json",
  );
  static MediaType APPLICATION_PROBLEM_XML = MediaType(
    "application",
    "problem+xml",
  );
  static MediaType APPLICATION_PROTOBUF = MediaType(
    "application",
    "x-protobuf",
  );
  static MediaType APPLICATION_RSS_XML = MediaType(
    "application",
    "rss+xml",
  );
  static MediaType APPLICATION_STREAM_JSON = MediaType(
    "application",
    "stream+json",
  );
  static MediaType APPLICATION_XHTML_XML = MediaType(
    "application",
    "xhtml+xml",
  );
  static MediaType APPLICATION_XML = MediaType(
    "application",
    "xml",
  );
  static MediaType IMAGE_GIF = MediaType(
    "image",
    "gif",
  );
  static MediaType IMAGE_JPEG = MediaType(
    "image",
    "jpeg",
  );
  static MediaType IMAGE_PNG = MediaType(
    "image",
    "png",
  );
  static MediaType MULTIPART_FORM_DATA = MediaType(
    "multipart",
    "form-data",
  );
  static MediaType MULTIPART_MIXED = MediaType(
    "multipart",
    "mixed",
  );
  static MediaType MULTIPART_RELATED = MediaType(
    "multipart",
    "related",
  );
  static MediaType TEXT_EVENT_STREAM = MediaType(
    "text",
    "event-stream",
  );
  static MediaType TEXT_HTML = MediaType(
    "text",
    "html",
  );
  static MediaType TEXT_MARKDOWN = MediaType(
    "text",
    "markdown",
  );
  static MediaType TEXT_PLAIN = MediaType(
    "text",
    "plain",
  );
  static MediaType TEXT_XML = MediaType(
    "text",
    "xml",
  );

  final String type;
  final String subtype;

  /// The parameters to the media type.
  ///
  /// This map is immutable and the keys are case-insensitive.
  final Map<String, String> parameters;

  /// The media type's MIME type.
  String get mimeType => '$type/$subtype';

  const MediaType(
    this.type,
    this.subtype, {
    Map<String, String>? parameters,
  }) : parameters = parameters ?? const {};

  /// Parses a media type.
  ///
  /// This will throw a FormatError if the media type is invalid.
  factory MediaType.parse(String mediaType) {
    final scanner = StringScanner(
      mediaType,
    );
    scanner.scan(
      whitespace,
    );
    scanner.expect(
      token,
    );
    final type = scanner.lastMatch![0]!;
    scanner.expect(
      '/',
    );
    scanner.expect(
      token,
    );
    final subtype = scanner.lastMatch![0]!;
    scanner.scan(
      whitespace,
    );

    final parameters = <String, String>{};
    while (scanner.scan(';')) {
      scanner.scan(
        whitespace,
      );
      scanner.expect(
        token,
      );
      final attribute = scanner.lastMatch![0]!;
      scanner.expect(
        '=',
      );

      String value;
      if (scanner.scan(token)) {
        value = scanner.lastMatch![0]!;
      } else {
        value = expectQuotedString(
          scanner,
        );
      }

      scanner.scan(
        whitespace,
      );
      parameters[attribute] = value;
    }

    scanner.expectDone();
    return MediaType(
      type,
      subtype,
      parameters: parameters,
    );
  }
}
