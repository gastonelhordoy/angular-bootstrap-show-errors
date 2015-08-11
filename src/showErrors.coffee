showErrorsModule = angular.module('res.showErrors', [])

showErrorsModule.directive 'resShowErrors',
['$timeout', 'resShowErrorsConfig', '$interpolate', ($timeout, resShowErrorsConfig, $interpolate) ->

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

    linkFn = (scope, el, attrs, formCtrl) ->
      blurred = false
      options = scope.$eval attrs.resShowErrors
      showSuccess = getShowSuccess options
      trigger = getTrigger options
      errorClass = getErrorClass options

      inputEl   = el[0].querySelector '.form-control[name]'
      inputNgEl = angular.element inputEl
      inputName = $interpolate(inputNgEl.attr('name') || '')(scope)
      unless inputName
        throw "show-errors element has no child input elements with a 'name' attribute and a 'form-control' class"

      inputNgEl.bind trigger, ->
        blurred = true
        toggleClasses formCtrl[inputName].$invalid

      scope.$watch ->
        formCtrl[inputName] && formCtrl[inputName].$invalid
      , (invalid) ->
        return if !blurred
        toggleClasses invalid

      scope.$on 'show-errors-check-validity', ->
        toggleClasses formCtrl[inputName].$invalid

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
        if attrs['resShowErrors'].indexOf('skipFormGroupCheck') == -1
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

  @showSuccess = (showSuccess) ->
    _showSuccess = showSuccess

  @trigger = (trigger) ->
    _trigger = trigger

  @errorClass = (errorClass) ->
    _errorClass = errorClass

  @skipFormGroupCheck = (skipFormGroupCheck) ->
    _skipFormGroupCheck = skipFormGroupCheck

  @$get = ->
    showSuccess: _showSuccess
    trigger: _trigger
    skipFormGroupCheck: _skipFormGroupCheck
    errorClass: _errorClass

  return
