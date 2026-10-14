# Практична робота 6.2 - Provider State Management

**Варіант 2: Авторизація та профіль**

## Запуск

```bash
flutter create .          # згенерує android/ios/web та .gitignore
rm -f test/widget_test.dart
flutter pub get
flutter analyze
flutter run
```

**Тестовий акаунт:** `test@example.com` / `password123`
(будь-які інші дані -> "Невірний email або пароль").

## Структура

```
lib/
  main.dart                      MultiProvider над MaterialApp, AppRoot
  api/fake_api.dart              "сервер": затримка + випадкова помилка
  models/auth_model.dart         AuthModel (стан входу, помилка)
  models/profile_model.dart      ProfileModel (loading / error / data)
  models/user_profile.dart       незмінний клас профілю
  screens/login_screen.dart      форма входу
  screens/home_screen.dart       головний екран
  screens/edit_profile_screen.dart
```

## Де що використано

| API | Де | Чому |
|---|---|---|
| `MultiProvider` + `create` | `main.dart` | `FakeApi`, `AuthModel`, `ProfileModel` створюються один раз над `MaterialApp`; `.value` не використовується |
| `context.select` | `AppRoot` (`isLoggedIn`), `_SubmitButton` (`isLoading`), `_ProfileBody` (`status`), `_Greeting` (ім'я), `_ErrorView` | віджет залежить від одного поля, тож перебудовується лише коли воно змінилось |
| `Selector` | `_ErrorText` на екрані входу | підписка лише на текст помилки |
| `Consumer` | `_LoggedInAs` | маленький листковий віджет, якому потрібна вся `AuthModel` |
| `context.watch` | `_Details` | листок залежить від усього профілю (email + біо) |
| `context.read` | колбеки: `_submit`, `_logout`, "Повторити", "Зберегти", `initState` | лише викликаємо метод, підписка не потрібна |
| `setState` | `LoginScreen` ("показати пароль"), контролери форм | ефемерний стан, що не потрібен решті застосунку |

Додатково:
- пароль не зберігається в моделі, він лише передається в `login()`;
- кнопка "Увійти" неактивна під час запиту й показує індикатор;
- профіль завантажується через `FakeApi` (~кожен 5-й запит - помилка), UI показує індикатор, повідомлення та кнопку "Повторити";
- `dispose()` викликається для всіх `TextEditingController`.

## Звіт про перебудови

У кожному `build()` стоїть `debugPrint('build: ...')`. Рахувати рядки в консолі.

**"До"** - `context.watch<...>()` / `Consumer` на весь екран/модель
(коміт `refactor: watch everywhere`).
**"Після"** - `select` / `Selector` (коміт `perf: use select/Selector`).

| Дія | Перебудов до | Перебудов після |
|---|---|---|
| Натиснути "Увійти" з невірним паролем (isLoading true -> false + помилка) | 4 (AppRoot x2, LoginScreen x2) | 3 (SubmitButton x2, ErrorText x1); AppRoot і LoginScreen - 0 |
| Ввести текст у поле email | 0 | 0 (модель не сповіщається, перебудовується лише саме поле) |
| Зберегти профіль, змінивши лише "Про себе" | 3 (ProfileBody, Greeting, Details) | 1 (Details); Greeting і ProfileBody - 0 |

> ЗАУВАЖЕННЯ: значення в таблиці отримані аналізом коду. Перед здачею перевір їх
> реальним запуском і виправ цифри, якщо відрізняються.

## Скриншоти

- [ ] екран входу
- [ ] помилка входу
- [ ] головний екран
- [ ] стан помилки завантаження профілю (з кнопкою "Повторити")
- [ ] редагування профілю

## Історія комітів (план)

1. `chore: init flutter project, add provider`
2. `feat: FakeApi and models (AuthModel, ProfileModel)`
3. `feat: login form with validation`
4. `feat: home screen, profile loading states, edit profile`
5. `refactor: watch everywhere (baseline rebuild counts)` - "до"
6. `perf: use select/Selector` - "після"
7. `docs: README with rebuild report`

### Як отримати версію "до" (коміт 5)

Тимчасово замінити:
- `AppRoot`: `context.watch<AuthModel>().isLoggedIn`
- `LoginScreen.build`: `final auth = context.watch<AuthModel>();` і брати з нього `isLoading` / `error` (без `_ErrorText`/`_SubmitButton` як підписників)
- `_ProfileBody`: `context.watch<ProfileModel>().status`
- `_Greeting`: `context.watch<ProfileModel>().profile?.name ?? ''`
