var clef = require('./clef').initialize({
    appID: '6f8fb6e642924a5e9e7deacf35292abf', 
    appSecret: '27788a6c0934331258651af709813ba2'
});

clef.getLoginInformation({code: 'code_123456789'}, function(err, info) {
    if (err) {
        switch(err.type) {
            case 'InvalidAppIDError': 
                console.log('I must have a typo in my app ID.');
                break;
            case 'InvalidAppSecretError': 
                console.log('I must have a typo in my app secret.');
                break;
            case 'InvalidOAuthCodeError':
                console.log('I must have a bad OAuth code.');
                break;
            case 'InvalidOAuthTokenError': 
                console.log('The Clef library must not be exchanging the OAuth token correctly.');
                break;
            default:
                console.log('There must have been some other error');
                console.log(err);
        } 
    } else {
        var clefID = info['clef_id']
    }
});

clef.getLogoutInformation({logoutToken: 'a logout token'}, function(err, clefID) {
    if (err) {
        console.log(err);
    } else {
        console.log(clefID);
    }
});


