import 'package:build/build.dart';
import 'package:schema_registry/annotation.dart';
import 'package:source_gen/source_gen.dart';

Builder typeAnnotationLocatingBuilder(BuilderOptions options) => TypeAnnotationLocatingBuilder();

class TypeAnnotationLocatingBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.dart': ['.exports']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final lib = LibraryReader(await buildStep.inputLibrary);
    final typeAnnotationChecker = TypeChecker.fromRuntime(TypeAnnotation);

    final annotatedClasses = <String>[];

    for (var classElement in lib.classes) {
      // Iterate over all metadata annotations on the class
      for (var annotation in classElement.metadata) {
        final constantValue = annotation.computeConstantValue();

        // Check if this metadata is a TypeAnnotation
        if (constantValue != null && typeAnnotationChecker.isExactlyType(constantValue.type!)) {
          final typeString = constantValue.getField('type')?.toStringValue();

          if (typeString != null) {
            // Capture each type string for the class
            annotatedClasses.add('$typeString,${classElement.name},${buildStep.inputId.uri}');
          }
        }
      }
    }

    if (annotatedClasses.isNotEmpty) {
      await buildStep.writeAsString(
          buildStep.inputId.changeExtension('.exports'),
          annotatedClasses.join('\n')
      );
    }
  }
}