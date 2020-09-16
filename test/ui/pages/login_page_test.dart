import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_tdd_clean_arq_solid_design_patters/ui/pages/pages.dart';

class LoginPresenterSpy extends Mock implements LoginPresenter {}

void main() {
  LoginPresenter presenter;
  StreamController<String> emailErrorController;
  StreamController<String> passwordErrorController;
  StreamController<String> mainErrorController;
  StreamController<bool> isFormValidController;
  StreamController<bool> isLoadingController;

  Future<void> loadPage(WidgetTester tester) async {
    presenter = LoginPresenterSpy();
    emailErrorController = StreamController<String>();
    passwordErrorController = StreamController<String>();
    mainErrorController = StreamController<String>();
    isFormValidController = StreamController<bool>();
    isLoadingController = StreamController<bool>();
    when(presenter.emailErrorStream)
        .thenAnswer((_) => emailErrorController.stream);
    when(presenter.passwordErrorStream)
        .thenAnswer((_) => passwordErrorController.stream);
    when(presenter.isFormValidStream)
        .thenAnswer((_) => isFormValidController.stream);
    when(presenter.isLoadingStream)
        .thenAnswer((_) => isLoadingController.stream);
    when(presenter.mainErrorStream)
        .thenAnswer((_) => mainErrorController.stream);
    final loginPage = MaterialApp(home: LoginPage(presenter));
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    emailErrorController.close();
    passwordErrorController.close();
    isFormValidController.close();
    isLoadingController.close();
    mainErrorController.close();
  });

  testWidgets('Should load with initial state', (WidgetTester tester) async {
    await loadPage(tester);

    final emailTextChildren = find.descendant(
        of: find.bySemanticsLabel('Email'), matching: find.byType(Text));
    expect(
      emailTextChildren,
      findsOneWidget,
      reason: 'descrição do error',
    );

    final passwordTextChildren = find.descendant(
        of: find.bySemanticsLabel('Senha'), matching: find.byType(Text));
    expect(
      passwordTextChildren,
      findsOneWidget,
      reason: 'descrição do error',
    );

    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));
    expect(button.onPressed, null);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('Should call validate with correct values',
      (WidgetTester tester) async {
    await loadPage(tester);

    final email = faker.internet.email();
    await tester.enterText(find.bySemanticsLabel('Email'), email);

    verify(presenter.validateEmail(email));

    final password = faker.internet.password();
    await tester.enterText(find.bySemanticsLabel('Senha'), password);

    verify(presenter.validatePassword(password));
  });

  testWidgets('Should presenter error if email is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add('any error');
    await tester.pump();
    expect(find.text('any error'), findsOneWidget);
  });

  testWidgets('Should presenter error if email is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    emailErrorController.add(null);
    await tester.pump();
    expect(
        find.descendant(
            of: find.bySemanticsLabel('Email'), matching: find.byType(Text)),
        findsOneWidget);
  });

  testWidgets('Should presenter error if password is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add('');
    await tester.pump();
    expect(
      find.descendant(
          of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('Should presenter error if password is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    passwordErrorController.add(null);
    await tester.pump();
    expect(
        find.descendant(
            of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)),
        findsOneWidget);
  });
  testWidgets('Should enable form button if form is valid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(true);
    await tester.pump();
    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));
    expect(button.onPressed, isNotNull);
  });
  testWidgets('Should disable form button if form is invalid',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(false);
    await tester.pump();
    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Should call authentication on form submit',
      (WidgetTester tester) async {
    await loadPage(tester);

    isFormValidController.add(true);
    await tester.pump();
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();
    verify(presenter.auth()).called(1);
  });

  testWidgets('Should present loading', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Should present loading hide', (WidgetTester tester) async {
    await loadPage(tester);

    isLoadingController.add(true);
    await tester.pump();
    isLoadingController.add(false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Should present error message if authentication fails',
      (WidgetTester tester) async {
    await loadPage(tester);

    mainErrorController.add('main error');
    await tester.pump();

    expect(find.text('main error'), findsOneWidget);
  });
  testWidgets('Should close streams on dispose', (WidgetTester tester) async {
    await loadPage(tester);

    addTearDown(() {
      verify(presenter.dispose()).called(1);
    });
  });
}
