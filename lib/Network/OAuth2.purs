module Network.OAuth2 where

import Data.Array
import Data.Foldable
import Data.Function
import Data.Maybe
import Data.Maybe.Unsafe
import Data.Monoid

type OAuthURI = String
type OAuthSeconds = Number

data OAuthPresentToken = PresentQS | PresentHeader

instance showOAuthPresentToken :: Show OAuthPresentToken where
    show PresentQS     = "qs"
    show PresentHeader = "header"

data OAuthScopes = OAuthScopes
    { _oscopeRequest :: [OAuthURI]
    , _oscopeRequire :: [OAuthURI]
    }

instance showOAuthScopes :: Show OAuthScopes where
    show (OAuthScopes s) = "(OAuthScopes"
        <> " " <> intercalate "," s._oscopeRequest
        <> " " <> intercalate "," s._oscopeRequire
        <> ")"

data OAuthSettings = OAuthSettings
    { _oauthProviderID    :: Maybe String
    , _oauthClientID      :: String
    , _oauthRedirectURI   :: Maybe OAuthURI
    , _oauthAuthorization :: OAuthURI
    , _oauthDefLifetime   :: Maybe OAuthSeconds
    , _oauthPresentToken  :: Maybe OAuthPresentToken
    , _oauthScopes        :: OAuthScopes
    , _oauthIsDefault     :: Boolean
    , _oauthDebug         :: Boolean
    }

instance showOAuthSettings :: Show OAuthSettings where
    show (OAuthSettings s) = "(OAuthSettings "
        <>  intercalate ", " [ show s._oauthProviderID
                             , show s._oauthClientID
                             , show s._oauthRedirectURI
                             , show s._oauthAuthorization
                             , show s._oauthDefLifetime
                             , show s._oauthPresentToken
                             , show s._oauthScopes
                             , show s._oauthIsDefault
                             , show s._oauthDebug ]
        <> ")"

foreign import data OAuthInstance :: *

instance showOAuthInstance :: Show OAuthInstance where
    show _ = "(OAuthInstance)"

defaultSettings :: OAuthSettings
defaultSettings = OAuthSettings
    { _oauthProviderID:    Nothing
    , _oauthClientID:      "client-id"
    , _oauthRedirectURI:   Nothing
    , _oauthAuthorization: "http://localhost"
    , _oauthDefLifetime:   Nothing
    , _oauthPresentToken:  Nothing
    , _oauthScopes:        OAuthScopes { _oscopeRequest: [], _oscopeRequire: [] }
    , _oauthIsDefault:     false
    , _oauthDebug:         false
    }

foreign import initOAuthImpl
"""
function initOAuthImpl(isJust, fromJust, showToken, settings) {
    var jsoSettings = {};
    if (isJust(settings._oauthProviderID)) {
        jsoSettings.providerID = fromJust(settings._oauthProviderID);
    }
    jsoSettings.client_id = settings._oauthClientID;
    if (isJust(settings._oauthRedirectURI)) {
        jsoSettings.redirect_uri = fromJust(settings._oauthRedirectURI);
    }
    jsoSettings.authorization = settings._oauthAuthorization;
    if (isJust(settings._oauthDefLifetime)) {
        jsoSettings.default_lifetime = fromJust(settings._oauthDefLifetime);
    }
    jsoSettings.isDefault = settings._oauthIsDefault;
    jsoSettings.debug = settings._oauthDebug;
    jsoSettings.presenttoken = showToken(settings._oauthPresentToken);
    jsoSettings.scopes = {};
    if (settings._oauthScopes._oscopeRequest) {
        jsoSettings.scopes.request = settings._oauthScopes._oscopeRequest;
    }
    if (settings._oauthScopes._oscopeRequire) {
        jsoSettings.scopes.require = settings._oauthScopes._oscopeRequire;
    }

    return new JSO(jsoSettings);
}
""" :: forall a. Fn4
    (Maybe a -> Boolean)
    (Maybe a -> a)
    (OAuthPresentToken -> String)
    OAuthSettings
    OAuthInstance

initOAuth
    :: OAuthSettings
    -> OAuthInstance
initOAuth x = runFn4 initOAuthImpl isJust fromJust show x
