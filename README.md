# clef-node

A Python wrapper for the [Clef](https://getclef.com/) API. Authenticate a user and access their information in two lines of code. 

## Installation

Install using npm:        

 ```
 npm install clef
 ```

## Getting Started

The Clef API lets you retrieve information about a user after they log in to your site with Clef. 

### Get your API credentials

[Create a Clef application](http://docs.getclef.com/v1.0/docs/creating-a-clef-application) to get your App ID and App secret.

### Add the Clef button

The [Clef button](http://docs.getclef.com/v1.0/docs/adding-the-clef-button) has a `data-redirect-url`, which is where you'll be interacting with the Clef API.

## Usage

### Logging in a user

When a user logs in with Clef, the browser will redirect to your `data-redirect-url`. To retrieve user information, call `getLoginInformation` in that endpoint: 

``` 
var clef = require('clef').initialize({
    appID: YOUR_APP_ID,
    appSecret: YOUR_APP_SECRET
});

# In your redirect URL route: 
var code = req.query.code;
clef.getLoginInformation({code: code}, function(err, userInformation) {
    if (err) {
        // Handle the error
    } else {
        var clefID = userInformation['clef_id'];
    }
});
```

For what to do after getting user information, check out our documentation on
[Associating users](http://docs.getclef.com/v1.0/docs/persisting-users).

#### Logging out a user

When you configure your Clef integration, you can also set up a logout hook URL. Clef sends a POST to this URL whenever a user logs out with Clef, so you can log them out on your website too.

```
var clef = require('clef').initialize({
    appID: YOUR_APP_ID,
    appSecret: YOUR_APP_SECRET
});

# In your logout hook route:
var logoutToken = req.body['logout_token']
clef.getLogoutInformation({logoutToken: logoutToken}, function(err, clefID) {
    // log the user out
});
```

For what to do after getting a user who's logging out's `clef_id`, see our
documentation on [Database
logout](http://docs.getclef.com/v1.0/docs/database-logout).


## Resources

Check out the [API docs](http://docs.getclef.com/v1.0/docs/).     
Access your [developer dashboard](https://getclef.com/user/login).
