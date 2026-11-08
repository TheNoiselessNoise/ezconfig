import 'dart:convert';
import 'dart:collection';

/// A factory used to create an [EzConfig] instance from serialized data.
///
/// The optional [EzConfigParent] describes the field and configuration instance
/// containing the newly created configuration.
typedef EzConfigFactory<X extends EzConfig> = X Function([Map data]);

/// A factory that produces a default value for a particular type.
///
/// Default value factories are registered through [EzConfig.defaultValue].
typedef EzDefault<X> = X Function();

/// A validation callback invoked whenever an [EzConfig] field is written.
///
/// [obj] is the configuration instance being modified, [field] is the
/// key used writing the value, and [value] is the value being assigned.
///
/// Validators can return [String] to reject a value,
/// which is also [EzValidationException.reason].
typedef EzGlobalValidator = String? Function(EzConfig obj, String field, dynamic value);

/// A field specific validation callback invoked whenever given field is written.
///
/// [value] is the value being assigned.
///
/// Validators can return [String] to reject a value,
/// which is also [EzValidationException.reason].
typedef EzFieldValidator<X> = String? Function(X value);

/// A callback used to recover an invalid value loaded from serialized data.
///
/// [raw] is the original stored value before any conversion or defaulting.
///
/// Return a value of type [X] to recover the field. Return `null` if the
/// value cannot be recovered, allowing the usual fallback mechanisms to
/// take over.
///
/// Recovery is performed only during loading, when the stored key is present
/// but its value is invalid. Lists are recovered as a whole rather than
/// element by element.
typedef EzFieldRepair<X> = X? Function(Object? raw);

/// Exception if any [EzGlobalValidator] or [EzFieldValidator] returns [String].
final class EzValidationException implements Exception {
  final String key;
  final Object? value;
  final String reason;

  /// Creates a new [EzValidationException].
  const EzValidationException(this.key, this.value, this.reason);

  @override
  String toString() => 'EzValidationException: cannot set "$key" ($reason)';
}

/// A typed, live reference to a single configuration field.
///
/// A [EzField] provides controlled access to a value stored in an [EzConfig]
/// instance. Reading the field retrieves its current value, while writing
/// delegates to its setter, allowing the owning configuration to perform
/// validation and serialization.
class EzField<T> {
  /// The key identifying this field in its owning configuration.
  final String key;

  final EzFieldValidator<T>? _validator;

  final T? Function(Object? raw)? _recover;

  final (dynamic raw, bool found) Function() _traverseRaw;

  final (bool, T?) Function() _tryGet;

  final T Function() _get;

  final void Function(T, {required bool strict}) _set;

  final T Function() _reset;

  final EzDefault<T>? _initial;

  /// Creates a field backed by the supplied getter, setter and reset.
  EzField(this.key, {
    required this._validator,
    required this._recover,
    required this._traverseRaw,
    required this._tryGet,
    required this._get,
    required this._set,
    required this._reset,
    this._initial
  });

  T _getOrInitial() {
    final (ok, value) = _tryGet();
    // 1. valid stored value
    if (ok && (value != null || null is T)) return value as T;
    final (raw, found) = _traverseRaw();
    if (found && _recover != null) {
      // 2. present but invalid
      final fixed = _recover(raw);
      if (fixed != null) return fixed;
    }
    // 3. missing, or recover gave up
    if (_initial != null) return _initial();
    // 4. type default / lenient path
    return this.value;
  }

  /// Returns the current value of this field.
  ///
  /// The value is retrieved on every access rather than cached.
  T get value => _get();

  /// Replaces the current field value.
  ///
  /// This is equivalent to calling [set].
  set value(T value) => _set(value, strict: true);

  /// Replaces the current field value.
  ///
  /// This is equivalent to assigning [value].
  void set(T value, {bool strict = true}) => _set(value, strict: strict);

  /// Validates a value.
  String? validate([T? value]) => _validator?.call(value ?? this.value);

  /// Resets the value of the field to the default.
  void reset() => set(_reset());
}

/// A live, list-like view of a configuration field containing a list.
///
/// [EzFieldList] implements [ListBase] while routing modifications through
/// the underlying field setter. This ensures that changes are written back
/// to the owning [EzConfig], including validation and serialization.
///
/// Most modifying operations work on a copy of the current list and replace
/// the stored value with the modified copy.
final class EzFieldList<T> extends EzField<List<T>> with ListBase<T> {
  /// Creates a list view backed by the supplied field getter and setter.
  EzFieldList(super.key, {
    required super.validator,
    required super.recover,
    required super.traverseRaw,
    required super.tryGet,
    required super.get,
    required super.set,
    required super.reset,
    super.initial
  });

