import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_tdd_clean_arq_solid_design_patters/data/http/http.dart';
import 'package:flutter_tdd_clean_arq_solid_design_patters/data/usecases/usecases.dart';

import 'package:flutter_tdd_clean_arq_solid_design_patters/domain/helpers/helpers.dart';
import 'package:flutter_tdd_clean_arq_solid_design_patters/domain/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;
  Map mockValidData() =>
      {"accessToken": faker.guid.guid(), "name": faker.person.name()};

  PostExpectation mockRequest() => when(
        httpClient.request(
          url: anyNamed('url'),
          method: anyNamed('method'),
          body: anyNamed('body'),
        ),
      );
  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError erro) {
    mockRequest().thenThrow(erro);
  }

  setUp(() {
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    mockHttpData(mockValidData());
  });
  test('Should call HttpClient whit correct values', () async {
    await sut.auth(params);

    verify(
      httpClient.request(
        url: url,
        method: 'post',
        body: {'email': params.email, 'password': params.secret},
      ),
    );
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    mockHttpError(HttpError.badRequest);
    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCrendencialsError if HttpClient returns 401',
      () async {
    mockHttpError(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredencials));
  });
  test('Should return a Account if HttpClient returns 200', () async {
    final validData = mockValidData();
    mockHttpData(validData);
    final account = await sut.auth(params);

    expect(account.token, validData["accessToken"]);
  });

  test(
      'Should throw UnexpectedError if HttpClient returns 200 with invalid data',
      () async {
    mockHttpData({'invalid_key': 'invalid_value'});

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
