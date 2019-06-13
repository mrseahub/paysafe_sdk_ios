//
//  OPAYMockPaymentAuthorizationProcess.m
//
//  Created by sachin on 26/02/15.
//  Copyright (c) 2015 PaySafe. All rights reserved.
//

#import "PaySafeMockPaymentAuthorizationProcess.h"
#import "PaySafeMockPaymentSummaryViewController.h"
#import "PaySafeMockApplePayDef.h"
#import "PaySafeMockPayment.h"
#import "PKPayment+OPAYMockKeys.h"
#import "PaySafeMockCardStore.h"
#import "PaySafeMockShippingManager.h"
#import <iOS_SDK/WebServiceHandler.h>
#import <iOS_SDK/PaySafeDef.h>

#define FAKE_APPLE_TOKE_SERVICE @"FakeApplePayTokenService"
#define FAKE_SINGLE_USE_TOKEN @"FakeSingleUseTOkenService"


@interface PaySafeMockPaymentAuthorizationProcess ()  <UIViewControllerTransitioningDelegate,PKPaymentAuthorizationViewControllerDelegate>
{
    
    NSDictionary *merchantCartDictonary;
    NSDictionary *shippingMethodData;
    
}

@property(nonatomic, assign)id<PKPaymentAuthorizationViewControllerDelegate>pkDelegate;

@property (strong) NSData *paymentTokenData;
@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) PaySafeMockShippingManager *shippingManager;

// URL ///
@property (retain, nonatomic) NSMutableData *responseData;
@property (retain, nonatomic) NSString *baseURL;
@property (retain) id requestData;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic , retain) UIViewController *optViewController;
@property(nonatomic , retain) NSString *requestServiceName;

@property (retain, nonatomic) NSMutableData *fakeTokenData;
@property (retain, nonatomic) NSData *cardData;
@property(retain,nonatomic) UIViewController *authorizationController;
@end

@implementation PaySafeMockPaymentAuthorizationProcess
@synthesize authTestDelegate;
@synthesize responseData,baseURL,requestData,shippingManager=_shippingManager;
@synthesize activityIndicator,optViewController,requestServiceName,fakeTokenData,cardData,authorizationController;

-(BOOL)isHavingStub
{
    return true;
}

- (id)initWithMerchantIdentifier:(NSString*)merchantIdentifier withMerchantID:(NSString*)optiMerchantID withMerchantPwd:(NSString*)optiMerchantPwd withMerchantCountry:(NSString*)merchantCountry withMerchantCurrency:(NSString*)merchantCurrency withEnviornmentType:(NSString *)enviornmentType withMerchantAuthID:(NSString *)merchantAuthID withMerchantAuthPassword:(NSString*)merchantAuthPassword withMerchantAccountNumber:(NSString *)merchantAccountNumber{
    // Set the data for all objects !!!
    
    PaySafeMockApplePayDef.merchantUserID=optiMerchantID;
    PaySafeMockApplePayDef.merchantPassword=optiMerchantPwd;
    PaySafeMockApplePayDef.merchantIdentifier=merchantIdentifier;
    PaySafeMockApplePayDef.countryCode=merchantCountry;
    PaySafeMockApplePayDef.currencyCode=merchantCurrency;
    PaySafeMockApplePayDef.envType = enviornmentType;
    PaySafeMockApplePayDef.merchantAuthID =merchantAuthID;
    PaySafeMockApplePayDef.merchantAuthPassword = merchantAuthPassword;
    PaySafeMockApplePayDef.merchantAccountNo =merchantAccountNumber;
    //PaySafeMockApplePayDef.
    return self;
}

- (void)showPaymentSummeryView:(UIViewController *)viewController delgate:(id<PKPaymentAuthorizationViewControllerDelegate>) pDelegate withIdentifier:(NSString*)merchantIdentifier withMerchantID:(NSString*)optiMerchantID withMerchantPwd:(NSString*)optiMerchantPwd withMerchantCountry:(NSString*)merchantCountry withMerchantCurrency:(NSString*)merchantCurrency withRequestData:(NSDictionary*)dataDictionary withCartData:(NSDictionary*)cartData
{
    
    optViewController=viewController;
    
    shippingMethodData = [dataDictionary objectForKey:@"ShippingMethod"];
    
    merchantCartDictonary =  cartData;
    // End of Placing data
    
    PaySafeMockApplePayDef.merchantUserID = optiMerchantID;
    PaySafeMockApplePayDef.merchantPassword = optiMerchantPwd;
    
    PaySafeMockApplePayDef.merchantIdentifier = merchantIdentifier;
    PaySafeMockApplePayDef.countryCode = merchantCountry;
    PaySafeMockApplePayDef.currencyCode = merchantCurrency;
    
    
    
    NSString *merchantId = PaySafeMockApplePayDef.merchantIdentifier ;
    PKPaymentRequest *paymentRequest = [PaySafeMockPayment paymentRequestWithMerchantIdentifier:merchantId];
    [paymentRequest setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldPostalAddress];
       
    if (shippingMethodData == nil || [shippingMethodData count]==0)
    {
         paymentRequest.paymentSummaryItems = [self summaryItemsForShippingMethod];
    } else
    {
        paymentRequest.shippingMethods =[self getShippingMethod];
        paymentRequest.paymentSummaryItems = [self summaryItemsForShippingMethod:paymentRequest.shippingMethods.firstObject];
   }
    
    
    PaySafeMockPaymentSummaryViewController *summary = [[PaySafeMockPaymentSummaryViewController alloc] initWithPaymentRequest:paymentRequest];
    summary.delegate=pDelegate;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:summary];
    [optViewController presentViewController:navController animated:YES completion:nil];
    
}

