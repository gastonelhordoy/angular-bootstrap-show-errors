showErrorsModule = angular.module('res.showErrors', [])

showErrorsModule.directive 'resShowErrors',
['$log', '$timeout', 'resShowErrorsConfig', '$interpolate', ($log, $timeout, resShowErrorsConfig, $interpolate) ->

    getTrigger = (options) ->
      trigger = resShowErrorsConfig.trigger
      if options && options.trigger?
        trigger = options.trigger
      trigger

    getShowSuccess = (options) ->
      showSuccess = resShowErrorsConfig.showSuccess
      if options && options.showSuccess?
        showSuccess = options.showSuccess
      showSuccess

    getErrorClass = (options) ->
      errorClass = resShowErrorsConfig.errorClass
      if options && options.errorClass?
        errorClass = options.errorClass
      errorClass

    getFormControlClass = (options) ->
      formControlClass = resShowErrorsConfig.formControlClass
      if options && options.formControlClass?
        formControlClass = options.formControlClass
      formControlClass

    getSkipFormGroupCheck = (options) ->
      skipFormGroupCheck = resShowErrorsConfig.skipFormGroupCheck
      if options.indexOf('skipFormGroupCheck') != -1
        skipFormGroupCheck = true
      skipFormGroupCheck


    linkFn = (scope, el, attrs, formCtrl) ->
      blurred = false
      options = scope.$eval attrs.resShowErrors
      showSuccess = getShowSuccess options
      trigger = getTrigger options
      errorClass = getErrorClass options
      formControlClass = getFormControlClass options

      inputEl   = el[0].querySelector '.' + formControlClass + '[name]'
      inputNgEl = angular.element inputEl
      inputName = $interpolate(inputNgEl.attr('name') || '')(scope);

      unless inputName
        $log.warn "show-errors element has no child input elements with a 'name' attribute and a '" + formControlClass + "' class"

      inputNgEl.bind trigger, ->
        blurred = true
        inputName = $interpolate(inputNgEl.attr('name') || '')(scope)
        toggleClasses formCtrl[inputName].$invalid

      scope.$watch ->
        formCtrl[inputName] && formCtrl[inputName].$invalid
      , (invalid) ->
        return if !blurred
        toggleClasses invalid

      scope.$on 'show-errors-check-validity', ->
        inputName = $interpolate(inputNgEl.attr('name') || '')(scope)
        toggleClasses formCtrl[inputName].$invalid
        blurred = true

      scope.$on 'show-errors-reset', ->
        $timeout ->
          # want to run this after the current digest cycle
          el.removeClass errorClass
          el.removeClass 'has-success'
          blurred = false
        , 0, false

      toggleClasses = (invalid) ->
        el.toggleClass errorClass, invalid
        if showSuccess
          el.toggleClass 'has-success', !invalid

    {
      restrict: 'A'
      require: '^form'
      compile: (elem, attrs) ->
        _skipFormGroupCheck = getSkipFormGroupCheck attrs['resShowErrors']
        if !_skipFormGroupCheck
          unless elem.hasClass('form-group') or elem.hasClass('input-group')
            throw "show-errors element does not have the 'form-group' or 'input-group' class"
        linkFn
    }
]

showErrorsModule.provider 'resShowErrorsConfig', ->
  _showSuccess = false
  _trigger = 'blur'
  _errorClass = 'has-error'
  _skipFormGroupCheck = false
  _formControlClass = 'form-control'

  @showSuccess = (showSuccess) ->
    _showSuccess = showSuccess

  @trigger = (trigger) ->
    _trigger = trigger

  @errorClass = (errorClass) ->
    _errorClass = errorClass

  @skipFormGroupCheck = (skipFormGroupCheck) ->
    _skipFormGroupCheck = skipFormGroupCheck

  @formControlClass = (clazz) ->
    _formControlClass = clazz

  @$get = ->
    showSuccess: _showSuccess
    trigger: _trigger
    skipFormGroupCheck: _skipFormGroupCheck
    errorClass: _errorClass
    formControlClass: _formControlClass

  return
