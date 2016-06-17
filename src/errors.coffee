class APIError extends Error
    type: 'APIError'
    constructor: (@message) ->
        if @type?
            @name = @type
        @stack = (new Error(@message)).stack

class InvalidAppIDError extends APIError
    type: 'InvalidAppIDError'
class InvalidAppSecretError extends APIError
    type: 'InvalidAppSecretError'
class InvalidAppError extends APIError
    type: 'InvalidAppError'
class InvalidOAuthCodeError extends APIError
    type: 'InvalidOAuthCodeError'
class InvalidOAuthTokenError extends APIError
    type: 'InvalidOAuthTokenError'
class InvalidLogoutHookURLError extends APIError
    type: 'InvalidLogoutHookURLError'
class InvalidLogoutTokenError extends APIError
    type: 'InvalidLogoutTokenError'
class ServerError extends APIError
    type: 'ServerError'
class ConnectionError extends APIError
    type: 'ConnectionError'
class NotFoundError extends APIError
    type: 'NotFoundError'
class ParseError extends APIError
    type: 'ParseError'

module.exports =
    APIError: APIError
    InvalidAppIDError: InvalidAppIDError
    InvalidAppSecretError: InvalidAppSecretError
    InvalidAppError: InvalidAppError
    InvalidOAuthCodeError: InvalidOAuthCodeError
    InvalidOAuthTokenError: InvalidOAuthTokenError
    InvalidLogoutHookURLError: InvalidLogoutHookURLError
    InvalidLogoutTokenError: InvalidLogoutTokenError
    ServerError: ServerError
    ConnectionError: ConnectionError
    NotFoundError: NotFoundError
    ParseError: ParseError
