import 'package:ezconfig/ezconfig.dart';
import 'package:test/test.dart';

typedef Any = Object?;

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

enum TestEnum { first, second, third }

class NonnullScalarConfig extends EzConfig {
  late final EzField<bool> boolField;
  late final EzField<int> intField;
  late final EzField<double> doubleField;
  late final EzField<String> stringField;

  NonnullScalarConfig([super.data]) {
    boolField = field('boolField');
    intField = field('intField');
    doubleField = field('doubleField');
    stringField = field('stringField');
  }
}

class NullScalarConfig extends EzConfig {
  late final EzField<bool?> boolField;
  late final EzField<int?> intField;
  late final EzField<double?> doubleField;
  late final EzField<String?> stringField;

  NullScalarConfig([super.data]) {
    boolField = fieldNull('boolField');
    intField = fieldNull('intField');
    doubleField = fieldNull('doubleField');
    stringField = fieldNull('stringField');
  }
}

class MySubConfig extends EzConfig {
  MySubConfig([super.data]);
}

class MyBasicConfig extends EzConfig {
  late final EzField<int> id;

  MyBasicConfig([super.data]) {
    id = field('id');
  }
}

/// Used for reset tests (one key per field kind).
class ResetConfig extends EzConfig {
  late final EzField<bool> boolean;
  late final EzField<bool?> booleanNull;
  late final EzField<int> integer;
  late final EzField<int?> integerNull;
  late final EzField<double> dbl;
  late final EzField<double?> dblNull;
  late final EzField<String> string;
  late final EzField<String?> stringNull;
  late final EzField<MyBasicConfig> object;
  late final EzField<MyBasicConfig?> objectNull;
  late final EzList<int> integerList;
  late final EzList<int?> integerNullList;
  late final EzList<Any> anyList;
  late final EzNullList<int> integerListNullable;
  late final EzNullList<int?> integerNullListNullable;
  late final EzNullList<Any> anyListNullable;

  ResetConfig([super.data]) {
    boolean = field('boolean');
    booleanNull = fieldNull('booleanNull');
    integer = field('integer');
    integerNull = fieldNull('integerNull');
    dbl = field('dbl');
    dblNull = fieldNull('dblNull');
    string = field('string');
    stringNull = fieldNull('stringNull');
    object = field('object');
    objectNull = fieldNull('objectNull');
    integerList = list('integerList');
    integerNullList = listNull('integerNullList');
    anyList = list('anyList');
    integerListNullable = nullList('integerListNullable');
    integerNullListNullable = nullListNull('integerNullListNullable');
    anyListNullable = nullList('anyListNullable');
  }
}

class EnumConfig extends EzConfig {
  late final EzField<TestEnum> enumValue;
  late final EzField<TestEnum?> enumNull;
  late final EzList<TestEnum> enumList;
  late final EzList<TestEnum?> enumListNullable;
  late final EzNullList<TestEnum> enumNullList;
  late final EzNullList<TestEnum?> enumNullListNullable;

  final Map<String, dynamic Function()?>? _initials;

  dynamic _initial(String key) => _initials?[key];

  EnumConfig([this._initials, super.data]) {
    enumValue = field('enumValue', initial: _initial('enumValue'));
    enumNull = fieldNull('enumNull', initial: _initial('enumNull'));
    enumList = list('enumList', initial: _initial('enumList'));
    enumListNullable = listNull('enumListNullable', initial: _initial('enumListNullable'));
    enumNullList = nullList('enumNullList', initial: _initial('enumNullList'));
    enumNullListNullable = nullListNull('enumNullListNullable', initial: _initial('enumNullListNullable'));
  }
}

/// Used for "initial value" tests (one key per field kind).
class InitialConfig extends EzConfig {
  late final EzField<bool> boolean;
  late final EzField<bool?> booleanNull;
  late final EzField<int> integer;
  late final EzField<int?> integerNull;
  late final EzField<double> dbl;
  late final EzField<double?> dblNull;
  late final EzField<String> string;
  late final EzField<String?> stringNull;
  late final EzField<MyBasicConfig> object;
  late final EzField<MyBasicConfig?> objectNull;
  late final EzList<int> integerList;
  late final EzList<int?> integerNullList;
  late final EzList<Any> anyList;
  late final EzNullList<int> integerListNullable;
  late final EzNullList<int?> integerNullListNullable;
  late final EzNullList<Any> anyListNullable;
  
  final Map<String, dynamic Function()?>? _initials;

  dynamic _initial(String key) => _initials?[key];

  InitialConfig([this._initials, super.data]) {
    boolean = field('boolean', initial: _initial('boolean'));
    booleanNull = fieldNull('booleanNull', initial: _initial('booleanNull'));
    integer = field('integer', initial: _initial('integer'));
    integerNull = fieldNull('integerNull', initial: _initial('integerNull'));
    dbl = field('dbl', initial: _initial('dbl'));
    dblNull = fieldNull('dblNull', initial: _initial('dblNull'));
    string = field('string', initial: _initial('string'));
    stringNull = fieldNull('stringNull', initial: _initial('stringNull'));
    object = field('object', initial: _initial('object'));
    objectNull = fieldNull('objectNull', initial: _initial('objectNull'));
    integerList = list('integerList', initial: _initial('integerList'));
    integerNullList = listNull('integerNullList', initial: _initial('integerNullList'));
    anyList = list('anyList', initial: _initial('anyList'));
    integerListNullable = nullList('integerListNullable', initial: _initial('integerListNullable'));
    integerNullListNullable = nullListNull('integerNullListNullable', initial: _initial('integerNullListNullable'));
    anyListNullable = nullList('anyListNullable', initial: _initial('anyListNullable'));
  }
}

