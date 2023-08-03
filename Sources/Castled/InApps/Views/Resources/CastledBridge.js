class CastledBridge {
    constructor() {
        this.user = new User();
    }

    getUser() {
        return this.user;
    }

    requestImmediateDataFlush()
    {

    }
    showMessage() {  }

    submitForm() {
        var message = { name: document.getElementById('name').value,
            email: document.getElementById('email').value };
        window.webkit.messageHandlers.castled. postMessage(message);

    }
    logClick() {
        var message = 'log click empty';
        window.webkit.messageHandlers.castled. postMessage(message);
    }
    logClick(message,optional_params) {

        const jsonObject = {
            'clickAction'    : 'DEFAULT',
            'message'        : message,
            'params'    : optional_params

        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }

    closeMessage() {
        const jsonObject = {
            'clickAction'    : 'DISMISS_NOTIFICATION'
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    dismissMessage() {
        const jsonObject = {
            'clickAction'    : 'DISMISS_NOTIFICATION'
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    requestPushPermission() {
        const jsonObject = {
            'clickAction'    : 'REQUEST_PUSH_PERMISSION'
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    customAction(optional_params) {
        const jsonObject = {
            'clickAction'  : 'CUSTOM',
            'params'    : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    navigateToScreen(screen_name,optional_params){

        var jsonObject = {
            'clickActionUrl' : screen_name,
            'clickAction'    : 'NAVIGATE_TO_SCREEN',
            'params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    openDeepLink(deeplink_url,optional_params){

        var jsonObject = {
            'clickActionUrl' : deeplink_url,
            'clickAction'    : 'DEEP_LINKING',
            'params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    openRichLanding(richlanding_url,optional_params){

        var jsonObject = {
            'clickActionUrl' : richlanding_url,
            'clickAction'    : 'RICH_LANDING',
            'params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }

    call(mobile_number){

    }
    sms(mobile_number,message){

    }
    share(message){

    }

}

class User {
    constructor() {
        this.email = '';
    }

    setEmail(email) {
        this.email = email;
    }
}
const castledBridge = new CastledBridge();
