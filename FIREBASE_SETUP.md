# Подключение Firebase к САН

Сейчас приложение работает на mock-слое (без бэкенда). Архитектура построена так, что Firebase подключается без изменения экранов: все реализации спрятаны за протоколами `AuthService`, `DataRepository`, `PushService`, а точка переключения — `AppConfig.swift`.

## 1. Создать проект Firebase

1. console.firebase.google.com → Add project → назови `san-kg`.
2. Add app → iOS, Bundle ID: `kg.san.app`.
3. Скачай `GoogleService-Info.plist` и перетащи в папку `SAN` в Xcode (target SAN, ✓ Copy if needed).

## 2. Подключить SDK (Swift Package Manager)

Xcode → File → Add Package Dependencies → `https://github.com/firebase/firebase-ios-sdk`

Добавь продукты к target SAN: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseMessaging`.
Для входа через Google ещё: `https://github.com/google/GoogleSignIn-iOS` → `GoogleSignIn`.

## 3. Включить методы входа

В консоли: Authentication → Sign-in method → включи **Email/Password**, **Google**, **Apple**.

- **Apple**: в Xcode target SAN → Signing & Capabilities → `+ Capability` → **Sign in with Apple**.
- **Google**: открой `GoogleService-Info.plist`, скопируй `REVERSED_CLIENT_ID`, добавь его как URL Scheme (target → Info → URL Types).

## 4. Структура Firestore (хранение заведений и акций)

Коллекция `venues` — документ на заведение (легко редактировать прямо в консоли):

```
venues/{venueID}
  name: string            "Navat"
  category: string        "teahouse"      // cafe|coffee|fastfood|restaurant|teahouse|bakery
  district: string        "Центр"
  address: string
  phone: string
  emoji: string           "🫖"
  gradientFrom: string    "#E65C00"
  gradientTo: string      "#F9D423"
  active: bool
```

Коллекция `deals` — документ на предложение:

```
deals/{dealID}
  venueID: string         "navat"
  type: string            "discount"      // discount|promo|novelty (С-А-Н)
  title: string
  details: string
  emoji: string
  oldPrice: number | null
  newPrice: number | null
  discountPercent: number | null
  validUntil: timestamp                   // истёкшие не показываются
```

Так твоя команда добавляет/правит заведения и акции прямо в Firebase Console — без релиза приложения.

### Правила безопасности (для старта)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /venues/{id} { allow read: if true; allow write: if request.auth != null; }
    match /deals/{id}  { allow read: if true; allow write: if request.auth != null; }
  }
}
```

Запись лучше делать через консоль/админ-панель, чтение — публичное.

## 5. Push-уведомления (FCM)

1. Apple Developer → Keys → создай APNs Auth Key (.p8), загрузи в Firebase → Project Settings → Cloud Messaging.
2. Xcode target SAN → Capabilities → **Push Notifications** + **Background Modes ▸ Remote notifications**.
3. Подписки по темам уже заложены в `PushService`:
   - `deals_bishkek` — все новые акции города;
   - `fav_<venueID>` — акции конкретного избранного места.
4. Рассылка: из консоли (Messaging → New campaign по теме) или Cloud Function на событие создания документа в `deals`.

## 6. Включить Firebase в коде

1. Переименуй `SAN/Firebase/FirebaseServices.swift.template` → `FirebaseServices.swift`, раскомментируй.
2. Допиши `Venue(firestore:id:)` и `Deal(firestore:id:)` под схему выше.
3. В `SANApp.swift` добавь в init: `FirebaseApp.configure()`.
4. В `AppConfig.swift` раскомментируй Firebase-ветки и поставь `useFirebase = true`.

Готово — экраны те же, данные и вход идут через Firebase.
