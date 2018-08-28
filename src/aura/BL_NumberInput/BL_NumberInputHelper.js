({
    fromModelToView : function(component, value) {
            var fraction = component.get('v.fraction');
            if(fraction && !$A.util.isEmpty(value) && !isNaN(value)) {
                value = Math.round(value * Math.pow(10, fraction)) / Math.pow(10, fraction);
            }

            var val = value == null || value == undefined || $A.util.isUndefinedOrNull(value) ? '' : (value + '');
            return val.replace('.', component.get('v.fractionSeparator'));
        },

        fromViewToModel : function(component, value) {
            var val = (value === null || value === undefined || value === '') ? null : value.replace(component.get('v.fractionSeparator'), '.');
            return $A.util.isUndefinedOrNull(val) || $A.util.isEmpty(val) ? null : parseFloat(val);
        },

        validateViewValue : function (component, event) {
            var oldValue = component.get('v.oldValue'),//event.getParam("oldValue"),
                validatedValue = component.get('v.viewValue');//event.getParam('value');

            if (oldValue != validatedValue) {
                validatedValue = this.validateValue(component, event, oldValue);
                component.set('v.validatedValue', validatedValue);
            }
            component.set('v.oldValue', validatedValue);
            return validatedValue;
        },

        validateInitialViewValue : function (component, event) {
            var initialValue = component.get('v.initialValue'),
                currentValue = component.get('v.viewValue');//event.getParam('value');

            if (!$A.util.isUndefinedOrNull(currentValue) && currentValue.length < initialValue.length) {
                component.set('v.initialValue', currentValue);
                return currentValue;
            }

            return this.validateValue(component, event, initialValue);
        },

        validateValue : function (component, event, value) {
            var integers = component.get('v.integers'),
                fraction = component.get('v.fraction'),
                fractionSeparator = component.get('v.fractionSeparator'),
                min = component.get('v.min'),
                max = component.get('v.max'),
                forceMinMaxOnChange = component.get('v.forceMinMaxOnChange'),
                currentValue = component.get('v.viewValue'),//event.getParam("value"),
                numParts = currentValue ? currentValue.split(/\D/).filter(Boolean) : [];

            if ($A.util.isUndefinedOrNull(currentValue)) {
                return '';
            }

            if (min >= 0 && currentValue.charAt(0) == '-') {
                return value == null ? '' : value;
            }

            if (currentValue.match(/^-?0[0]+/)) {
                return value;
            }

            if (currentValue.match(/^(,|\.)/)) {
                return '0' + fractionSeparator;
            }

            if (currentValue.match(/^-(,|\.)/)) {
                return '-0' + fractionSeparator;
            }

            if (!$A.util.isEmpty(currentValue) && (currentValue.match(/^(-)?[\d]*(\.|,)?([\d]+)?$/) === null)) {
                return this.normalizeFractionSeparator(component, value);
            }

            if (numParts.length > 0 && numParts[0].length > integers) {
                return value;
            }

            if (fraction == 0 && (numParts.length > 1 || currentValue.match(/,|\./))) {
                if (currentValue.charAt(0) == '-') {
                    return '-' + numParts[0];
                }
                return numParts[0];
            }

            if (numParts.length > 1 && numParts[1].length > fraction) {
                return this.normalizeFractionSeparator(component, value);
            }

            if (forceMinMaxOnChange && (parseFloat(currentValue) > max || parseFloat(currentValue) < min)) {
                return value;
            }

            component.set('v.initialValue', '');

            return this.normalizeFractionSeparator(component, currentValue);
        },

        normalizeFractionSeparator : function (component, viewValue) {
            var fractionSeparator = component.get('v.fractionSeparator');

            if ($A.util.isEmpty(viewValue)) {
                return '';
            }

            return viewValue.replace('.', fractionSeparator);
        },

        trimFloatingZeroes : function(viewValue) {

            if ($A.util.isUndefinedOrNull(viewValue) || viewValue === '') {
                return '';
            }

            if ($A.util.isEmpty(viewValue)) {
                return '';
            }

            if (viewValue.match(/^(-)?[0]*(,)?[0]*$/)) {
                return '0';
            }

            if (viewValue.match(/,[1-9]*0+$/)) {
                return viewValue.replace(/,?0+$/, '');
            }

            if (viewValue.match(/[0-9]+,$/)) {
                return viewValue.replace(/,/, '');
            }

            return viewValue;
        },

        validateOnBlur: function (component, event) {
            var viewValue = component.get('v.viewValue'),
                modelValue = this.fromViewToModel(component, viewValue),
                validatedValue = component.get('v.validatedValue');

            if($A.util.isEmpty(validatedValue) && !$A.util.isEmpty(modelValue)) {
                validatedValue = this.fromModelToView(component, modelValue);
            }

            viewValue = this.validateValue(component, event, viewValue);

            if (isNaN(viewValue)) {
                viewValue = $A.util.isEmpty(validatedValue) ? '' : validatedValue;
                modelValue = this.fromViewToModel(component, viewValue);
            }

            if (!$A.util.isEmpty(viewValue)) {
                viewValue = viewValue.trim();
            }

            component.set('v.viewValue', viewValue);
            component.set('v.value', modelValue);
        },

        forceMinMax : function(component, event) {
            var min = component.get('v.min'),
                max = component.get('v.max'),
                isForceMinMax = component.get('v.forceMinMax'),
                value = component.get('v.value');

            if(isForceMinMax) {
                component.set('v.value', value < min ? min : (value > max ? max : value));
            }
        },

        showErrorIfInvalid : function(component, event) {
            var value = component.get('v.value'),
                min = component.get('v.min'),
                max = component.get('v.max'),
                pattern = new RegExp(component.get('v.pattern')),
                input = component.find('numberInput'),
                initialClass = component.get('v.initialClass'),
                overflowMessage = component.get('v.helpMessageWhenRangeOverflow'),
                underflowMessage = component.get('v.helpMessageWhenRangeUnderflow'),
                valueMissingMessage = component.get('v.helpMessageWhenValueMissing'),
                patternMismatchMessage = component.get('v.helpMessageWhenPatternMismatch'),
                messageWhenBadInput = component.get('v.messageWhenBadInput');

                component.set('v.customErrorMessage', '');
                component.set('v.validity', {valid:true, badInput:false, valueMissing:false, patternMismatch:false});
                input.set('v.class', initialClass);


                if (!$A.util.isUndefinedOrNull(max) && value > max) {
                    component.set('v.validity', {valid:false, badInput:true});
                    input.set('v.class', 'slds-has-error ' + initialClass);
                    component.set('v.customErrorMessage', messageWhenBadInput ? messageWhenBadInput : overflowMessage);
                } else if (!$A.util.isUndefinedOrNull(min) && value < min) {
                    component.set('v.validity', {valid:false, badInput:true});
                    input.set('v.class', 'slds-has-error ' + initialClass);
                    component.set('v.customErrorMessage', messageWhenBadInput ? messageWhenBadInput : underflowMessage);
                }

                if ((value === null || value === undefined || value === '') && component.get('v.required') === true) {
                    component.set('v.validity', {valid:false, valueMissing:true});
                    input.set('v.class', 'slds-has-error ' + initialClass);
                    component.set('v.customErrorMessage', valueMissingMessage);
                }

                if (component.get('v.forceError') && messageWhenBadInput) {
                    component.set('v.validity', {valid:false, badInput:true});
                    input.set('v.class', 'slds-has-error ' + initialClass);
                    component.set('v.customErrorMessage', messageWhenBadInput);
                }

                if (!$A.util.isEmpty(value)) {
                    if (!$A.util.isEmpty(pattern) && value.toString().match(pattern) === null) {
                        component.set('v.validity', {valid:false, patternMismatch:true});
                        input.set('v.class', 'slds-has-error ' + initialClass);
                        component.set('v.customErrorMessage', patternMismatchMessage);
                    }
                }
        },

        onViewValueChange : function(component, event) {
            if (!component.get('v.isInit')) {
                if (component.get('v.initialValue')) {
                    component.set('v.viewValue', this.validateInitialViewValue(component, event));
                } else {
                    component.set('v.viewValue', this.validateViewValue(component, event));
                }
            }
        },

        throwEvent: function(component, eventName) {
            var action = component.get('v.' + eventName);

            if (action != null){
                component.set('v.' + eventName + 'Helper', component.get('v.' + eventName + 'Helper') + 1);
            }
        }
})