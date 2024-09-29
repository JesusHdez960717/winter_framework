import 'dart:async';

import '../winter.dart';

class FilterChain {
  int _currentFilterIndex = 0;
  final List<Filter> _filters;

  FilterChain(List<Filter> filters, WinterHandler requestHandler)
      : _filters = List.of([...filters, BaseFilter(requestHandler)]);

  Future<ResponseEntity> doFilter(RequestEntity request) async {
    if (_currentFilterIndex < _filters.length) {
      final filter = _filters[_currentFilterIndex];
      _currentFilterIndex++;
      return await filter.doFilter(request, this);
    } else {
      return ResponseEntity.internalServerError(
        body: 'Filter chain ended without a response',
      );
    }
  }
}

abstract class Filter {
  Future<ResponseEntity> doFilter(
    RequestEntity request,
    FilterChain chain,
  );
}

class BaseFilter implements Filter {
  final WinterHandler _baseHandler;

  BaseFilter(this._baseHandler);

  @override
  Future<ResponseEntity> doFilter(
    RequestEntity request,
    FilterChain chain,
  ) async {
    return await _baseHandler(request);
  }
}
