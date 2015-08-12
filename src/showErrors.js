(function() {
  var showErrorsModule;

  showErrorsModule = angular.module('res.showErrors', []);

  showErrorsModule.directive('resShowErrors', [
    '$timeout', 'resShowErrorsConfig', '$interpolate', function($timeout, resShowErrorsConfig, $interpolate) {
      var getErrorClass, getFormControlClass, getShowSuccess, getSkipFormGroupCheck, getTrigger, linkFn;
      getTrigger = function(options) {
        var trigger;
        trigger = resShowErrorsConfig.trigger;
        if (options && (options.trigger != null)) {
          trigger = options.trigger;
        }
        return trigger;
      };
      getShowSuccess = function(options) {
        var showSuccess;
        showSuccess = resShowErrorsConfig.showSuccess;
        if (options && (options.showSuccess != null)) {
          showSuccess = options.showSuccess;
        }
        return showSuccess;
      };
      getErrorClass = function(options) {
        var errorClass;
        errorClass = resShowErrorsConfig.errorClass;
        if (options && (options.errorClass != null)) {
          errorClass = options.errorClass;
        }
        return errorClass;
      };
      getFormControlClass = function(options) {
        var formControlClass;
        formControlClass = resShowErrorsConfig.formControlClass;
        if (options && (options.formControlClass != null)) {
          formControlClass = options.formControlClass;
        }
        return formControlClass;
      };
      getSkipFormGroupCheck = function(options) {
        var skipFormGroupCheck;
        skipFormGroupCheck = resShowErrorsConfig.skipFormGroupCheck;
        if (options.indexOf('skipFormGroupCheck') !== -1) {
          skipFormGroupCheck = true;
        }
        return skipFormGroupCheck;
      };
      linkFn = function(scope, el, attrs, formCtrl) {
        var blurred, errorClass, formControlClass, inputEl, inputName, inputNgEl, options, showSuccess, toggleClasses, trigger;
        blurred = false;
        options = scope.$eval(attrs.resShowErrors);
        showSuccess = getShowSuccess(options);
        trigger = getTrigger(options);
        errorClass = getErrorClass(options);
        formControlClass = getFormControlClass(options);
        inputEl = el[0].querySelector('.' + formControlClass + '[name]');
        inputNgEl = angular.element(inputEl);
        inputName = $interpolate(inputNgEl.attr('name') || '')(scope);
        if (!inputName) {
          throw "show-errors element has no child input elements with a 'name' attribute and a '" + formControlClass + "' class";
        }
        inputNgEl.bind(trigger, function() {
          blurred = true;
          return toggleClasses(formCtrl[inputName].$invalid);
        });
        scope.$watch(function() {
          return formCtrl[inputName] && formCtrl[inputName].$invalid;
        }, function(invalid) {
          if (!blurred) {
            return;
          }
          return toggleClasses(invalid);
        });
        scope.$on('show-errors-check-validity', function() {
          return toggleClasses(formCtrl[inputName].$invalid);
        });
        scope.$on('show-errors-reset', function() {
          return $timeout(function() {
            el.removeClass(errorClass);
            el.removeClass('has-success');
            return blurred = false;
          }, 0, false);
        });
        return toggleClasses = function(invalid) {
          el.toggleClass(errorClass, invalid);
          if (showSuccess) {
            return el.toggleClass('has-success', !invalid);
          }
        };
      };
      return {
        restrict: 'A',
        require: '^form',
        compile: function(elem, attrs) {
          var _skipFormGroupCheck;
          _skipFormGroupCheck = getSkipFormGroupCheck(attrs['resShowErrors']);
          if (!_skipFormGroupCheck) {
            if (!(elem.hasClass('form-group') || elem.hasClass('input-group'))) {
              throw "show-errors element does not have the 'form-group' or 'input-group' class";
            }
          }
          return linkFn;
        }
      };
    }
  ]);

  showErrorsModule.provider('resShowErrorsConfig', function() {
    var _errorClass, _formControlClass, _showSuccess, _skipFormGroupCheck, _trigger;
    _showSuccess = false;
    _trigger = 'blur';
    _errorClass = 'has-error';
    _skipFormGroupCheck = false;
    _formControlClass = 'form-control';
    this.showSuccess = function(showSuccess) {
      return _showSuccess = showSuccess;
    };
    this.trigger = function(trigger) {
      return _trigger = trigger;
    };
    this.errorClass = function(errorClass) {
      return _errorClass = errorClass;
    };
    this.skipFormGroupCheck = function(skipFormGroupCheck) {
      return _skipFormGroupCheck = skipFormGroupCheck;
    };
    this.formControlClass = function(clazz) {
      return _formControlClass = clazz;
    };
    this.$get = function() {
      return {
        showSuccess: _showSuccess,
        trigger: _trigger,
        skipFormGroupCheck: _skipFormGroupCheck,
        errorClass: _errorClass,
        formControlClass: _formControlClass
      };
    };
  });

}).call(this);