- (NSArray *)getShippingMethod
{
    
    PKShippingMethod *normalItem =[PKShippingMethod summaryItemWithLabel:[shippingMethodData valueForKey:@"shippingName"] amount:[NSDecimalNumber decimalNumberWithString:[shippingMethodData valueForKey:@"shippingAmount"]]];
    normalItem.detail = [shippingMethodData valueForKey:@"shippingDes"];
    
    normalItem.identifier = normalItem.label;
    return  @[normalItem];
}

- (PaySafeMockShippingManager *)shippingManager {
    if (!_shippingManager) {
        _shippingManager = [PaySafeMockShippingManager new];
    }
    return _shippingManager;
}

- (NSArray *)summaryItemsForShippingMethod:(PKShippingMethod *)shippingMethod
{
    self.amount=[[NSDecimalNumber alloc] initWithString:[merchantCartDictonary valueForKey:@"CartCost"]];
    
    PKPaymentSummaryItem *summeryItem = [PKPaymentSummaryItem summaryItemWithLabel:[merchantCartDictonary valueForKey:@"CartTitle"] amount:self.amount];
    NSDecimalNumber *total = [summeryItem.amount decimalNumberByAdding:shippingMethod.amount];
    
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:[merchantCartDictonary valueForKey:@"PayTo"] amount:total];
    
    return @[summeryItem,shippingMethod,totalItem];
    
}
- (NSArray *)summaryItemsForShippingMethod
{
    self.amount=[[NSDecimalNumber alloc] initWithString:[merchantCartDictonary valueForKey:@"CartCost"]];
    
    PKPaymentSummaryItem *summeryItem = [PKPaymentSummaryItem summaryItemWithLabel:[merchantCartDictonary valueForKey:@"CartTitle"] amount:self.amount];
    NSDecimalNumber *total =self.amount;
    
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:[merchantCartDictonary valueForKey:@"PayTo"] amount:total];
    
    return @[summeryItem,totalItem];
    
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    cardData=[self getCardDetails:payment];
    [self requestServiceByName:FAKE_APPLE_TOKE_SERVICE] ;
    
}
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {

}

-(NSData *)getCardDetails:(PKPayment *)payment
{
    NSString *accountNumbar =PaySafeMockApplePayDef.selectedCardNumber;//payment.opt_testCardNumber;
    NSString *accountExpiry = @"221231";
    NSString *amount = [merchantCartDictonary valueForKey:@"CartCost"];
    NSString *cardHolderName = @"Bill Gates";
    
    NSDictionary *fakeTokenDictonary = [NSDictionary dictionaryWithObjectsAndKeys:accountNumbar,@"applicationPrimaryAccountNumber",accountExpiry,@"applicationExpirationDate",amount,@"transactionAmount",cardHolderName, @"cardholderName", nil];
    
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fakeTokenDictonary options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    
    return jsonData;
}

//get token from optimal !!!
- (void)requestServiceByName:(NSString *)serviceName
{
    requestServiceName=serviceName;
    NSString *userIDPassword= [NSString stringWithFormat:@"%@:%@", PaySafeMockApplePayDef.merchantUserID, PaySafeMockApplePayDef.merchantPassword];
    NSData *plainData = [userIDPassword dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSString *authorizationField= [NSString stringWithFormat: @"Basic %@", base64String];
    self.responseData=[NSMutableData data];
     NSString *projectsUrl;
     NSData *postData;
    if ([requestServiceName isEqualToString:FAKE_APPLE_TOKE_SERVICE]) {
        [self showActivityViewer];
        projectsUrl = [NSString stringWithFormat:@"%@/customervault/v1/applepaysingleusetokens/faketoken/simple",[PaySafeDef getOptimalUrl]];
        postData = cardData;
    }
    else if([requestServiceName isEqualToString:FAKE_SINGLE_USE_TOKEN]) {
        projectsUrl = [NSString stringWithFormat:@"%@/customervault/v1/applepaysingleusetokens",[PaySafeDef getOptimalUrl]];

        postData = fakeTokenData;

    }
    
    [[WebServiceHandler sharedManager] callWebServiceWithURL:projectsUrl withWebServiceName:requestServiceName withAuthorization:authorizationField withReqData:postData withMethod:@"POST" withSuccessfulBlock:^(NSData * _Nonnull responseData,NSString *serviceName) {
        self.responseData = (NSMutableData *)responseData;
        NSError *myError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
        
        if ([serviceName isEqualToString:FAKE_APPLE_TOKE_SERVICE])
        {
            self.fakeTokenData=self.responseData;
            [self requestServiceByName:FAKE_SINGLE_USE_TOKEN];
        }
        else if([serviceName isEqualToString:FAKE_SINGLE_USE_TOKEN])
        {
            [self hideActivityViewer];
            [self.authTestDelegate callBackResponseFromOPAYMockSDK:res];
        }

        
    } withFailedBlock:^(NSError * _Nonnull error) {
        [self hideActivityViewer];
        NSLog(@"Error %@",error.debugDescription);
      //  [self.authTestDelegate callBackResponseFromOPAYMockSDK:error.];


    }];
    

}


//////// ANIMATION ///////////

-(void)showActivityViewer
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [optViewController.view addSubview:self.activityIndicator];
    self.activityIndicator.center = CGPointMake(self.optViewController.view.frame.size.width / 2, self.optViewController.view.frame.size.height / 2);
    [optViewController.view setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
}

-(void)hideActivityViewer{
    [self.activityIndicator stopAnimating];
    [optViewController.view setUserInteractionEnabled:YES];
    self.activityIndicator=nil;
}

@end
