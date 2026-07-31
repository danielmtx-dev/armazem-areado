# Armazém App

App Flutter para controle de armazém de sacas de café, com leitura de QR Code,
Firebase Auth (login) e Firestore (dados em tempo real).

Projeto Firebase conectado: **armazem-areado** (pacote `com.armazem`).

## O que já está pronto
- Tela de login (e-mail/senha via Firebase Auth)
- Tela principal com lista de sacas cadastradas (tempo real via Firestore)
- Tela de leitura de QR Code (usa a câmera do celular)
- Ao escanear, abre um formulário para confirmar/editar: número da saca,
  quantidade e tipo de bebida, antes de salvar
- `google-services.json` já incluído em `android/app/`

## Formato esperado do QR Code (opcional)
Se o QR Code contiver um JSON assim, os campos já vêm pré-preenchidos:
```json
{"numero": "123", "quantidade": 60, "tipoBebida": "Arábica"}
```
Se o QR Code só tiver texto/número simples, ele preenche apenas o campo
"número da saca" e você completa o resto manualmente.

## Antes de compilar, você precisa (no Firebase Console, projeto armazem-areado):
1. Ativar **Authentication** → método "E-mail/senha" → criar os usuários da equipe manualmente (aba Users → Add user)
2. Ativar **Firestore Database** (modo produção) e criar a coleção `sacas` (ela é criada sozinha no primeiro cadastro)
3. Ajustar as regras do Firestore para exigir login, por exemplo:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sacas/{doc} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Como compilar o APK

Você vai precisar do **Flutter SDK** instalado na sua máquina (não consigo
compilar o APK final aqui no ambiente do chat, só gerar o código-fonte).

1. Instale o Flutter: https://docs.flutter.dev/get-started/install
2. Abra o terminal na pasta deste projeto e rode:
   ```
   flutter pub get
   flutter build apk --release
   ```
3. O APK final aparece em:
   `build/app/outputs/flutter-apk/app-release.apk`

Para instalar direto no celular conectado via USB (com depuração USB ativada):
```
flutter install
```

## Observações
- O app está assinado com a chave de debug do Flutter por enquanto — funciona
  normal para instalar e testar, mas antes de publicar na Play Store é
  preciso gerar uma keystore própria e configurar a assinatura de release.
- Se quiser, posso ajustar o formulário, adicionar filtros/busca na lista,
  exportar relatórios, ou outras telas — é só pedir.
