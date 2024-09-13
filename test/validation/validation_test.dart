import 'package:test/test.dart';

import '../../bin/winter/winter.dart';
import 'models.dart';

void main() {
  setUpAll(() {});

  //---------- Object via Serializable----------\\
  test('Serialize/Deserialize - Tool', () async {
    Tool object = Tool(name: '');
    ValidationService vs = ValidationService();

    List<ConstrainViolation> violations = vs.validate(object);

    expect(violations.length, 1);
  });
}
