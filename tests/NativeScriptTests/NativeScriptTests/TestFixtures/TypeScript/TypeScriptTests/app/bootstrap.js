var __extends = this.__extends || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};

var MyObject = (function (_super) {
    __extends(MyObject, _super);
    function MyObject() {
        _super.apply(this, arguments);
    }
    MyObject.prototype.getSomeString = function () {
        return "some string";
    };
    MyObject.prototype.description = function () {
        return "Overriden description";
    };
    return MyObject;
})(NSObject);


var TSExtension = (function (_super) {
    __extends(TSExtension, _super);
    function TSExtension(value) {
        _super.call(this, value);
    }
    TSExtension.prototype.divideTo = function (num1, num2) {
        return 42;
    };
    TSExtension.prototype.superDivideTo = function (num1, num2) {
        return _super.prototype.divideTo.call(this, num1, num2);
    };
    TSExtension.prototype.superDescription = function () {
        return _super.prototype.description.call(this);
    };
    return TSExtension;
})(TNSTypeScript);


// Perform Tests

(function When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance() {

    console.log("TEST: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance");

    var myObj = new MyObject();

    var isInstanceOf = myObj instanceof MyObject;
    assert(isInstanceOf === true, "FAILED: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance. Should be instance of MyObject");

    isInstanceOf = myObj instanceof NSObject;
    assert(isInstanceOf === true, "FAILED: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance.Should be instance of NSObject");
})();


(function When_creating_a_typescript_instance_with_arguments_it_should_be_a_valid_nativescript_instance() {

    console.log("TEST: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance");

    var tsExt = new TSExtension(5);

    var isInstanceOf = tsExt instanceof TSExtension;
    assert(isInstanceOf === true, "FAILED: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance. Should be instance of TSExtension");

    isInstanceOf = tsExt instanceof TNSTypeScript;
    assert(isInstanceOf === true, "FAILED: When_creating_a_typescript_instance_it_should_be_a_valid_nativescript_instance.Should be instance of com.tns.tests.TNSTypeScript");
})();


(function When_creating_a_typescript_instance_it_should_support_member_access() {

    console.log("TEST: When_creating_a_typescript_instance_it_should_support_member_access");

    // Access method
    var obj = new MyObject();
    var someString = obj.getSomeString();
    assert(someString == "some string", "FAILED: When_creating_a_typescript_instance_it_should_support_member_access. Method access failed.");

    // Access method with arguments
    var tsExt = new TSExtension(9);
    var multiplyResult = tsExt.multiplyWith(8, 7);
    assert(multiplyResult === 56, "FAILED: When_creating_a_typescript_instance_it_should_support_member_access. multiplyWith access failed.");

    // Access property
    var tnsExt = new TSExtension(7);
    var value = tnsExt.intValue;
    assert(value === 7, "FAILED: When_creating_a_typescript_instance_it_should_support_member_access. Property access failed.");
})();


(function When_creating_a_typescript_instance_it_should_support_overriden_members() {

    console.log("TEST: When_creating_a_typescript_instance_it_should_support_overriden_members");

    var copyCalled = false;
    MyObject.prototype.copy = function () {
        copyCalled = true;
    };

    (new MyObject()).copy();
    assert(copyCalled === true, "FAILED: When_creating_a_typescript_instance_it_should_support_overriden_members. copy not called.");

    var obj = new MyObject();
    var description = obj.description();
    assert(description === "Overriden description", "FAILED: When_creating_a_typescript_instance_it_should_support_overriden_members. description not called.");

    var tsExt = new TSExtension(9);
    var divideResult = tsExt.divideTo(10, 2);
    assert(divideResult === 42, "FAILED: When_creating_a_typescript_instance_it_should_support_overriden_members. divideTo not called.");
})();


(function When_creating_a_typescript_instance_it_should_support_calling_super_members_from_overriden_members() {

    console.log("TEST: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_overriden_members");

    TSExtension.prototype.getSuperDescription = function () {
        return this.super.description();
    };

    var tsExt = new TSExtension(10);
    var superDescription1 = tsExt.getSuperDescription();
    var superDescription2 = tsExt.superDescription();
    assert(superDescription1 === "TNSTypeScript 10", "FAILED: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_overriden_members. Super call 1.");
    assert(superDescription2 === "TNSTypeScript 10", "FAILED: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_overriden_members. Super call 2.");

    var superDivideResult = tsExt.superDivideTo(18, 4);
    assert(superDivideResult === 4, "FAILED: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_overriden_members. Super call 3.");
})();


(function When_creating_a_typescript_instance_it_should_support_calling_super_members_from_super_prototype() {

  console.log("TEST: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_super_prototype");

    TSExtension.prototype.description = function () {
        return (this.intValue.toString() + " " + this.super.description());
    };

    var tsExt = new TSExtension(9);
    var desc = tsExt.description();
    assert(desc === "9 TNSTypeScript 9", "FAILED: When_creating_a_typescript_instance_it_should_support_calling_super_members_from_super_prototype");
})();


(function When_extending_an_already_extended_object_it_should_throw_an_error() {

  console.log("TEST: When_extending_an_already_extended_object_it_should_throw_an_error");
  console.log('--------------------: ' + MyObject.__extended);
  var errorThrown = false;
  try {
    var SecondObject = (function (_super) {
        __extends(SecondObject, _super);

        function SecondObject() {
            _super.apply(this, arguments);
        }

        return SecondObject;
    })(MyObject);
  } catch (err){
    errorThrown = true;
    assert(err.name === "TNSNativeError");
    assert(err.message === "Only one level of inheritance is supported for native interfaces.");
  }

  assert(errorThrown === true, "FAILED: When_extending_an_already_extended_object_it_should_throw_an_error.");
})();

(function When_extending_a_regular_function_it_should_not_throw_an_error() {

  console.log("TEST: When_extending_a_regular_function_it_should_not_throw_an_error");

  var MyRegularFunction = function() {};
  try {
    var SecondObject = (function (_super) {
        __extends(SecondObject, _super);

        function SecondObject() {
            _super.apply(this, arguments);
        }

        return SecondObject;
    })(MyRegularFunction);
  } catch (err){
        assert(false, "FAILED: When_extending_a_regular_function_it_should_not_throw_an_error. Error should not be thrown.");
  }
})();


TNSTLog("tests passed");
