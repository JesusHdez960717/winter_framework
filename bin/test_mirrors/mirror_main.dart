import 'dart:mirrors';

void main() async {
  MyClass clazz = MyClass("super name", 55);

  // Obtener un ClassMirror para la clase 'MyClass'
  var classMirror = reflectClass(MyClass);

  InstanceMirror instanceMirror = reflect(clazz);

  // Obtener las anotaciones de la clase
  var annotations = classMirror.metadata;
  for (var annotation in annotations) {
    if (annotation.reflectee is MyAnnotation) {
      var myAnnotation = annotation.reflectee as MyAnnotation;
      print('Class annotation: ${myAnnotation.description}');
    }
  }

  // Obtener los atributos (campos) de la clase
  var fields = classMirror.declarations.values.whereType<VariableMirror>();
  for (var field in fields) {
    print('Field: ${MirrorSystem.getName(field.simpleName)}, Type: ${field.type}, Value: ${instanceMirror.getField(field.simpleName).reflectee}');
  }

  // Obtener los métodos de la clase
  var methods = classMirror.declarations.values.whereType<MethodMirror>();
  for (var method in methods) {
    if (method.isRegularMethod) {
      print('Method: ${MirrorSystem.getName(method.simpleName)}');
    }
  }
}

class MyAnnotation {
  final String description;

  const MyAnnotation(this.description);
}

@MyAnnotation('This is a test class')
class MyClass {
  String name;
  int age;

  MyClass(this.name, this.age);

  void sayHello() {
    print('Hello, $name!');
  }
}