  /// Returns the number of elements in the current list.
  @override
  int get length => value.length;

  /// Changes the number of elements in the list.
  ///
  /// A copy of the current list is resized and written back to the field.
  /// Growing the list uses the default fill behavior of [List.length].
  @override
  set length(int value) {
    final list = [...this.value];
    list.length = value;
    set(list);
  }

  /// Returns the element at [index].
  @override
  T operator [](int index) => value[index];

  /// Replaces the element at [index].
  @override
  void operator []=(int index, T value) {
    final list = [...this.value];
    list[index] = value;
    set(list);
  }

  /// Inserts [element] at the specified [index].
  @override
  void insert(int index, T element) {
    final list = [...value];
    list.insert(index, element);
    set(list);
  }

  /// Appends [element] to the list.
  @override
  void add(T element) => set([...value, element]);

  /// Appends all elements from [iterable] to the list.
  @override
  void addAll(Iterable<T> iterable) => set([...value, ...iterable]);

  /// Modifies the underlying list in place through [modifier].
  ///
  /// Unlike the other modifying operations, this method passes the current
  /// list directly to the callback instead of creating a copy.
  void modify(void Function(List<T> list) modifier) {
    final list = value;
    modifier(list);
    set(list);
  }
}

/// A configuration field containing an optional list.
///
/// Unlike [EzFieldList], which always exposes a non-null list, this class
/// preserves the distinction between a null value and an empty list.
///
/// Use [list] to obtain a list view when the value is non-null, or [ensured]
/// to initialize the field with an empty list when necessary.
final class EzNullFieldList<T> extends EzField<List<T>?> {
  /// Creates a nullable list field backed by the supplied getter and setter.
  EzNullFieldList(super.key, {
    required super.validator,
    required super.recover,
    required super.traverseRaw,
    required super.tryGet,
    required super.get,
    required super.set,
    required super.reset,
    required super.initial
  });

  /// Whether the underlying list value is null.
  bool get isNull => value == null;

  /// Returns a live [EzFieldList] view if the underlying value is non-null.
  ///
  /// Returns null when the field itself contains null.
  EzFieldList<T>? get list => value == null ? null : .new(key,
    validator: (value) => _validator?.call(value),
    recover: (raw) => _recover?.call(value),
    traverseRaw: _traverseRaw,
    tryGet: _tryGet,
    get: () => value!,
    set: (v, {bool strict = false}) => set(v, strict: strict),
    reset: () => _reset() ?? [],
  );

  /// Ensures that the field contains a list and returns its live view.
  ///
  /// If the current value is null, an empty list is assigned first.
  EzFieldList<T> get ensured {
    if (value == null) set(<T>[]);
    return list!;
  }

  /// Sets the underlying field value to null.
  void clear() => set(null);
}

/// Describes the relationship between a nested configuration and its parent.
///
/// The [key] identifies the field in the parent configuration that contains
/// this configuration, while [config] references the parent instance.
final class EzConfigParent {
  /// The key under which this configuration is stored in its parent.
  final String key;

  /// The configuration instance containing this configuration.
  final EzConfig config;

  /// Creates a parent reference for a nested configuration.
  EzConfigParent(this.key, this.config);
}

final class _ConfigView extends MapBase<String, dynamic> {
  final EzConfig _config;
  
  _ConfigView(this._config);

  @override
  Iterable<String> get keys => _config._fields.keys;

  @override
  int get length => _config._fields.length;

  @override
  bool containsKey(Object? key) => _config._fields.containsKey(key);

  @override
  dynamic operator [](Object? key) => containsKey(key) ? _config._data[key] : null;

  @override
  void operator []=(String key, dynamic value) {
    if (!containsKey(key)) throw EzValidationException(key, value, 'unknown field');
    _config._writeField(key, value, strict: true);
  }

  @override
  dynamic remove(Object? key) => throw UnsupportedError('Fields cannot be removed');

  @override
  void clear() => throw UnsupportedError('Fields cannot be cleared');
}

/// Base class for configurations backed by dynamically typed map data.
///
/// [EzConfig] provides typed field access, nested configuration support,
/// default values, list handling, validation, and serialization.
///
/// Subclasses typically expose their configuration properties through
/// [field], [fieldNull], [list], and the other field registration methods.
///
/// Configuration factories and custom default values are registered
/// statically and are shared between all configuration instances.
abstract class EzConfig {
  static final Map<Type, EzConfigFactory> _factories = {};

