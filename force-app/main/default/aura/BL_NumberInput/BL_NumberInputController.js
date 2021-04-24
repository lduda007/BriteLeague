({
    doInit : function(component, event, helper) {
            if (!$A.util.isEmpty(component.get('v.value')) && !$A.util.isUndefinedOrNull(component.get('v.value'))) {
                component.set('v.initialValue', helper.fromModelToView(component, component.get('v.value')));
                component.set('v.viewValue', helper.fromModelToView(component, component.get('v.value')));
                helper.forceMinMax(component, event);
            } else if (!$A.util.isEmpty(component.get('v.default'))) {
                component.set('v.value', component.get('v.default'));
                component.set('v.viewValue', helper.fromModelToView(component, component.get('v.default')));
            }

            component.set('v.oldValue', component.get('v.value'));
            component.set('v.initialClass', component.get('v.class'));
            component.set('v.isInit', false);
            component.set('v.validity', component.find('numberInput').get('v.validity'));
        },

        onModelValueChange : function(component, event, helper) {
            var modelValue = component.get('v.value');
            component.set('v.viewValue', helper.fromModelToView(component, modelValue));
        },

        onViewValueChange : function(component, event, helper) {
            var viewValue, modelValue;
            helper.onViewValueChange(component, event);
            viewValue = helper.trimFloatingZeroes(component.get('v.viewValue')),
            modelValue = helper.fromViewToModel(component, viewValue);
            component.set('v.viewValue', viewValue);
            component.set('v.value', modelValue);
        },

        onShowHelpMessageIfInvalid : function(component, event, helper) {
            var input = component.find('numberInput');
            helper.showErrorIfInvalid(component, event);
        },

        onInternalBlur : function(component, event, helper) {
//            var viewValue = helper.trimFloatingZeroes(component.get('v.viewValue')),
//                modelValue = helper.fromViewToModel(component, viewValue);
//
//            component.set('v.viewValue', viewValue);
//            component.set('v.value', modelValue);

            helper.validateOnBlur(component, event);
            helper.forceMinMax(component, event);
            helper.throwEvent(component, 'onblur');
            helper.showErrorIfInvalid(component, event);
        },

        onInternalChange : function (component, event, helper) {
            helper.throwEvent(component, 'onchange');
        },

        onInternalFocus : function(component, event, helper) {
            helper.throwEvent(component, 'onfocus');
        },

        onRangeChange : function (component, event, helper) {
            if (component.get('v.validateOnRangeChange')) {
                helper.showErrorIfInvalid(component, event);
            }
        },

        onForceErrorChange: function (component, event, helper) {
            helper.showErrorIfInvalid(component, event);
        }
})