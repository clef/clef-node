request = require 'request'
errors = require './errors'

MESSAGE_TO_ERROR_MAP =
    'Invalid App ID.': errors.InvalidAppIDError,
    'Invalid App Secret.': errors.InvalidAppSecretError,
    'Invalid App.': errors.InvalidAppError,
    'Invalid OAuth Code.': errors.InvalidOAuthCodeError,
    'Invalid token.': errors.InvalidOAuthTokenError,
    'Invalid logout hook URL.': errors.InvalidLogoutHookURLError,
    'Invalid Logout Token.': errors.InvalidLogoutTokenError

class ClefAPI
    constructor: (opts) ->
        @root = opts['root'] ? 'https://clef.io/api'
        @version = 'v1'

        @appID = opts['appID']
        @appSecret = opts['appSecret']

        @apiBase = "#{@root}/#{@version}"
        @authorizeURL = "#{@apiBase}/authorize"
        @infoURL = "#{@apiBase}/info"
        @logoutURL = "#{@apiBase}/logout"

    @initialize = (opts) ->
        return new ClefAPI(opts)

    sendRequest: (opts, callback) ->
        requestOptions = {}
        requestOptions.url = opts.url
        method = opts.method.toLowerCase()
        if method is 'get'
            requestOptions.qs = opts.params
        else if method is 'post'
            requestOptions.form = opts.params
        request[method] requestOptions, (err, response, body) ->
            try
                jsonBody = JSON.parse(body ? null)
            catch jsonParseError
                return callback(new errors.ParseError(jsonParseError.message))
            message = jsonBody?.error ? err?.message
            if response
              switch response.statusCode
                  when 500 then callback(new errors.ServerError(message))
                  when 404 then callback(new errors.NotFoundError(message))
                  when 403, 400
                      ErrorClass = MESSAGE_TO_ERROR_MAP[message] ? errors.APIError
                      callback(new ErrorClass(message))
                  when 200 then callback(null, jsonBody)
                  else callback(new errors.APIError(message ? 'Unknown error'))
            else
              callback(err)


    _getAccessToken: (code, callback) ->
        params =
            code: code
            app_id: @appID
            app_secret: @appSecret
        @sendRequest(url: @authorizeURL, method: 'POST', params: params, (err, json) =>
            if err?
                callback(err)
            else
                callback(null, json['access_token'])
        )

    _getUserInfo: (accessToken, callback) ->
        @sendRequest(url: @infoURL, method: 'GET', params: {access_token: accessToken}, (err, json) =>
            if err?
                callback(err)
            else
                callback(null, json['info'])
        )

    getLoginInformation: (opts, callback) ->
        @_getAccessToken opts.code, (err, accessToken) =>
            return callback(err) if err?
            @_getUserInfo accessToken, (err, userInfo) =>
                return callback(err) if err?
                callback(null, userInfo)

    getLogoutInformation: (opts, callback) ->
        params =
            logout_token: opts.logoutToken
            app_id: @appID
            app_secret: @appSecret
        @sendRequest(url: @logoutURL, method: 'POST', params: params, (err, json) =>
            return callback(err) if err?
            callback(null, json['clef_id'])
        )

for own errorName, errorType of errors
    ClefAPI::[errorName] = errorType


module.exports = ClefAPI