/// Used for coercion tests (one key per field kind).
class MyConfig extends EzConfig {
  late final EzField<MySubConfig> subConfig;
  late final EzField<MySubConfig?> subConfigNullable;
  late final EzList<MyBasicConfig> basicList;
  late final EzList<MyBasicConfig?> basicListNullable;
  late final EzList<int> intList;
  late final EzList<int?> intListNullable;
  late final EzList<Any> mixedList;

  MyConfig([super.data]) {
    subConfig = field('subConfig');
    subConfigNullable = fieldNull('subConfigNullable');
    basicList = list('basicList');
    basicListNullable = listNull('basicListNullable');
    intList = list('intList');
    intListNullable = listNull('intListNullable');
    mixedList = list('mixedList');
  }
}

/// Used for nested read/write propagation tests (sub configs with content).
class OuterConfig extends EzConfig {
  late final EzField<MyBasicConfig> inner;
  late final EzField<MyBasicConfig?> innerNullable;

  OuterConfig([super.data]) {
    inner = field('inner');
    innerNullable = fieldNull('innerNullable');
  }
}

/// Used for testing nullable lists (values which are either null or list of particular type).
class NullableListConfig extends EzConfig {
  late final EzNullList<int> intList;
  late final EzNullList<int?> intListNullable;
  late final EzNullList<MyBasicConfig> basicList;

  NullableListConfig([super.data]) {
    intList = nullList('intList');
    intListNullable = nullListNull('intListNullable');
    basicList = nullList('basicList');
  }
}

/// Used for testing edge cases
class NumListConfig extends EzConfig {
  late final EzList<int> ints;
  late final EzList<double> doubles;

  NumListConfig([super.data]) {
    ints = list('ints');
    doubles = list('doubles');
  }
}

/// Used for testing edge cases
class SmallConfig extends EzConfig {
  late final EzField<int> id;

  SmallConfig([super.data]) {
    id = field('id');
  }
}

/// Used for testing edge cases
class ListConfig extends EzConfig {
  late final EzList<SmallConfig> smalls;

  ListConfig([super.data]) {
    smalls = list('smalls', initial: () => [.new({'id': 7})]);
  }
}

// ---------------------------------------------------------------------------
// Data helpers
// ---------------------------------------------------------------------------

/// Valid source data for [NonnullScalarConfig].
Map nonnullData() => {
  'boolField': false,
  'intField': 0,
  'doubleField': 0.0,
  'stringField': '',
};

/// Valid source data for [NullScalarConfig]: everything null.
Map nullableData() => {
  'boolField': null,
  'intField': null,
  'doubleField': null,
  'stringField': null,
};

/// Valid source data for [NullableListConfig]: everything null.
Map<String, Object?> nullableListData([Map<String, Object?> overrides = const {}]) => {
  'intList': null,
  'intListNullable': null,
  'basicList': null,
  ...overrides,
};

/// Valid source data for [MyConfig]; [overrides] replace individual keys.
Map myData([Map overrides = const {}]) => {
  'subConfig': <Any, Any>{},
  'subConfigNullable': null,
  'basicList': <Any>[],
  'basicListNullable': <Any>[],
  'intList': <Any>[],
  'intListNullable': <Any>[],
  'mixedList': <Any>[],
  ...overrides,
};

/// Builds a [MyConfig] with [source] at [key] and returns what ends up in
/// `getData()[key]` after coercion.
Any coerced(String key, Object? source)
  => MyConfig(myData({key: source})).getData()[key];

/// Builds a [ResetConfig] with [source] at [key] and returns what ends up in
/// `getData()[key]` after resetting a field at [key].
Any reset(String key, Object? source) {
  final config = ResetConfig({key: source});
  config.getField(key)!.reset();
  return config.getData()[key];
}

/// Builds a [InitialConfig] with [values] and returns what ends up in
/// `getData()[key]` after initialization.
Any initialized(String key, Map<String, Object?>? values, dynamic Function()? initial)
  => InitialConfig({key: initial}, values).getData()[key];

/// Builds a [EnumConfig] with [values] and returns what ends up in
/// `getData()[key]` after initialization.
Any initializedEnum(String key, Map<String, Object?>? values, dynamic Function()? initial)
  => EnumConfig({key: initial}, values).getData()[key];

/// Builds a [NullableListConfig] with [source] at [key] and returns what ends up in
/// `getData()[key]` after coercion.
Object? coercedNullableList(String key, Object? source)
  => NullableListConfig(nullableListData({key: source})).getData()[key];

/// Values that are neither object, list, int, bool, nor string-compatible
/// with whatever the field expects.
final List<Any> notAnObject = ['x', 5, 1.5, true, <Any>[]];
final List<Any> notAList = ['x', 5, 1.5, true, null, <Any, Any>{}];

// ---------------------------------------------------------------------------
// Scalar tests (shared between all four scalar types)
// ---------------------------------------------------------------------------