  static final Map<Type, EzDefault> _defaults = {
    bool: () => false,
    int: () => 0,
    double: () => 0.0,
    num: () => 0.0,
    String: () => '',
    Map: () => <dynamic, dynamic>{},
    List: () => <dynamic>[],
  };

  static final Map<Type, List<Enum>> _enums = {};
  
  static final List<EzGlobalValidator> _validators = [];

  /// Whether field values should be validated during configuration initialization.
  ///
  /// By default, validation is performed only when values are explicitly set.
  /// Override this to `true` to also validate values loaded during initialization.
  ///
  /// When enabled, invalid loaded values cause an [EzValidationException]
  /// instead of being silently replaced or defaulted.
  bool get strictInitializing => false;

  /// Registers a factory for constructing instances of [X].
  ///
  /// The factory receives the serialized map data and an optional parent
  /// reference describing where the new instance belongs.
  ///
  /// Registering another factory for the same type replaces the previous one.
  static void register<X extends EzConfig>(EzConfigFactory<X> factory)
    => _factories[X] = factory;

  /// Registers a factory for producing default values of type [X].
  ///
  /// The factory is used when a field does not contain a compatible value
  /// and a default is required.
  ///
  /// Registering another default for the same type replaces the previous one.
  static void defaultValue<X>(EzDefault<X> factory)
    => _defaults[X] = factory;

  /// Registers a global validator invoked whenever a field is written.
  ///
  /// Validators are executed for every configuration field write and can
  /// reject values by returning [String] which throws [EzValidationException].
  static void validation(EzGlobalValidator validator)
    => _validators.add(validator);

  /// Registers the available values for the enum type [E].
  ///
  /// The provided values are used to resolve serialized enum values back into
  /// their corresponding enum instances.
  static void registerEnum<E extends Enum>(List<E> values)
    => _enums[E] = values;

  /// Whether non-finite numeric values (`NaN` and `Infinity`) should be
  /// preserved during numeric coercion.
  ///
  /// When `false`, non-finite values are replaced with the
  /// field's default value (or `null` if nullable).
  ///
  /// When `true` (default), non-finite values are preserved instead of being replaced.
  /// Note that converting non-finite values to `int`/`double` is not supported.
  static bool preserveNonFiniteNumbers = true;

  late final EzConfigParent? _parent;
  final Map _data;
  final Map<String, EzField> _fields = {};

  /// Creates a configuration backed by [data].
  ///
  /// If [data] is omitted, an empty map is created.
  ///
  /// [_parent] identifies the containing configuration when this instance
  /// represents a nested configuration.
  EzConfig([Map? data]) : _data = data ?? {};

  late final Map<String, dynamic> asMap = _ConfigView(this);

  /// Returns the outermost configuration containing this instance.
  ///
  /// Traverses the parent chain until a configuration without a parent
  /// is reached. If this instance has no parent, returns itself.
  EzConfig getRoot() {
    EzConfig current = this;

    while (current._parent != null) {
      current = current._parent.config;
    }

    return current;
  }

  /// Returns the underlying raw configuration map.
  ///
  /// The returned map is not copied. Modifying it directly bypasses
  /// field validation and the normal serialization process.
  Map getData() => _data;

  /// Returns the parent reference of this configuration, if any.
  EzConfigParent? getParent() => _parent;

  /// Returns a JSON-compatible deep copy of the underlying configuration.
  ///
  /// Serialization is performed through JSON encoding and decoding.
  /// Consequently, values unsupported by JSON serialization will cause
  /// an exception.
  Map toJson() => jsonDecode(jsonEncode(_data));

  /// Writes [value] directly into the raw configuration map under [key].
  ///
  /// If [strict] is `true`, run the registered validators (if any).
  /// 
  /// This operation does NOT bypass normal value serialization process.
  void set(String key, dynamic value, {bool strict = false})
    => _writeField(key, value, strict: strict);

  (dynamic value, bool found) _get(dynamic data, dynamic segment) {
    if (data is Map) return (data[segment], data.containsKey(segment));

    if (data is List) {
      final index = segment is int ? segment : int.tryParse(segment.toString());

      if (index != null && index >= 0 && index < data.length) {
        return (data[index], true);
      }
    }

    return (null, false);
  }

