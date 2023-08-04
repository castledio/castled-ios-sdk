class CastledBridge {

    dismissMessage(optional_params) {
        const jsonObject = {
            'clickAction'    : 'DISMISS_NOTIFICATION',
            'custom_params'    : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    navigateToScreen(screen_name,optional_params){

        var jsonObject = {
            'clickActionUrl' : screen_name,
            'clickAction'    : 'NAVIGATE_TO_SCREEN',
            'custom_params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    openDeepLink(deeplink_url,optional_params){

        var jsonObject = {
            'clickActionUrl' : deeplink_url,
            'clickAction'    : 'DEEP_LINKING',
            'custom_params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    openRichLanding(richlanding_url,optional_params){

        var jsonObject = {
            'clickActionUrl' : richlanding_url,
            'clickAction'    : 'RICH_LANDING',
            'custom_params'          : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }
    requestPushPermission(optional_params) {
        const jsonObject = {
            'clickAction'    : 'REQUEST_PUSH_PERMISSION',
            'custom_params'    : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }

    customAction(optional_params) {
        const jsonObject = {
            'clickAction'  : 'CUSTOM',
            'custom_params'    : optional_params
        };
        window.webkit.messageHandlers.castled. postMessage(jsonObject);
    }

}

const castledBridge = new CastledBridge();
