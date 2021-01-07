{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE RankNTypes #-}
module Web.Stripe.Test.PaymentIntent where

import           Data.Either   (Either(..), isRight)
import           Test.Hspec
import           Web.Stripe.Test.Util     (makePlanId)
import           Web.Stripe.Test.Prelude

import           Web.Stripe.PaymentIntent
import           Web.Stripe.Card
import           Web.Stripe.Customer
import           Web.Stripe.Token

paymentIntentTests :: StripeSpec
paymentIntentTests stripe = do
  describe "Payment intent tests" $ do
    it "Succesfully creates a PaymentIntent" $ do
      result <- stripe $ do
        paymentIntent <- createPaymentIntent (Amount 100) USD -&- (PaymentIntentUsage OffSession)
        void $ cancelPaymentIntent (paymentIntentId paymentIntent)
        return paymentIntent
      result `shouldSatisfy` isRight
    it "Successfully updates a PaymentIntent" $ do
      result <- stripe $ do
        paymentIntent <- createPaymentIntent (Amount 100) USD
        Customer { customerId = cid } <- createCustomer
        updatedPaymentIntent <-
          updatePaymentIntent (paymentIntentId paymentIntent)
            -&- (Amount 100) -&- USD
            -&- cid
            -&- Description "some description"
            -&- (PaymentIntentUsage OffSession)
        void $ cancelPaymentIntent (paymentIntentId paymentIntent)
        void $ deleteCustomer cid
        return updatedPaymentIntent
      result `shouldSatisfy` isRight
    it "Successfully cancels a PaymentIntent" $ do
      result <- stripe $ do
        paymentIntent <- createPaymentIntent (Amount 100) USD
        cancelledPaymentIntent <- cancelPaymentIntent (paymentIntentId paymentIntent)
        return cancelledPaymentIntent
      result `shouldSatisfy` isRight
    it "Successfully gets a PaymentIntent"$ do
      result <- stripe $ do
        paymentIntent <- createPaymentIntent (Amount 100) USD
        paymentIntent' <- getPaymentIntent (paymentIntentId paymentIntent)
        void $ cancelPaymentIntent (paymentIntentId paymentIntent)
        return paymentIntent'
      result `shouldSatisfy` isRight
    it "Successfully confirms a PaymentIntent"$ do
      result <- stripe $ do
        Customer { customerId = cid } <- createCustomer
        paymentIntent <- createPaymentIntent (Amount 100) USD -&- cid
        Token    { tokenId = tkid   } <- createCardToken (Just cardinfo)
        Card { cardId = CardId cardid } <- createCustomerCardByToken cid tkid
        confirmedPaymentIntent <-
          confirmPaymentIntent (paymentIntentId paymentIntent) -&- (PaymentMethodId cardid)
        void $ deleteCustomer cid
        return confirmedPaymentIntent
      result `shouldSatisfy` isRight
    {- need to do a separate authorization and capture to test this
       https://stripe.com/docs/payments/capture-later
    it "Successfully captures a PaymentIntent"$ do
      result <- stripe $ do
        Customer { customerId = cid } <- createCustomer
        paymentIntent <- createPaymentIntent (Amount 100) USD -&- cid
        Token    { tokenId = tkid   } <- createCardToken (Just cardinfo)
        Card { cardId = CardId cardid } <- createCustomerCardByToken cid tkid
        capturedPaymentIntent <- capturePaymentIntent (paymentIntentId paymentIntent)
        void $ deleteCustomer cid
        return capturedPaymentIntent
      result `shouldSatisfy` isRight -}
    it "Successfully gets all PaymentIntents"$ do
      result <- stripe $ do
        paymentIntents <- getPaymentIntents
        return paymentIntents
      result `shouldSatisfy` isRight

  where
    cardinfo = (mkNewCard credit em ey) { newCardCVC = Just cvc }
    credit = CardNumber "4242424242424242"
    em  = ExpMonth 12
    ey  = ExpYear 2023
    cvc = CVC "123"
