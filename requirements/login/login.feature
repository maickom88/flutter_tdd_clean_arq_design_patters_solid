Feature: Login
Como cliente
Quero poder acessar minha conta e me manter logado
Para que eu possa ver e responder enquetes de forma rápipa.

Cenário: Credenciais Válidas
Dado que o cliente informou as Credenciais Válidas
Quando solicitar para fazer login
Então o sistema deve enviar o usuario para a tela de pesquisas
E manter o usuario conectado

Cenário: Credencias Inválidas
Dado que o cliente informou Credenciais Inválidas
Quando solicitar para fazer o login
Então o sistema deve retornar uma menssagem de error