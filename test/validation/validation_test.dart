import 'package:test/test.dart';

import '../../bin/winter/winter.dart';
import 'models.dart';

late ValidationService vs;

void main() {
  setUpAll(() {
    // Global config for all tests
    vs = ValidationServiceImpl();
  });

  test('Class Level Validation - Tool', () async {
    Tool object = Tool(name: 'hammer');

    List<ConstrainViolation> violations = vs.validate(object);

    expect(violations.length, 1); //custom tool (not a hammer)
  });

  test('Field Level validation - Address', () async {
    Address address = Address(
      streetName: '',
      houseNumber: null,
    );
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'root.streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.houseNumber',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Custom baseName - Address', () async {
    ValidationService vs = ValidationServiceImpl(baseName: 'this');
    Address address = Address(
      streetName: '',
      houseNumber: null,
    );
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'this.streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'this.houseNumber',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Custom field separator - Address', () async {
    ValidationService vs = ValidationServiceImpl(defaultFieldSeparator: ' -> ');
    Address address = Address(
      streetName: '',
      houseNumber: null,
    );
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'root -> streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root -> houseNumber',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Naming Strategy - Address', () async {
    Address address = Address(
      streetName: '',
      houseNumber: null,
    );
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'root.streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.houseNumber',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Naming Strategy + Custom field separator + Custom baseName - Address',
      () async {
    ValidationService vs = ValidationServiceImpl(
      baseName: 'this',
      defaultFieldSeparator: ' -> ',
      namingStrategy: NamingStrategies.snakeCase,
    );
    Address address = Address(
      streetName: '',
      houseNumber: null,
    );
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'this -> street_name',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'this -> house_number',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Field Level Validation - Car', () async {
    Car object = Car(brand: '');

    List<ConstrainViolation> violations = vs.validate(object);

    expect(violations.length, 1);
  });

  test('List - List<Address>', () async {
    List<Address> address = [
      Address(
        streetName: '',
        houseNumber: null,
      ),
      Address(
        streetName: '',
        houseNumber: 456,
      ),
      Address(
        streetName: 'Third Street',
        houseNumber: 789,
      )
    ];
    List<ConstrainViolation> violations = vs.validate(address);
    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'root[0].streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root[0].houseNumber',
        message: 'Value can\'t be null',
      ),
      ConstrainViolation(
        value: '',
        fieldName: 'root[1].streetName',
        message: 'Text can\'t be empty',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Map - Map<Address>', () async {
    Map<String, Address> address = {
      'first': Address(
        streetName: '',
        houseNumber: null,
      ),
      'second': Address(
        streetName: '',
        houseNumber: 456,
      ),
      'third': Address(
        streetName: 'Third Street',
        houseNumber: 789,
      ),
    };
    List<ConstrainViolation> violations = vs.validate(address);

    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: '',
        fieldName: 'root[first].streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root[first].houseNumber',
        message: 'Value can\'t be null',
      ),
      ConstrainViolation(
        value: '',
        fieldName: 'root[second].streetName',
        message: 'Text can\'t be empty',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Full object - User', () async {
    User object = User(
      userName: null,
      userId: 0,
      duration: Duration(days: 365),
      isActive: true,
      addresses: [
        Address(
          streetName: '',
          houseNumber: null,
        ),
        Address(
          streetName: 'Second Street',
          houseNumber: 456,
        ),
      ],
      singleAddress: Address(
        streetName: null,
        houseNumber: 789,
      ),
      additionalAttributes: {
        'key1': 'value1',
        'key2': 42,
        'key3': Address(
          streetName: null,
          houseNumber: null,
        ),
      },
    );

    List<ConstrainViolation> violations = vs.validate(object);

    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: 'User{userName: null, userId: 0}',
        fieldName: 'root',
        message: 'Can\'t have a cero id',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.userName',
        message: 'Value can\'t be null',
      ),
      ConstrainViolation(
        value: '',
        fieldName: 'root.addresses[0].streetName',
        message: 'Text can\'t be empty',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.addresses[0].houseNumber',
        message: 'Value can\'t be null',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.singleAddress.streetName',
        message: 'Error validating field',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.additionalAttributes[key3].streetName',
        message: 'Error validating field',
      ),
      ConstrainViolation(
        value: null,
        fieldName: 'root.additionalAttributes[key3].houseNumber',
        message: 'Value can\'t be null',
      ),
    ];

    expect(violations, correctValidations);
  });

  test('Custom validation - Laptop', () async {
    Laptop object = Laptop(gbSpace: 256, ram: 16);

    List<ConstrainViolation> violations = vs.validate(object);

    List<ConstrainViolation> correctValidations = [
      ConstrainViolation(
        value: object,
        fieldName: 'root',
        message: 'need more ram',
      ),
      ConstrainViolation(
        value: 256,
        fieldName: 'root.hard_drive_space',
        message: 'need more hd space',
      ),
    ];

    expect(violations, correctValidations);
  });
}
