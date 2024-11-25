import 'package:build/build.dart';
import 'package:glob/glob.dart';

Builder registryBuilder(BuilderOptions options) => RegistryBuilder();

class RegistryBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$lib$': ['registry.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final annotatedExports = buildStep.findAssets(Glob('**/*.exports'));
    final registryEntries = <String>[];
    final imports = <String>{};

    await for (final exportFile in annotatedExports) {
      final annotatedClasses = await buildStep.readAsString(exportFile);
      final classes = annotatedClasses.split('\n');

      for (var classInfo in classes) {
        final parts = classInfo.split(',');
        if (parts.length == 3) {
          final typeString = parts[0]; // Use typeString as the key
          final className = parts[1];
          final importPath = parts[2];

          // Add import if not already present
          imports.add("import '$importPath';");

          // Map type string to the `fromJson` method of each class
          registryEntries.add("'$typeString': $className.fromJson,");
        }
      }
    }

    if (registryEntries.isNotEmpty) {
      final content = '''
      // GENERATED CODE - DO NOT MODIFY BY HAND
      // Registry mapping for annotated classes

      ${imports.join('\n')}

      final Map<String, Function> registry = {
        ${registryEntries.join('\n')}
      };
      ''';

      await buildStep.writeAsString(
          AssetId(buildStep.inputId.package, 'lib/registry.dart'), content);
    }
  }
}