# ezconfig

Single file, under 1000 lines, zero dependencies typed config for Dart that doesn't make you write a `fromJson` for the hundredth time.

Declare your fields. Hand it a `Map`. Get typed values back, or a sensible default, but never a `type 'String' is not a subtype of type 'int'` nonsense.

## Why

Your config file is user input. User input is wrong. ezconfig assumes that and doesn't throw a tantrum about it.

- **No codegen.** No `build_runner`, no `.g.dart`, no waiting.
- **No exceptions on bad data.** Invalid values are replaced, not thrown at you.
- **Nested configs and lists** work the way you'd expect.
- **Null is a type, not an accident.** Nullable and non-nullable fields are different things, and the API says so.
- **Validation is opt-in and explicit.** Per field or global, and it rejects with a reason you wrote.

## Quick look

```dart
class ServerConfig extends EzConfig {
  late final EzField<String> host;
  late final EzField<int> port;
  late final EzField<bool?> debug;

  new([super.data]) {
    host = field('host', initial: () => 'localhost');
    port = field('port', initial: () => 8080);
    debug = fieldNull('debug');
  }
}

final cfg = ServerConfig({'host': 'example.com', 'port': 'oops'});

cfg.host.value;  // 'example.com' (valid, so it wins)
cfg.port.value;  // 8080          (invalid, so the initializer runs)
cfg.debug.value; // null          (missing, nullable, so null is fine)

cfg.getData(); // the serialized result, ready to write back to disk
```

## Fields

| Factory         | Type            | Stored `null` | Missing (or invalid loaded) key          |
|-----------------|-----------------|---------------|----------------------|
| `field`         | `T`             | invalid       | `initial` or default |
| `fieldNull`     | `T?`            | valid         | `initial` or `null`  |
| `list`          | `List<T>`       | invalid       | `initial` or `[]`    |
| `listNull`      | `List<T?>`      | invalid       | `initial` or `[]`    |
| `nullList`      | `List<T>?`      | valid         | `initial` or `null`  |
| `nullListNull`  | `List<T?>?`     | valid         | `initial` or `null`  |

`T` can be `bool`, `int`, `double`, `num`, `String`, `enum`, another `EzConfig`, or `dynamic` for "I don't care".

Every factory also accepts `initial` and `validate`.

## Nested configs

```dart
class AppConfig extends EzConfig {
  late final EzField<ServerConfig> server;
  late final EzFieldList<ServerConfig> replicas;

  new([super.data]) {
    server = field('server');
    replicas = list('replicas');
  }
}

void main() {
  // every nested config class must be registered
  EzConfig.register(ServerConfig.new);

  final app = AppConfig(loadJson());
}
```

A `Map` becomes a config. Anything else isn't one.

**Register every config class that is used as a field type.** The root class doesn't need it, because you construct it yourself. Forget a nested one and ezconfig has no idea how to build it.

Registering a second factory for the same type replaces the first.

## Enums

Enums work like nested configs: register them once, then use them as a field type.

```dart
enum LogLevel { debug, info, warning }

class AppConfig extends EzConfig {
  late final EzField<LogLevel> level;

  new([super.data]) {
    level = field('level', initial: () => LogLevel.info);
  }
}

void main() {
  EzConfig.registerEnum(LogLevel.values);
}
```

- Stored as a `String` holding the value's `name`. Not the index, because reordering the enum would silently change what a stored value means.
- Anything else is invalid: an unknown name, a number, a `Map`.
- Renaming an enum value invalidates every config file that still uses the old name.
- Without `initial`, an invalid or missing value gives the enum's **first** value, or `null` for nullable fields. The first value is rarely what you meant, so give non-nullable enum fields an `initial`.
- Lists of enums follow the usual list rules.

## Defaults

When a value is missing or invalid and there's no `initial`, you get the built-in default for the type:

| Type     | Default                  |
|----------|--------------------------|
| `bool`   | `false`                  |
| `int`    | `0`                      |
| `double` | `0.0`                    |
| `num`    | `0.0`                    |
| `String` | `''`                     |
| `Map`    | `<dynamic, dynamic>{}`   |
| `List`   | `<dynamic>[]`            |

