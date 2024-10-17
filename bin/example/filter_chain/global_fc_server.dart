import '../../winter/winter.dart';

void main() => Winter.run(
      config: ServerConfig(port: 9090),
      globalFilterConfig: FilterConfig(
        [
          RemoveQueryParamsFilter(),
          //LogsFilter(),
          RateLimiterFilter(
            onRequest: (request) =>
                request.headers['X-Request-ID'] ?? 'unknown',
            rateLimiter: RateLimiter(
              1,
              const Duration(minutes: 1),
            ),
            log: (request, requestId) {
              print('Rate limiter fail');
            },
          )
        ],
      ),
      router: WinterRouter(
        routes: [
          Route(
            path: '/filter-chain/{id}',
            method: HttpMethod.get,
            handler: (request) => ResponseEntity.ok(
              body: 'path: ${request.pathParams}, query: ${request.queryParams}',
            ),
          ),
        ],
      ),
    );

class RemoveQueryParamsFilter implements Filter {
  @override
  Future<ResponseEntity> doFilter(
    RequestEntity request,
    FilterChain chain,
  ) async {
    request.pathParams.clear();
    request.queryParams.clear();
    return await chain.doFilter(request);
  }
}