void scalarTests<T extends Object>({
  required String key,
  required T value,
  required T defaultValue,
  required Object wrong,
  required EzField<T> Function(NonnullScalarConfig) nonnull,
  required EzField<T?> Function(NullScalarConfig) nullable,
}) {
  group('non-nullable', () {
    NonnullScalarConfig make(Map data) => .new(data);

    test('reads initial value', () {
      final config = make({...nonnullData(), key: value});
      expect(nonnull(config).value, value);
    });

    test('write is reflected in getData and leaves other keys alone', () {
      final config = make(nonnullData());
      nonnull(config).value = value;
      expect(config.getData(), {...nonnullData(), key: value});
    });

    test('missing key falls back to default', () {
      final config = make(nonnullData()..remove(key));
      expect(nonnull(config).value, defaultValue);
      expect(config.getData()[key], defaultValue);
    });

    test('null source falls back to default', () {
      final config = make({...nonnullData(), key: null});
      expect(nonnull(config).value, defaultValue);
      expect(config.getData()[key], defaultValue);
    });

    test('wrong-typed source falls back to default', () {
      final config = make({...nonnullData(), key: wrong});
      expect(nonnull(config).value, defaultValue);
      expect(config.getData()[key], defaultValue);
    });
  });

  group('nullable', () {
    NullScalarConfig make(Map data) => .new(data);

    test('reads initial value', () {
      final config = make({...nullableData(), key: value});
      expect(nullable(config).value, value);
    });

    test('write then clear round-trips', () {
      final config = make(nullableData());
      nullable(config).value = value;
      expect(config.getData(), {...nullableData(), key: value});
      nullable(config).value = null;
      expect(config.getData(), nullableData());
    });

    test('missing key reads as null', () {
      final config = make(nullableData()..remove(key));
      expect(nullable(config).value, isNull);
    });

    test('wrong-typed source becomes null', () {
      final config = make({...nullableData(), key: wrong});
      expect(nullable(config).value, isNull);
      expect(config.getData()[key], isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void registerTypes() {
  EzConfig.registerEnum(TestEnum.values);
  EzConfig.register(NonnullScalarConfig.new);
  EzConfig.register(NullScalarConfig.new);
  EzConfig.register(MySubConfig.new);
  EzConfig.register(MyBasicConfig.new);
  EzConfig.register(MyConfig.new);
  EzConfig.register(OuterConfig.new);
  EzConfig.register(NullableListConfig.new);
  EzConfig.register(ListConfig.new);
  EzConfig.register(SmallConfig.new);
}

bool testCustom() {
  // custom specific testing, return `true` and run `dart run test/test.dart`
  return false;
}

void main() {
  registerTypes();
  if (testCustom()) return;

  group('reset', () {
    // <field, (value, expected)>
    final resetTests = <String, (Object?, Object?)>{
      'boolean': (true, false),
      'booleanNull': (true, null),
      'integer': (99, 0),
      'integerNull': (99, null),
      'dbl': (99.0, 0.0),
      'dblNull': (99.0, null),
      'string': ('foo', ''),
      'stringNull': ('foo', null),
      'object': ({'id': 99}, {'id': 0}),
      'objectNull': ({'id': 99}, null),
      'integerList': ([1, 2, 3], []),
      'integerNullList': ([1, null, 3], []),
      'anyList': ([1, true, 'foo'], []),
      'integerListNullable': ([1, 2, 3], null),
      'integerNullListNullable': ([1, null, 3], null),
      'anyListNullable': ([1, true, 'foo'], null),
    };

    for (final resetTest in resetTests.entries) {
      final key = resetTest.key;
      final (value, expected) = resetTest.value;

      test('`$key` expecting `$expected` after reset', () {
        expect(reset(key, value), expected);
      });
    }
  });

  group('initial', () {
    // <test_name, (key, values, expected, init)>
    final initTests = <String, (String, Map<String, Object?>?, Object?, dynamic Function()?)>{
      // existing value, no initializer
      'boolean': ('boolean', {'boolean': false}, false, null),
      'integer': ('integer', {'integer': 99}, 99, null),
      'dbl': ('dbl', {'dbl': 99.0}, 99.0, null),
      'string': ('string', {'string': 'foo'}, 'foo', null),
      'object': ('object', {'object': {'id': 99}}, {'id': 99}, null),
      'integerList': ('integerList', {'integerList': [1, 2, 3]}, [1, 2, 3], null),
      'integerNullList': ('integerNullList', {'integerNullList': [1, null, 3]}, [1, null, 3], null),
      'anyList': ('anyList', {'anyList': [1, true, 'foo']}, [1, true, 'foo'], null),

      // missing value with initializer
      'booleanNull (missing)': ('booleanNull', {}, true, () => true),
      'integerNull (missing)': ('integerNull', {}, 99, () => 99),
      'dblNull (missing)': ('dblNull', {}, 99.0, () => 99.0),
      'stringNull (missing)': ('stringNull', {}, 'foo', () => 'foo'),
      'objectNull (missing)': ('objectNull', {}, {'id': 0}, () => MyBasicConfig()),
      'integerListNullable (missing)': ('integerListNullable', {}, [1, 2, 3], () => [1, 2, 3]),
      'integerNullListNullable (missing)': ('integerNullListNullable', {}, [1, null, 3], () => [1, null, 3]),
      'anyListNullable (missing)': ('anyListNullable', {}, [1, true, 'foo'], () => [1, true, 'foo']),

      // invalid value with initializer
      'booleanNull (invalid)': ('booleanNull', {'booleanNull': 'x'}, true, () => true),
      'integerNull (invalid)': ('integerNull', {'integerNull': 'x'}, 99, () => 99),
      'dblNull (invalid)': ('dblNull', {'dblNull': 'x'}, 99.0, () => 99.0),
      'stringNull (invalid)': ('stringNull', {'stringNull': []}, 'foo', () => 'foo'),
      'objectNull (invalid)': ('objectNull', {'objectNull': 'x'}, {'id': 0}, () => MyBasicConfig()),
      'integerListNullable (invalid)': ('integerListNullable', {'integerListNullable': ['x']}, [1, 2, 3], () => [1, 2, 3]),
      'integerNullListNullable (invalid)': ('integerNullListNullable', {'integerNullListNullable': 'x'}, [1, null, 3], () => [1, null, 3]),
      'anyListNullable (invalid)': ('anyListNullable', {'anyListNullable': 'x'}, [1, true, 'foo'], () => [1, true, 'foo']),

      // existing valid value wins over a non-null initializer
      'string (existing, ignores init)': ('string', {'string': 'foo'}, 'foo', () => 'bar'),
      'integer (existing, ignores init)': ('integer', {'integer': 99}, 99, () => 0),
      'dbl (existing, ignores init)': ('dbl', {'dbl': 99.0}, 99.0, () => 0.0),
      'boolean (existing, ignores init)': ('boolean', {'boolean': false}, false, () => true),
      'stringNull (existing, ignores init)': ('stringNull', {'stringNull': 'foo'}, 'foo', () => 'bar'),
      'object (existing, ignores init)': ('object', {'object': {'id': 99}}, {'id': 99}, () => MyBasicConfig()),
      'integerList (existing, ignores init)': ('integerList', {'integerList': [1, 2, 3]}, [1, 2, 3], () => [9]),
    };

    for (final initTest in initTests.entries) {
      final name = initTest.key;
      final (key, values, expected, init) = initTest.value;

      test('`$name` expecting `$expected` after initialization', () {
        expect(initialized(key, values, init), expected);
      });
    }
  });

  group('initial (strictness)', () {
    // <test_name, (key, values, expected, init)>
    final tests = <String, (String, Map<String, Object?>?, Object?, dynamic Function()?)>{
      // lists are all-or-nothing: one bad element sends the whole list to the initializer
      'integerList (bad element)': ('integerList', {'integerList': [1, 'x', 3]}, [9], () => [9]),
      'integerList (null element)': ('integerList', {'integerList': [1, null, 3]}, [9], () => [9]),
      'integerNullList (bad element)': ('integerNullList', {'integerNullList': [1, 'x', null]}, [9], () => [9]),
      'integerNullList (null elements are valid)': ('integerNullList', {'integerNullList': [1, null, 3]}, [1, null, 3], () => [9]),
      'integerListNullable (bad element)': ('integerListNullable', {'integerListNullable': [1, 'x']}, [9], () => [9]),
      'integerNullListNullable (bad element)': ('integerNullListNullable', {'integerNullListNullable': [1, 'x']}, [9], () => [9]),

      // stored null: valid for nullable kinds (wins over init), invalid otherwise
      'integerNull (stored null)': ('integerNull', {'integerNull': null}, null, () => 99),
      'stringNull (stored null)': ('stringNull', {'stringNull': null}, null, () => 'foo'),
      'objectNull (stored null)': ('objectNull', {'objectNull': null}, null, () => MyBasicConfig()),
      'integerListNullable (stored null)': ('integerListNullable', {'integerListNullable': null}, null, () => [9]),
      'integerNullListNullable (stored null)': ('integerNullListNullable', {'integerNullListNullable': null}, null, () => [9]),
      'integer (stored null)': ('integer', {'integer': null}, 99, () => 99),
      'integerList (stored null)': ('integerList', {'integerList': null}, [9], () => [9]),

      // wrong container type
      'integerList (not a list)': ('integerList', {'integerList': 'x'}, [9], () => [9]),
      'integerList (map instead of list)': ('integerList', {'integerList': {'a': 1}}, [9], () => [9]),

      // coercion
      'dbl (int stored)': ('dbl', {'dbl': 99}, 99.0, () => 0.0),

      // invalid without initializer: falls back to the type default
      // (adjust if your defaults differ)
      'integer (invalid, no init)': ('integer', {'integer': 'x'}, 0, null),
      'integerList (invalid, no init)': ('integerList', {'integerList': [1, 'x']}, [1, 0], null),
      'integerNull (invalid, no init)': ('integerNull', {'integerNull': 'x'}, null, null),
    };

    for (final t in tests.entries) {
      final (key, values, expected, init) = t.value;
      test('`${t.key}` expecting `$expected`', () {
        expect(initialized(key, values, init), expected);
      });
    }
  });

  group('initial (enums)', () {
    // <test_name, (key, values, expected, init)>
    final tests = <String, (String, Map<String, Object?>?, Object?, dynamic Function()?)>{
      // valid stored name wins, even over an initializer
      'enum (existing)': ('enumValue', {'enumValue': 'second'}, 'second', null),
      'enum (existing, ignores init)': ('enumValue', {'enumValue': 'second'}, 'second', () => TestEnum.third),
      'enum (existing first value, ignores init)': ('enumValue', {'enumValue': 'first'}, 'first', () => TestEnum.third),

      // missing or invalid goes to the initializer
      'enum (missing, init)': ('enumValue', {}, 'third', () => TestEnum.third),
      'enum (unknown name, init)': ('enumValue', {'enumValue': 'zzz'}, 'third', () => TestEnum.third),
      'enum (wrong case, init)': ('enumValue', {'enumValue': 'SECOND'}, 'third', () => TestEnum.third),
      'enum (index, init)': ('enumValue', {'enumValue': 1}, 'third', () => TestEnum.third),
      'enum (map, init)': ('enumValue', {'enumValue': {'a': 1}}, 'third', () => TestEnum.third),
      'enum (stored null, init)': ('enumValue', {'enumValue': null}, 'third', () => TestEnum.third),

      // no initializer: first value
      'enum (missing, no init)': ('enumValue', {}, 'first', null),
      'enum (unknown name, no init)': ('enumValue', {'enumValue': 'zzz'}, 'first', null),
      'enum (index, no init)': ('enumValue', {'enumValue': 2}, 'first', null),

      // nullable
      'enumNull (existing, ignores init)': ('enumNull', {'enumNull': 'second'}, 'second', () => TestEnum.third),
      'enumNull (stored null wins)': ('enumNull', {'enumNull': null}, null, () => TestEnum.third),
      'enumNull (missing, init)': ('enumNull', {}, 'third', () => TestEnum.third),
      'enumNull (unknown name, init)': ('enumNull', {'enumNull': 'zzz'}, 'third', () => TestEnum.third),
      'enumNull (unknown name, no init)': ('enumNull', {'enumNull': 'zzz'}, null, null),
      'enumNull (missing, no init)': ('enumNull', {}, null, null),

      // lists
      'enumList (existing)': ('enumList', {'enumList': ['second', 'third']}, ['second', 'third'], null),
      'enumList (dynamic list, ignores init)': ('enumList', {'enumList': <Object?>['first', 'second']}, ['first', 'second'], () => [TestEnum.third]),
      'enumList (bad name, init)': ('enumList', {'enumList': ['second', 'zzz']}, ['third'], () => [TestEnum.third]),
      'enumList (index element, init)': ('enumList', {'enumList': ['second', 1]}, ['third'], () => [TestEnum.third]),
      'enumList (null element, init)': ('enumList', {'enumList': ['second', null]}, ['third'], () => [TestEnum.third]),
      'enumList (bad name, no init)': ('enumList', {'enumList': ['second', 'zzz']}, ['second', 'first'], null),
      'enumListNullable (null elements are valid)': ('enumListNullable', {'enumListNullable': ['second', null]}, ['second', null], () => [TestEnum.third]),
      'enumListNullable (bad name, init)': ('enumListNullable', {'enumListNullable': ['second', 'zzz']}, ['third'], () => [TestEnum.third]),
      'enumListNullable (bad name, no init)': ('enumListNullable', {'enumListNullable': ['second', 'zzz']}, ['second', null], null),
      'enumNullListNullable (stored null wins)': ('enumNullListNullable', {'enumNullListNullable': null}, null, () => [TestEnum.third]),
      'enumNullListNullable (missing, init)': ('enumNullListNullable', {}, ['third'], () => [TestEnum.third]),
    };

    for (final t in tests.entries) {
      final (key, values, expected, init) = t.value;
      test('`${t.key}` expecting `$expected`', () {
        expect(initializedEnum(key, values, init), expected);
      });
    }

    test('serializes by name, not index', () {
      final c = EnumConfig();
      c.enumValue.value = .third;
      expect(c.getData()['enumValue'], 'third');
    });

    test('reordering-safe: stored name maps to the same value', () {
      final c = EnumConfig(null, {'enumValue': 'second'});
      expect(c.enumValue.value, TestEnum.second);
    });
  });

  group('config lists', () {
    test('invalid element rejects the whole list and uses the initializer', () {
      final c = ListConfig({'smalls': [{'id': 1}, {'id': 2}, 'x']});
      expect(c.getData(), {'smalls': [{'id': 7}]});
    });

    test('valid stored list wins over the initializer', () {
      final c = ListConfig({'smalls': [{'id': 1}, {'id': 2}]});
      expect(c.getData(), {'smalls': [{'id': 1}, {'id': 2}]});
    });
  });

  group('scalar fields', () {
    group('bool', () {
      scalarTests<bool>(
        key: 'boolField',
        value: true,
        defaultValue: false,
        wrong: 'yes',
        nonnull: (c) => c.boolField,
        nullable: (c) => c.boolField,
      );
    });

    group('int', () {
      scalarTests<int>(
        key: 'intField',
        value: 42,
        defaultValue: 0,
        wrong: '42',
        nonnull: (c) => c.intField,
        nullable: (c) => c.intField,
      );

      group('double source is converted to int', () {
        test('non-nullable, integral value', () {
          final config = NonnullScalarConfig({...nonnullData(), 'intField': 3.0});
          expect(config.intField.value, isA<int>());
          expect(config.intField.value, 3);
          expect(config.getData()['intField'], isA<int>());
        });

        test('nullable, integral value', () {
          final config = NullScalarConfig({...nullableData(), 'intField': 3.0});
          expect(config.intField.value, isA<int>());
          expect(config.intField.value, 3);
          expect(config.getData()['intField'], isA<int>());
        });

        test('non-nullable, fractional value is truncated', () {
          final config = NonnullScalarConfig({...nonnullData(), 'intField': 3.7});
          expect(config.intField.value, 3);
          expect(config.getData()['intField'], 3);
        });

        test('nullable, fractional value is truncated', () {
          final config = NullScalarConfig({...nullableData(), 'intField': 3.7});
          expect(config.intField.value, 3);
          expect(config.getData()['intField'], 3);
        });
      });
    });

    group('double', () {
      scalarTests<double>(
        key: 'doubleField',
        value: 3.14,
        defaultValue: 0.0,
        wrong: '3.14',
        nonnull: (c) => c.doubleField,
        nullable: (c) => c.doubleField,
      );

      group('int source is converted to double', () {
        test('non-nullable', () {
          final config = NonnullScalarConfig({...nonnullData(), 'doubleField': 3});
          expect(config.doubleField.value, isA<double>());
          expect(config.doubleField.value, 3.0);
          expect(config.getData()['doubleField'], isA<double>());
        });

        test('nullable', () {
          final config = NullScalarConfig({...nullableData(), 'doubleField': 3});
          expect(config.doubleField.value, isA<double>());
          expect(config.doubleField.value, 3.0);
          expect(config.getData()['doubleField'], isA<double>());
        });
      });
    });

    group('string', () {
      scalarTests<String>(
        key: 'stringField',
        value: 'foo',
        defaultValue: '',
        wrong: 42,
        nonnull: (c) => c.stringField,
        nullable: (c) => c.stringField,
      );
    });
  });

  group('nested object fields', () {
    group('Field<Sub>', () {
      test('object source is kept', () {
        final config = MyConfig(myData());
        expect(config.subConfig.value, isA<MySubConfig>());
        expect(config.getData()['subConfig'], <Any, Any>{});
      });

      for (final bad in [...notAnObject, null]) {
        test('${bad.runtimeType} source ($bad) is overwritten as object', () {
          expect(coerced('subConfig', bad), <Any, Any>{});
        });
      }

      test('missing key is created as object', () {
        final config = MyConfig(myData()..remove('subConfig'));
        expect(config.getData()['subConfig'], <Any, Any>{});
      });
    });

    group('Field<Sub?>', () {
      test('null source stays null', () {
        final config = MyConfig(myData());
        expect(config.subConfigNullable.value, isNull);
        expect(config.getData()['subConfigNullable'], isNull);
      });

      test('object source is kept', () {
        final config = MyConfig(myData({'subConfigNullable': <Any, Any>{}}));
        expect(config.subConfigNullable.value, isA<MySubConfig>());
        expect(config.getData()['subConfigNullable'], <Any, Any>{});
      });

      for (final bad in notAnObject) {
        test('${bad.runtimeType} source ($bad) is overwritten as null', () {
          expect(coerced('subConfigNullable', bad), isNull);
        });
      }

      test('can be cleared by assigning null', () {
        final config = MyConfig(myData({'subConfigNullable': <Any, Any>{}}));
        config.subConfigNullable.value = null;
        expect(config.getData()['subConfigNullable'], isNull);
      });
    });

    group('data propagation', () {
      OuterConfig make([Map overrides = const {}]) => .new({
        'inner': {'id': 7},
        'innerNullable': null,
        ...overrides,
      });

      test('nested values are readable', () {
        final config = make();
        expect(config.inner.value.id.value, 7);
      });

      test('writes through a nested config show up in the root data', () {
        final config = make();
        config.inner.value.id.value = 9;
        expect(config.getData()['inner'], {'id': 9});
      });

      test('nested defaults are applied for missing sub-keys', () {
        final config = make({'inner': <Any, Any>{}});
        expect(config.inner.value.id.value, 0);
        expect(config.getData()['inner'], {'id': 0});
      });

      test('nullable nested config can be set and cleared', () {
        final config = make();
        config.innerNullable.value = MyBasicConfig({'id': 1});
        expect(config.getData()['innerNullable'], {'id': 1});
        config.innerNullable.value = null;
        expect(config.getData()['innerNullable'], isNull);
      });
    });
  });

  group('list fields', () {
    group('shared behaviour', () {
      const keys = [
        'basicList',
        'basicListNullable',
        'intList',
        'intListNullable',
        'mixedList',
      ];

      for (final key in keys) {
        group(key, () {
          for (final bad in notAList) {
            test('${bad.runtimeType} source ($bad) is overwritten as list', () {
              expect(coerced(key, bad), <Any>[]);
            });
          }

          test('missing key is created as empty list', () {
            final config = MyConfig(myData()..remove(key));
            expect(config.getData()[key], <Any>[]);
          });

          test('empty list is kept', () {
            expect(coerced(key, <Any>[]), <Any>[]);
          });
        });
      }
    });

    group('FieldList<Basic>', () {
      test('valid objects are kept', () {
        final source = [{'id': 1}, {'id': 2}];
        expect(coerced('basicList', source), source);
      });

      test('non-object items (incl. null) are overwritten as objects', () {
        expect(
          coerced('basicList', [{'id': 1}, 'x', null, 5]),
          [ {'id': 1}, {'id': 0}, {'id': 0}, {'id': 0} ],
        );
      });

      test('items are exposed as typed configs', () {
        final config = MyConfig(myData({
          'basicList': [
            {'id': 1},
            {'id': 2},
          ],
        }));
        expect(config.basicList.value.map((e) => e.id.value), [1, 2]);
      });

      test('add is reflected in getData', () {
        final config = MyConfig(myData());
        config.basicList.add(MyBasicConfig({'id': 5}));
        expect(config.getData()['basicList'], [{'id': 5}]);
      });
    });

    group('FieldList<Basic?>', () {
      test('valid objects and nulls are kept', () {
        final source = [
          {'id': 1},
          null,
        ];
        expect(coerced('basicListNullable', source), source);
      });

      // nullable items follow Field<Sub?> semantics (non-object -> null)
      test('non-object, non-null items become null', () {
        expect(
          coerced('basicListNullable', [
            {'id': 1},
            null,
            'x',
            5,
          ]),
          [
            {'id': 1},
            null,
            null,
            null,
          ],
        );
      });
    });

    group('FieldList<int>', () {
      test('valid ints are kept', () {
        expect(coerced('intList', [1, 2, 3]), [1, 2, 3]);
      });

      test('non-int items (incl. null) are overwritten with the default', () {
        expect(coerced('intList', [1, 'x', null, 2.5, true, 3]), [1, 0, 0, 2, 0, 3]);
      });

      test('add is reflected in getData', () {
        final config = MyConfig(myData());
        config.intList.add(5);
        expect(config.getData()['intList'], [5]);
      });

      test('is exposed as typed ints', () {
        final config = MyConfig(myData({'intList': [1, 2, 3]}));
        expect(config.intList.value, [1, 2, 3]);
        expect(config.intList.value.length, 3);
      });
    });

    group('FieldList<int?>', () {
      test('valid ints and nulls are kept', () {
        expect(coerced('intListNullable', [1, null, 3]), [1, null, 3]);
      });

      test('non-int, non-null items become null', () {
        expect(coerced('intListNullable', [1, null, 'x', 2.5]), [1, null, null, 2]);
      });
    });

    group('FieldList<Any>', () {
      test('arbitrary items are kept untouched', () {
        final source = <Any>[
          1,
          'a',
          null,
          2.5,
          true,
          {'x': 1},
          [2, 3],
        ];
        expect(coerced('mixedList', source), source);
      });
    });

    group('nullable list (null or list)', () {
      const keys = ['intList', 'intListNullable', 'basicList'];

      for (final key in keys) {
        group(key, () {
          test('null source stays null', () {
            expect(coercedNullableList(key, null), isNull);
          });

          test('missing key reads as null', () {
            final config = NullableListConfig(nullableListData()..remove(key));
            expect(config.getData()[key], isNull);
          });

          test('empty list is kept', () {
            expect(coercedNullableList(key, <Object?>[]), <Object?>[]);
          });

          // same rule as Field<Sub?>: invalid -> null, not []
          for (final bad in ['x', 5, 1.5, true, <String, Object?>{}]) {
            test('${bad.runtimeType} source ($bad) becomes null', () {
              expect(coercedNullableList(key, bad), isNull);
            });
          }
        });
      }

      test('valid int list is kept', () {
        expect(coercedNullableList('intList', [1, 2, 3]), [1, 2, 3]);
      });

      test('int items are coerced to default, null included', () {
        expect(coercedNullableList('intList', [1, 'x', null]), [1, 0, 0]);
      });

      test('nullable items keep null, invalid become null', () {
        expect(
          coercedNullableList('intListNullable', [1, null, 'x']),
          [1, null, null],
        );
      });

      test('object items are coerced to objects', () {
        expect(
          coercedNullableList('basicList', [
            {'id': 1},
            'x',
            null,
          ]),
          [
            {'id': 1},
            {'id': 0},
            {'id': 0},
          ],
        );
      });

      test('can be cleared and re-set', () {
        final config = NullableListConfig(nullableListData({'intList': [1]}));
        config.intList.value = null;
        expect(config.getData()['intList'], isNull);
        config.intList.value = [4, 5];
        expect(config.getData()['intList'], [4, 5]);
        expect(config.intList.value, [4, 5]);
      });
    });
  });

  group('edge cases', () {
    group('NaN / Infinity into int fields', () {
      final bad = [double.nan, double.infinity, double.negativeInfinity];

      for (final v in bad) {
        test('non-nullable int falls back to default for $v', () {
          late NonnullScalarConfig config;
          expect(
            () => config = NonnullScalarConfig({...nonnullData(), 'intField': v}),
            returnsNormally,
          );
          expect(config.intField.value, 0);
          expect(config.getData()['intField'], 0);
        });

        test('nullable int becomes null for $v', () {
          late NullScalarConfig config;
          expect(
            () => config = NullScalarConfig({...nullableData(), 'intField': v}),
            returnsNormally,
          );
          expect(config.intField.value, isNull);
          expect(config.getData()['intField'], isNull);
        });

        test('int list item falls back to default for $v', () {
          late NumListConfig config;
          expect(
            () => config = NumListConfig({'ints': [1, v, 2], 'doubles': []}),
            returnsNormally,
          );
          expect(config.getData()['ints'], [1, 0, 2]);
        });
      }

      test('double field keeps NaN and Infinity', () {
        final nan = NonnullScalarConfig({...nonnullData(), 'doubleField': double.nan});
        expect(nan.doubleField.value, isNaN);
        final inf = NonnullScalarConfig({...nonnullData(), 'doubleField': double.infinity});
        expect(inf.doubleField.value, double.infinity);
      });
    });

    group('int/double conversion inside lists', () {
      Object? ints(Object? source) =>
        NumListConfig({'ints': source, 'doubles': []}).getData()['ints'];
      Object? doubles(Object? source) =>
        NumListConfig({'ints': [], 'doubles': source}).getData()['doubles'];

      test('FieldList<double> converts int items to double', () {
        final result = doubles([1, 2, 3.5]) as List;
        expect(result, [1.0, 2.0, 3.5]);
        expect(result, everyElement(isA<double>()));
      });

      test('FieldList<int> converts integral double items to int', () {
        final result = ints([1, 3.0, 4.0]) as List;
        expect(result, [1, 3, 4]);
        expect(result, everyElement(isA<int>()));
      });

      test('FieldList<int> truncates fractional double items', () {
        expect(ints([2.9, -2.9]), [2, -2]);
      });

      test('invalid items in numeric lists still use the default', () {
        expect(ints([1, 'x', null]), [1, 0, 0]);
        expect(doubles([1.5, 'x', null]), [1.5, 0.0, 0.0]);
      });
    });

    group('FieldList mutation reaches getData', () {
      final cases = <(String, void Function(EzList<int>), List<int>)>[
        ('add', (l) => l.add(4), [1, 2, 3, 4]),
        ('addAll', (l) => l.addAll([4, 5]), [1, 2, 3, 4, 5]),
        ('insert', (l) => l.insert(0, 0), [0, 1, 2, 3]),
        ('remove', (l) => l.remove(2), [1, 3]),
        ('removeAt', (l) => l.removeAt(0), [2, 3]),
        ('removeLast', (l) => l.removeLast(), [1, 2]),
        ('[]=', (l) => l[1] = 9, [1, 9, 3]),
        ('sort', (l) => l.sort((a, b) => b - a), [3, 2, 1]),
        ('clear', (l) => l.clear(), []),
      ];

      for (final (name, mutate, expected) in cases) {
        test(name, () {
          final config = MyConfig(myData({'intList': [1, 2, 3]}));
          mutate(config.intList);
          expect(config.getData()['intList'], expected);
          expect(config.intList.value, expected);
        });
      }

      test('writing through a list item reaches getData', () {
        final config = MyConfig(myData({
          'basicList': [
            {'id': 1},
            {'id': 2},
          ],
        }));
        config.basicList[1].id.value = 9;
        expect(config.getData()['basicList'], [
          {'id': 1},
          {'id': 9},
        ]);
      });
    });

    group('source map aliasing', () {
      test('two configs built from the same map do mutate the same map', () {
        final source = nonnullData();
        final a = NonnullScalarConfig(source);
        final b = NonnullScalarConfig(source);
        a.intField.value = 5;
        expect(b.intField.value, 5);
        expect(b.getData()['intField'], 5);
        expect(identical(a.getData(), b.getData()), isTrue);
      });

      test('writes do mutate the source map', () {
        final source = nonnullData();
        final config = NonnullScalarConfig(source);
        config.intField.value = 5;
        expect(source, config.getData());
      });
    });

    group('identity stability', () {
      OuterConfig make() => .new({
        'inner': {'id': 7},
        'innerNullable': null,
      });

      test('nested config is the same instance on repeated access', () {
        final config = make();
        expect(identical(config.inner.value.getData(), config.inner.value.getData()), isTrue);
      });

      test('list items are the same instance on repeated access', () {
        final config = MyConfig(myData({
          'basicList': [
            {'id': 1},
          ],
        }));
        expect(identical(config.basicList[0].getData(), config.basicList[0].getData()), isTrue);
      });

      test('writes through a held reference are not lost', () {
        final config = make();
        final held = config.inner.value;
        held.id.value = 9;
        expect(config.inner.value.id.value, 9);
        expect(config.getData()['inner'], {'id': 9});
      });

      test('nested config knows its parent', () {
        final config = make();
        expect(config.inner.value.getParent()?.config, same(config));
      });
    });

    group('unknown keys', () {
      test('top-level unknown keys survive getData', () {
        final config = NonnullScalarConfig({...nonnullData(), 'extra': 'keep'});
        expect(config.getData()['extra'], 'keep');
      });

      test('unknown keys survive writes to other fields', () {
        final config = NonnullScalarConfig({...nonnullData(), 'extra': 'keep'});
        config.intField.value = 5;
        expect(config.getData()['extra'], 'keep');
      });

      test('nested unknown keys survive', () {
        final config = OuterConfig({
          'inner': {'id': 1, 'extra': 'keep'},
          'innerNullable': null,
        });
        expect(config.getData()['inner'], {'id': 1, 'extra': 'keep'});
      });

      test('unknown keys in list items survive', () {
        final config = MyConfig(myData({
          'basicList': [
            {'id': 1, 'extra': 'keep'},
          ],
        }));
        expect(config.getData()['basicList'], [
          {'id': 1, 'extra': 'keep'},
        ]);
      });
    });
  });
}