Don't like them? Replace them:

```dart
EzConfig.defaultValue<int>(() => -1);
EzConfig.defaultValue<String>(() => 'unset');
```

This is global and per type. For one field, use `initial` instead.

## Validation

Valid type doesn't mean valid value. A port of `-5` is an `int`.

**Per field**, pass `validate`. Return a message to reject, `null` to accept:

```dart
port = field<int>('port',
  initial: () => 8080,
  validate: (v) => v > 0 && v < 65536 ? null : 'port out of range',
);
```

**Globally**, register a validator that sees every write:

```dart
EzConfig.validation((obj, field, value) {
  if (value is String && value.contains('\n')) return '$field must be one line';
  return null;
});
```

The callback gets the config instance being modified, the field key, and the value being assigned.

A rejected write throws `EzValidationException`, and the string you returned is its `reason`.

### Writes only, by default

Validators run when you **set** a value, not when data is loaded:

```dart
class MyConfig extends EzConfig {
  late final EzField<int> integer;

  new([super.data]) {
    integer = field('integer', validate: (v) => 'invalid');
  }
}

final config = MyConfig(); // fine, nothing is validated yet
config.integer.value = 10; // throws EzValidationException: 'invalid'
```

Loaded data that is merely wrong is handled by the rules below (replaced, defaulted, never thrown). That is deliberate: a config file with one bad value shouldn't take your app down on startup.

### Strict initializing

Want loaded data held to the same standard? Opt in per config class:

```dart
class MyConfig extends EzConfig {
  @override
  bool get strictInitializing => true;

  // ...fields as before
}
```

Now validators run during initialization too, so `MyConfig()` in the example above throws immediately. Use this when a bad value should be a startup failure, not a quiet fallback.

## Recovering bad data
 
Sometimes invalid data is fixable. An old config stored a port as `'8080'`, and you'd rather keep it than discard it. Pass `recover`:
 
```dart
port = field('port',
  initial: () => 8080,
  recover: (raw) => raw is String ? int.tryParse(raw) : null,
);
```
 
- Called only when loading, and only when the key is **present but invalid**. A valid value is never touched, and a missing key goes straight to `initial`.
- Receives the raw stored value and returns the field's type. Return `null` to say "can't fix this", and the usual fallback (`initial`, then the default) takes over.
- Lists are recovered whole, not element by element.
- Keep it cheap and side-effect free. Nested configs are rebuilt on every access, so a broken field runs `recover` on every read.
Order of precedence: valid stored value, then `recover`, then `initial`, then the type default.

## The rules

Read these once. They're the whole contract.

1. **A valid stored value always wins.** The initializer never overrides data that is actually fine.
2. **A missing or invalid value uses `initial`**, if you gave one.
3. **No `initial`? You get a default.** See the table above. Invalid list elements are replaced one by one.
4. **With `initial`, lists are all-or-nothing.** One bad element rejects the whole list and the initializer takes over.
5. **Numbers are coerced.** An `int` stored in a `double` field becomes a `double`.
6. **Stored `null`** is valid only for nullable kinds (see the table).

Rule 4 in practice. Say a `List<int>` field is stored as `[1, 'x', 3]`:
 
- **No `initial`:** the bad element is replaced by the type's default, so you get `[1, 0, 3]`.
- **With `initial: () => [9]`:** the whole list is rejected, so you get `[9]`.

Without a fallback, patching the bad element is the best ezconfig can do. With one, you've said what a good list looks like, so a list with a broken element isn't trusted and is replaced whole. The catch: adding `initial` to a field changes what invalid data produces. It's deliberate.

## Things worth knowing

- Nested config instances are created on every field access. They are views, not shared objects. Don't stash one and expect it to track later changes.
- `getData()` is the single source of truth, and it's what you serialize.
- Everything is validated against the declared type. If you declared it, it's checked.

## License

This project is released under the **zlib/libpng license**.

See [LICENSE](LICENSE) for details.