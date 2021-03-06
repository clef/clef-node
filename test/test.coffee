assert = require 'assert'
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require "sinon-chai"
expect = chai.expect
chai.use sinonChai

Clef = require '../src/clef'
request = require 'request'

TEST_APP_ID = 'da242b09262a021a8dbbee5b6346f750'
TEST_APP_SECRET = '5e18dbf4e817f0608a56b470537b22c2'
TEST_CODE = 'code_1234567890'
TEST_TOKEN = 'token_1234567890'
TEST_LOGOUT_TOKEN = '48ea8cc26d65ad7e1fbdd9acf6584786'

describe 'Clef API', ->
    @timeout(15000);
    describe '#initialize', ->
        it 'creates a ClefAPI object with the proper parameters', ->
            clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
            assert.equal(clef.appID, TEST_APP_ID)
            assert.equal(clef.appSecret, TEST_APP_SECRET)
            assert.equal(clef.apiBase, 'https://clef.io/api/v1')
            assert.equal(clef.authorizeURL, 'https://clef.io/api/v1/authorize')
            assert.equal(clef.infoURL, 'https://clef.io/api/v1/info')
            assert.equal(clef.logoutURL, 'https://clef.io/api/v1/logout')

        it 'sets root when passing in a root parameter', ->
            clef = Clef.initialize({
                appID: TEST_APP_ID,
                appSecret: TEST_APP_SECRET,
                root: 'https://turnip.com'
            })
            assert.equal(clef.apiBase, 'https://turnip.com/v1')
            assert.equal(clef.authorizeURL, 'https://turnip.com/v1/authorize')
            assert.equal(clef.infoURL, 'https://turnip.com/v1/info')
            assert.equal(clef.logoutURL, 'https://turnip.com/v1/logout')

    describe '#getLoginInformation', ->
        clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
        it 'should return user info', (done) ->
            clef.getLoginInformation code: TEST_CODE, (err, info) ->
                expect(info).to.have.property('email', 'alex@getclef.com')
                done()

        it 'gets an access token', (done) ->
            getAccessToken = sinon.spy(clef, '_getAccessToken')
            clef.getLoginInformation code: TEST_CODE, (err, info) ->
                expect(getAccessToken).to.have.been.calledWith(TEST_CODE)
                done()

        it 'gets user info', (done) ->
            getUserInfo = sinon.spy(clef, '_getUserInfo')
            clef.getLoginInformation code: TEST_CODE, (err, info) ->
                expect(getUserInfo).to.have.been.calledWith(TEST_TOKEN)
                done()

    describe '#_getAccessToken', ->
        clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
        it 'makes a request to the API server', (done) ->
            sendRequest = sinon.spy(clef, 'sendRequest')
            clef._getAccessToken TEST_CODE, (err, token) ->
                expect(sendRequest).to.have.been.calledWith({
                    url: clef.authorizeURL,
                    method: 'POST',
                    params: {
                        'code': TEST_CODE,
                        'app_id': TEST_APP_ID,
                        'app_secret': TEST_APP_SECRET
                    }
                })
                done()

        it 'errors when the code is invalid', (done) ->
            clef._getAccessToken 'invalid code', (err, token) ->
                expect(err).to.exist
                expect(err.type).to.equal('InvalidOAuthCodeError')
                done()

    describe '#_getUserInfo', ->
        clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
        it 'makes a request to the API server', (done) ->
            sendRequest = sinon.spy(clef, 'sendRequest')
            clef._getUserInfo TEST_TOKEN, (err, token) ->
                expect(sendRequest).to.have.been.calledWith({
                    url: clef.infoURL,
                    method: 'GET',
                    params: {
                        'access_token': TEST_TOKEN,
                    }
                })
                done()

        it 'errors when the token is invalid', (done) ->
            clef._getUserInfo 'invalid token', (err, token) ->
                expect(err).to.exist
                expect(err.type).to.equal('InvalidOAuthTokenError')
                done()

    describe '#sendRequest', ->
        clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
        requestStub = null
        before ->
            requestStub = sinon.stub(request, 'get')
        after ->
            requestStub.restore()

        it 'returns a ServerError for 500s', (done) ->
            response = statusCode: 500
            requestStub.callsArgWith(1, message: 'hey', response, '{}')

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('ServerError')
                done()

        it 'returns a NotFoundError for 404s', (done) ->
            response = statusCode: 404
            requestStub.callsArgWith(1, message: 'hey', response, '{}')

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('NotFoundError')
                done()

        it 'picks the correct error type based on message', (done) ->
            response = statusCode: 403
            requestStub.callsArgWith(1, message: 'Invalid App ID.', response, null)

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('InvalidAppIDError')
                done()

        it 'falls back to APIError for unknown error messages', (done) ->
            response = statusCode: 403
            requestStub.callsArgWith(1, message: 'unknown', response, null)

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('APIError')
                done()

        it 'returns JSON when there are no errors', (done) ->
            response = statusCode: 200
            requestStub.callsArgWith(1, null, response, '{"success" : true }')

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.not.exist
                expect(body).to.deep.equal({success: true})
                done()

        it 'falls back to APIError when there is an unknown status code', (done) ->
            response = statusCode: 418
            requestStub.callsArgWith(1, message: "I'm a teapot", response, null)

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('APIError')
                done()

        # This can happen if the whole Clef server is down
        it 'doesn\'t crash on unparseable response', (done) ->
            response = statusCode: 200
            requestStub.callsArgWith(1, null, response, '<!DOCTYPE html>')

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
                expect(err).to.exist
                expect(err.type).to.equal('ParseError')
                done()

        it "handles an error in the request", (done) ->
            requestStub.callsArgWith(1, new Error("Test error"), null, null)

            clef.sendRequest url: 'a url', method: 'GET', (err, body) ->
              expect(err).to.exist
              expect(err.message).to.equal('Test error')
              done()

    describe '#getLogoutInformation', ->
        clef = Clef.initialize({ appID: TEST_APP_ID, appSecret: TEST_APP_SECRET })
        it 'should return a clef id', (done) ->
            clef.getLogoutInformation logoutToken: TEST_LOGOUT_TOKEN, (err, clefID) ->
                expect(clefID).to.exist
                done()

        it 'throws an error with an invalid logout_token', (done) ->
            clef.getLogoutInformation logoutToken: 'wrong', (err, info) ->
                expect(err).to.exist
                expect(err.type).to.be.equal('InvalidLogoutTokenError')
                done()
