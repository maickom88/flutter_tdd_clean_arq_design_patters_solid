import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter_tdd_clean_arq_solid_design_patters/data/http/http.dart';
import 'package:flutter_tdd_clean_arq_solid_design_patters/infra/http/http.dart';

class ClintSpy extends Mock implements Client {}

void main() {
  ClintSpy client;
  HttpAdapter sut;
  String url;
  setUp(() {
    client = ClintSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });
  group('post', () {
    PostExpectation mockRequest() => when(
        client.post(any, body: anyNamed('body'), headers: anyNamed('headers')));

    void mockResponse(int statusCode,
        {String body = '{"any_key":"any_value"}'}) {
      mockRequest().thenAnswer((_) async => Response(body, statusCode));
    }

    setUp(() {
      mockResponse(200);
    });

    test('Should call post with correct values', () async {
      await sut
          .request(url: url, method: 'post', body: {'any_key': 'any_value'});

      verify(client.post(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: '{"any_key":"any_value"}',
      ));
    });

    test('Should call post without body', () async {
      await sut.request(
        url: url,
        method: 'post',
      );

      verify(client.post(
        any,
        headers: anyNamed('headers'),
      ));
    });

    test('Should return data if returns 200', () async {
      final response = await sut.request(url: url, method: 'post');

      expect(response, {'any_key': 'any_value'});
    });

    test('Should return null  data if returns 200 with no data', () async {
      mockResponse(200, body: '');
      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('Should return null data if returns 204', () async {
      mockResponse(204, body: '');
      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });

    test('Should return null data if returns 204 with data', () async {
      mockResponse(204);
      final response = await sut.request(url: url, method: 'post');

      expect(response, null);
    });
    test('Should return BadRequestError if post returns 400', () async {
      mockResponse(400, body: '');
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.badRequest));
    });
    test('Should return BadRequestError if post returns 400', () async {
      mockResponse(400);
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.badRequest));
    });
    test('Should return ServerError if post returns 500', () async {
      mockResponse(500);
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.serverError));
    });

    test('Should return AnauthorizedError if post returns 401', () async {
      mockResponse(401);
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.unauthorized));
    });
    test('Should return forbidden if post returns 401', () async {
      mockResponse(403);
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.forbidden));
    });

    test('Should return notFoundError if post returns 404', () async {
      mockResponse(404);
      final furure = sut.request(url: url, method: 'post');

      expect(furure, throwsA(HttpError.notFound));
    });
  });
}
