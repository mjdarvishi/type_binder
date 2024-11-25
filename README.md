# TypeBinder
The TypeBindery package simplifies the process of managing multiple types of JSON-serializable classes in Dart. It provides a dynamic, type-based class registry to streamline the conversion of JSON data into Dart objects. This package is especially useful when working with type annotations for schema management, widget building, or deserialization.

By leveraging code generation, this package maps annotated classes to their corresponding fromJson methods automatically. This enables developers to handle different class types dynamically without manually writing extensive boilerplate code.

# Key Features
1. Type-Based Class Registry
Automatically generates a registry that links string type identifiers (via @TypeAnnotation) to their respective fromJson factory constructors.

2. Automatic Code Generation
Utilizes build_runner and source_gen for seamless and efficient code generation.

3. Customizable and Flexible
Any class annotated with @TypeAnnotation is included in the generated registry, making it highly adaptable for various use cases.

## Usage

1. To use this package, you will need the following dependencies in your pubspec.yaml:

```
flutter pub add  schema_registry
```
2. Add type anotation

```dart
@TypeAnnotation('test')
@JsonSerializable()
class TestClass {
TestClass();


factory TestClass.fromJson(Map<String, dynamic> json) =>
_$TestClassFromJson(json);

Map<String, dynamic> toJson() => _$TestClassToJson(this);
}
```

3. Run build runner command for creating registry file
```
 dart run build_runner build
```
4. Use created registery map in factory class

```dart
@JsonSerializable()
class FactoryTestClass {
FactoryTestClass(this.type);

String type;

factory FactoryTestClass.fromJson(Map<String, dynamic> json) {
return registry[json['type']]!(json);
}

Map<String, dynamic> toJson() => _$FactoryTestClassJson(this);
}

```