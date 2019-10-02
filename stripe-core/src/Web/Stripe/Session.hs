{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeFamilies          #-}
-------------------------------------------
-- |
-- Module      : Web.Stripe.Session
-- Copyright   : (c) David Johnson, 2014
-- Maintainer  : djohnson.m@gmail.com
-- Stability   : experimental
-- Portability : POSIX
module Web.Stripe.Session
    ( -- * API
      CreateSession
    , createSession
    , GetSession
    , getSession
      -- * Types
    , SessionId(..)
    , SuccessUrl(..)
    , CancelUrl(..)
    , ClientReferenceId(..)
    , CustomerEmail(..)
    , Amount       (..)
    , LineItems(..)
    , LineItem(..)
    , Charge       (..)
    , ChargeId     (..)
    , EndingBefore (..)
    , ExpandParams (..)
    , Session       (..)
    , SessionId     (..)
    , StripeList   (..)
    ) where

import           Web.Stripe.StripeRequest   (Method (GET, POST),
                                             StripeHasParam, StripeReturn,
                                             StripeRequest (..), toStripeParam, mkStripeRequest)
import           Web.Stripe.Util            ((</>))
import           Web.Stripe.Types           (Amount(..), Charge (..), ChargeId (..), Currency(..),
                                             EndingBefore(..), Limit(..),
                                             MetaData(..), Session (..),
                                             SessionId (..), SuccessUrl(..), CancelUrl(..), LineItems(..), LineItem(..), CustomerId(..), CustomerEmail(..), ClientReferenceId(..),
                                             StartingAfter(..), ExpandParams(..),
                                             StripeList (..))

------------------------------------------------------------------------------
-- | create a `Session`
createSession
    :: SuccessUrl -- ^ Success url
    -> CancelUrl -- ^ Cancel url
    -> StripeRequest CreateSession
createSession
    successUrl
    cancelUrl   = request
  where request = mkStripeRequest POST url params
        url     = "checkout" </> "sessions"
        params  = toStripeParam successUrl $
                  toStripeParam cancelUrl $
                  (("payment_method_types[]", "card") :) $
                  []

data CreateSession
type instance StripeReturn CreateSession = Session
instance StripeHasParam CreateSession LineItems
instance StripeHasParam CreateSession CustomerId
instance StripeHasParam CreateSession ClientReferenceId
instance StripeHasParam CreateSession CustomerEmail

------------------------------------------------------------------------------
-- | Retrieve a `Session` by `ChargeId` and `SessionId`
getSession
    :: SessionId -- ^ `SessionId` associated with the `Session` to be retrieved
    -> StripeRequest GetSession
getSession
   (SessionId sessionid) = request
   where request = mkStripeRequest GET url params
         url     = "checkout" </> "sessions" </> sessionid
         params  = []

data GetSession
type instance StripeReturn GetSession = Session
instance StripeHasParam GetSession ExpandParams