  (dynamic value, bool found) _traverse(List<dynamic> path) {
    dynamic current = _data;
    bool found = true;

    for (final segment in path) {
      final (next, isFound) = _get(current, segment);
      current = next;
      found &= isFound;
    }

    return (current, found);
  }

  /// Traverses the underlying data structure using the given [path].
  ///
  /// Returns the value found at the end of the path, or `null` if the
  /// resolved value is `null` or a segment cannot be found.
  dynamic walk(List<dynamic> path) => _traverse(path).$1;

  dynamic _serialize(dynamic value) => switch (value) {
    EzConfig config => config.getData(),
    Enum e => e.name,
    List list => list.map(_serialize).toList(),
    Map map => map.map((key, value) => .new(key, _serialize(value))),
    _ => value,
  };

  F _regField<F extends EzField>(String key, F field) {
    _fields[key] = field;
    field.set(field._getOrInitial(), strict: strictInitializing);
    return field;
  }

  /// Returns a registered [EzField] based on provided [key], or null.
  EzField? getField(String key) => _fields[key];

  String? _validate(String key, dynamic value) {
    for (final v in _validators) {
      final error = v(this, key, value);
      if (error != null) return error;
    }
    return _fields[key]?.validate(value);
  }

  void _writeField<X>(String key, X value, {bool strict = false}) {
    if (strict) {
      final error = _validate(key, value);
      if (error != null) throw EzValidationException(key, value, error.isEmpty ? 'invalid' : error);
    }
    _data[key] = _serialize(value);
  }

  /// Returns the full dotted path from the root to [field].
  String getPath(String field) {
    final path = <String>[field];
    EzConfigParent? current = _parent;

    while (current != null) {
      path.insert(0, current.key);
      current = current.config._parent;
    }

    return path.join('.');
  }

  bool _isConfig<T>() => <T>[] is List<EzConfig?>;

  bool _isEnum<T>() => <T>[] is List<Enum?>;

  dynamic _coerceNum<X>(dynamic v, {bool nullable = false}) {
    if (v is num && (X == num || (X == int && v is double) || (X == double && v is int))) {
      if (!v.isFinite) {
        if (preserveNonFiniteNumbers) return v;
        return nullable ? null : _getDefault<X>();
      }

      return switch (X) {
        const (int) => v.toInt(),
        const (double) => v.toDouble(), 
        _ => v,
      };
    }

    return v;
  }

  X _buildConfig<X>(String field, Map value) {
    final factory = _factories[X];
    if (factory == null) throw StateError("Factory for $X was not registered.");
    final config = factory(value);
    config._parent = .new(field, this);
    return config as X;
  }

  X? _findEnum<X>(String name) {
    final values = _enums[X];
    if (values == null) throw StateError("Enum $X was not registered.");
    for (final e in values) {
      if (e.name == name) return e as X;
    }
    return null;
  }

  X _buildEnum<X>(String field, dynamic value) {
    final found = value is String ? _findEnum<X>(value) : null;
    return found ?? _enums[X]!.first as X;
  }

  static T _builtinDefault<T, A>({bool? nullable, EzConfigParent? parent}) {
    if (nullable == true) return null as T;
    if (<A>[] is T) return <A>[] as T;
    if (null is A) return null as T;
    if (_defaults[A] case EzDefault<A> def) return def() as T;
    if (_defaults[T] case EzDefault<T> def) return def();
    if (_factories[A] case EzConfigFactory fac) return fac({}) as T; // NOTE: no need for parent
    if (_factories[T] case EzConfigFactory fac) return fac({}) as T; // NOTE: no need for parent
    if (_enums[A] case List<Enum> values) return values.first as T;
    if (_enums[T] case List<Enum> values) return values.first as T;
    throw StateError("Unhandled type for ($T) ($A).");
  }

  static X _getDefault<X>([dynamic value]) {
    if (value is X) return value;
    if (value == null && null is X) return null as X;
    return _defaults[X]?.call() ?? _builtinDefault<X, X>();
  }

  // ---- single fields ----

  X _readField<X>(String field) {
    final (value, _) = _traverse([field]);
    if (_isConfig<X>()) return _buildConfig<X>(field, value is Map ? value : {});
    if (_isEnum<X>()) return _buildEnum<X>(field, value);
    return _getDefault<X>(_coerceNum<X>(value));
  }

