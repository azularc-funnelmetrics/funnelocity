({
    doInit: function (component) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getMemberProfileUrl');
        action.setParams({ recordId: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var profileUrl = response.getReturnValue();
                if (profileUrl) {
                    var globalId = component.getGlobalId();
                    var frameElem = document.getElementById(globalId + 'memberProfileFrame');
                    if (frameElem) {
                        frameElem.src = profileUrl;
                    }
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (window.console && console.log) {
                    console.log(errors);
                }
            }
        });
        $A.enqueueAction(action);
    }
})