# 🏍️ Moto Black - Aplicativo Mototaxista

Um aplicativo móvel desenvolvido em Flutter para mototaxistas gerenciarem suas corridas. O aplicativo permite aos mototaxistas receber solicitações de corridas, acompanhar passageiros em tempo real, gerenciar seu status online/offline e manter um histórico completo de atividades.

<a href="https://drive.google.com/file/d/1s8aDxcvFWrLBVcMQf-axb_SnoC36py0N/view?usp=sharing">Link demonstrativo</a>

## 📱 Funcionalidades

### 🚀 Principais Recursos
- **Sistema Online/Offline**: Toggle para ativar/desativar disponibilidade para corridas
- **Recebimento de Solicitações**: Interface para visualizar e aceitar/recusar corridas
- **Acompanhamento de Passageiros**: Visualização da localização do passageiro em tempo real
- **Sistema de Avaliação**: Avaliação de passageiros após cada corrida
- **Histórico de Atividades**: Registro completo de todas as corridas realizadas
- **Gerenciamento de Perfil**: Dados pessoais e informações dos veículos
- **Previsão do Tempo**: Informações meteorológicas em tempo real
- **Feed de Notícias**: Atualizações via RSS integradas
- **Autenticação Segura**: Sistema de login e registro

### 🎯 Funcionalidades Específicas
- **Geolocalização em Tempo Real**: Atualização automática da posição do mototaxista
- **Sugestões de Corridas**: Recebimento de propostas de corridas próximas
- **Gestão de Veículos**: Cadastro e edição de múltiplos veículos
- **Status de Corridas**: Acompanhamento do progresso da corridas ativa

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Flutter**: Framework principal para desenvolvimento mobile
- **Dart**: Linguagem de programação
- **Material Design**: Design system do Google

### Backend & APIs
- **Firebase**: Banco de dados em tempo real 
- **Google Maps API**: Mapas, geolocalização e navegação
- **HERE API**: Geocodificação e autocomplete de endereços
- **G1 RSS Feed**: Feed de notícias
- **Open Weather API**: Informações de clima

### Dependências Principais
```yaml
google_maps_flutter: ^2.3.1
firebase_core: ^2.15.1
firebase_database: ^10.2.5
geolocator: ^9.0.2
http: ^1.1.0
provider: ^6.1.2
shared_preferences: ^2.2.2
url_launcher: ^6.3.1
```

## 📋 Pré-requisitos
- Instalação e configuração da <a href="https://github.com/AlbertoJr789/app-motoblack-site-api">API Moto Black</a> (IMPORTANTE)
- Instalação e configuração do <a href="https://github.com/AlbertoJr789/app-motoblack-cliente">APP Cliente</a>.
- Flutter SDK (versão >=3.0.0), última versão que compilei foi a 3.24.5
- Dart SDK
- Android Studio / VS Code
- Conta para chave de <a href="https://console.cloud.google.com/welcome?hl=pt-br&pli=1&inv=1&invt=Ab1Gmg&project=moto-black"> API MAPS Google Cloud Platform </a>
- Conta <a href="https://console.firebase.google.com/u/0/?hl=pt-br"> Firebase </a>
- Conta para chave de <a href="https://developer.here.com/login"> API Here Technologies </a>
- Conta para chave de <a href="https://openweathermap.org/api"> API OpenWeather </a>
- Dispositivo Android/iOS ou emulador

## 🏗️ Estrutura do Projeto

```
lib/
├── controllers/          # Controladores de lógica de negócio
├── models/              # Modelos de dados
├── screens/             # Telas do aplicativo
├── widgets/             # Componentes reutilizáveis
├── theme/               # Configurações de tema
└── util/                # Utilitários e helpers
```

## 🚀 Instalação

### Instale as dependências
```bash
flutter pub get
```

### Configuração das APIs

#### Google Maps
- [ANDROID] Adicione a chave de API em `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <meta-data android:name="com.google.android.geo.API_KEY"
        android:value="{{YOUR_API_KEY}}"/>
    ```
- [iOS] Adicione a chave de API em `ios/Runner/AppDelegate.swift`:
    ```swift
    GMSServices.provideAPIKey("YOUR_API_KEY")
    ```

#### HERE API
- Procure a classe `controllers/hereAPIController.dart` e insira o token de API:
```dart
class HereAPIController implements Geocoder {
    static String _apiKey = ''; 
    // ...
}
```

#### OpenWeather
- Procure a classe `controllers/weatherController.dart` e insira o token de API:
```dart
class WeatherController {
    static const String _apiKey = '';
    // ...
}
```

### Configuração do Firebase
1. Crie um projeto no Firebase Console
2. Dentro do projeto, crie um Realtime Database (isso caso já não o tenha criado no aplicativo do passageiro, pois ambos utilizam o mesmo projeto).
3. Configure as regras do Realtime Database:
    ```json
    {
        "rules": {
            ".read": true,
            ".write": true,
            "availableAgents":{
                ".indexOn": ["type"]
            }
        }
    }
    ```
4. Utilize o <a href="https://firebase.google.com/docs/flutter/setup?hl=pt-br&platform=android"> Flutterfire e o Firebase CLI </a> para configurar o projeto Flutter.

### API Laravel

- Procure a classe `controllers/apiClient.dart` e insira a url Base em que está hospeada a api Laravel na sua rede LAN (lembre-se de seguir as instruções de configuração no repositório da API também):

```dart
...
class ApiClient {

  ApiClient._(){
    dio.options.connectTimeout = const Duration(seconds: 2);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.baseUrl = 'http://{{IPV4}}:8000'; // Replace with your Laravel API IPV4
...
```

### Execute o aplicativo
```bash
flutter run
```

## 📱 Como Usar

### Primeiro Acesso
1. Abra o aplicativo
2. Faça login ou crie uma conta
3. Permita acesso à localização
4. Configure seu perfil e veículos

### Iniciando Atividades
1. Na tela principal, ative o toggle "Online"
2. Aguarde receber sugestões de corridas
3. Visualize os detalhes da corrida proposta
4. Aceite ou recuse a corrida

### Durante uma Corrida
- Acompanhe a localização do passageiro
- Use a navegação integrada para chegar ao destino

### Após a Corrida
- Avalie o passageiro (1-5 estrelas)
- Deixe um comentário (opcional)
- Visualize o histórico na aba "Atividades"

### Gerenciamento de Perfil
- **Informações da Conta**: Edite dados pessoais
- **Meus Veículos**: Cadastre e gerencie seus veículos
- **Histórico**: Visualize todas as corridas realizadas

## 🔧 Funcionalidades Técnicas

### Sistema Online/Offline
- Toggle animado para ativar/desativar disponibilidade
- Atualização automática da localização em tempo real
- Integração com Firebase Realtime Database

### Recebimento de Corridas
- Sistema de sugestões baseado em proximidade
- Interface para visualizar detalhes da corrida
- Botões para aceitar ou recusar propostas

### Navegação
- Integração com Google Maps
- Rotas automáticas para origem e destino
- Visualização da distância aproximada

### Avaliações
- Sistema de rating com estrelas
- Comentários opcionais
- Histórico de avaliações

> 💡 **Não conseguiu configurar o projeto ?** [Clique aqui e acesse o vídeo com as instruções](https://youtu.be/m58e9LNdouU ) 