  (bool, X?) _tryReadField<X>(String field) {
    final (value, _) = _traverse([field]);

    if (_isConfig<X>()) {
      if (value is! Map) return (false, null);
      return (true, _buildConfig<X>(field, value));
    }

    if (_isEnum<X>()) {
      if (value is! String || _findEnum<X>(value) == null) return (false, null);
      return (true, _buildEnum<X>(field, value));
    }

    final coerced = _coerceNum<X>(value);
    return coerced is X ? (true, coerced) : (false, null);
  }

  X? _readFieldNull<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return null;
    if (_isConfig<X>()) return value is Map ? _buildConfig<X>(field, value) : null;
    if (_isEnum<X>()) return value is String ? _findEnum<X>(value) : null;
    final v = _coerceNum<X>(value, nullable: true);
    return v is X ? v : null;
  }

  (bool, X?) _tryReadFieldNull<X>(String field) {
    final (value, found) = _traverse([field]);

    if (!found) return (false, null); // missing: let the initializer run
    if (value == null) return (true, null);

    if (_isConfig<X>()) {
      if (value is! Map) return (false, null);
      return (true, _buildConfig<X>(field, value));
    }

    if (_isEnum<X>()) {
      if (value is! String || _findEnum<X>(value) == null) return (false, null);
      return (true, _buildEnum<X>(field, value));
    }

    final v = _coerceNum<X>(value, nullable: true);
    return v is X ? (true, v) : (false, null);
  }

  // ---- lists ----

  List<E>? _decodeList<E, X>(String field, dynamic value) {
    if (value is! List) return null;

    final nullable = null is E;
    final configurable = _isConfig<E>();
    final enum_ = _isEnum<E>();
    final items = <E>[];

    for (final item in value) {
      if (configurable) {
        if (nullable && item is! Map) {
          items.add(null as E);
        } else {
          items.add(_buildConfig<X>(field, item is Map ? item : {}) as E);
        }
        continue;
      }

      if (enum_) {
        final e = item is String ? _findEnum<X>(item) : null;
        items.add(e != null ? e as E : (nullable ? null as E : _buildEnum<X>(field, item) as E));
        continue;
      }

      final v = _coerceNum<X>(item);
      if (v is E) {
        items.add(v);
      } else {
        items.add(nullable ? null as E : _getDefault<E>(v));
      }
    }

    return items;
  }

  List<X> _readList<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return [];
    return _decodeList<X, X>(field, value) ?? _builtinDefault<List<X>, X>();
  }

  List<X?> _readListNull<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return [];
    return _decodeList<X?, X>(field, value) ?? _builtinDefault<List<X?>, X>();
  }

  List<X>? _readNullList<X>(String field)
    => _decodeList<X, X>(field, _traverse([field]).$1);

  List<X?>? _readNullListNull<X>(String field)
    => _decodeList<X?, X>(field, _traverse([field]).$1);

  // Strict: all-or-nothing, no default-filling. Original `_decodeList` is lenient.
  (bool, List<E>?) _tryDecodeList<E, X>(String field, dynamic value) {
    if (value is! List) return (false, null);

    final nullable = null is E;
    final configurable = _isConfig<E>();
    final enum_ = _isEnum<E>();

    // pass 1: validate only, no side effects
    for (final item in value) {
      if (item == null) {
        if (!nullable) return (false, null);
        continue;
      }
      if (configurable) {
        if (item is! Map) return (false, null);
        continue;
      }
      if (enum_) {
        if (item is! String || _findEnum<X>(item) == null) return (false, null);
        continue;
      }
      if (_coerceNum<X>(item) is! E) return (false, null);
    }

    // pass 2: build, cannot fail now
    final items = <E>[];
    for (final item in value) {
      if (item == null) {
        items.add(null as E);
      } else if (configurable) {
        items.add(_buildConfig<X>(field, item as Map) as E);
      } else if (enum_) {
        items.add(_buildEnum<X>(field, item as String) as E);
      } else {
        items.add(_coerceNum<X>(item) as E);
      }
    }

    return (true, items);
  }

  (bool, List<X>?) _tryReadList<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return (false, null); // missing: let the initializer run
    return _tryDecodeList<X, X>(field, value);
  }

  (bool, List<X?>?) _tryReadListNull<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return (false, null);
    return _tryDecodeList<X?, X>(field, value);
  }

  (bool, List<X>?) _tryReadNullList<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return (false, null);
    if (value == null) return (true, null); // stored null is valid for a nullable list
    return _tryDecodeList<X, X>(field, value);
  }

  (bool, List<X?>?) _tryReadNullListNull<X>(String field) {
    final (value, found) = _traverse([field]);
    if (!found) return (false, null);
    if (value == null) return (true, null);
    return _tryDecodeList<X?, X>(field, value);
  }

  /// Registers and returns a non-nullable field of type [T].
  EzField<T> field<T>(String key, {
    EzFieldValidator<T>? validate,
    EzDefault<T>? initial,
    EzFieldRepair<T>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadField<T>(key),
    get: () => _readField<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<T, T>(),
    initial: initial,
  ));

  /// Registers and returns a nullable field of type [T].
  EzField<T?> fieldNull<T>(String key, {
    EzFieldValidator<T?>? validate,
    EzDefault<T?>? initial,
    EzFieldRepair<T?>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadFieldNull<T>(key),
    get: () => _readFieldNull<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<T?, T?>(nullable: true),
    initial: initial,
  ));

  /// Registers and returns a non-nullable list field containing elements
  /// of type [T].
  EzFieldList<T> list<T>(String key, {
    EzFieldValidator<List<T>>? validate,
    EzDefault<List<T>>? initial,
    EzFieldRepair<List<T>>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadList<T>(key),
    get: () => _readList<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<List<T>, T>(),
    initial: initial,
  ));

  /// Registers and returns a non-nullable list field containing nullable
  /// elements of type [T].
  EzFieldList<T?> listNull<T>(String key, {
    EzFieldValidator<List<T?>>? validate,
    EzDefault<List<T?>>? initial,
    EzFieldRepair<List<T?>>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadListNull<T>(key),
    get: () => _readListNull<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<List<T?>, T>(),
    initial: initial,
  ));

  /// Registers and returns a nullable list field containing non-nullable
  /// elements of type [T].
  EzNullFieldList<T> nullList<T>(String key, {
    EzFieldValidator<List<T>?>? validate,
    EzDefault<List<T>?>? initial,
    EzFieldRepair<List<T>?>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadNullList<T>(key),
    get: () => _readNullList<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<List<T>?, T>(nullable: true),
    initial: initial,
  ));

  /// Registers and returns a nullable list field containing nullable
  /// elements of type [T].
  EzNullFieldList<T?> nullListNull<T>(String key, {
    EzFieldValidator<List<T?>?>? validate,
    EzDefault<List<T?>?>? initial,
    EzFieldRepair<List<T?>?>? recover,
  }) => _regField(key, .new(key,
    validator: validate,
    recover: recover,
    traverseRaw: () => _traverse([key]),
    tryGet: () => _tryReadNullListNull<T>(key),
    get: () => _readNullListNull<T>(key),
    set: (value, {required bool strict}) => _writeField(key, value, strict: strict),
    reset: () => _builtinDefault<List<T?>?, T>(nullable: true),
    initial: initial,
  ));

  /// Resets the specified fields to their default values.
  ///
  /// If [keys] is omitted or `null`, all fields are reset.
  /// Otherwise, only the fields whose keys are provided are reset.
  ///
  /// An empty [keys] list performs no operation.
  ///
  /// Throws a [StateError] if any of the specified keys does not exist.
  void reset([List<String>? keys]) {
    final fields = keys ?? _fields.keys;

    for (final key in fields) {
      final field = _fields[key];

      if (field == null) {
        throw StateError("Field '$key' does not exist.");
      }

      field.reset();
    }
  }

  String _dumpCollection(Iterable<String> items, int level, String open, String close) {
    final buffer = StringBuffer(open);
    final hasItems = items.isNotEmpty;
    if (hasItems) {
      final pad = '  ' * level;
      buffer.write('\n');
      buffer.writeAll(items.map((i) => '$pad$i,\n'));
      buffer.write('  ' * (level - 1));
    }
    buffer.write(close);
    return buffer.toString();
  }

  String _dumpValue(dynamic value, int level) {
    return switch (value) {
      EzConfig config => config._dump(level + 1),
      Enum e => e.name,
      String string => jsonEncode(string),
      List list => _dumpList(list, level + 1),
      _ => value.toString(),
    };
  }

  String _dumpList(List value, int level) => _dumpCollection(
    value.map((item) => _dumpValue(item, level)),
    level, '[', ']',
  );

  String _dump([int level = 1]) => _dumpCollection(
    _fields.entries.map((f) => '${f.key} = ${_dumpValue(f.value.value, level)}'),
    level, '$runtimeType {', '}',
  );

  /// Returns a formatted, human-readable representation of this configuration.
  ///
  /// Only registered fields are included in the output. Nested configurations
  /// and lists are formatted recursively.
  String dump() => _dump();
}