//
//  HomeViewController.m
//  TestQAMerchantApplication
//
//  Copyright (c) 2015 Opus. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuScreen.h"
#import "CreditCardViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface HomeViewController ()

{
    NSDictionary *tokenResponse;
    BOOL isSwitchOn;
}


@end

@implementation HomeViewController
@synthesize authButton,merchantRefLbl,merchantRefTxt,switchLbl,amountTxt,amtLbl,settleSwitch,btnBack;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Apple Pay";
    // Do any additional setup after loading the view.    
    [self getDataFromPlist];
    
    if (!([self.PaysafeAuthController isApplePaySupport])) {
        [self.payButton setImage:[UIImage imageNamed:@"payNow_img.png"] forState:UIControlStateNormal];
    }
    
    merchantRefTxt.text = @"test_2015_323_sdfa";
    merchantRefTxt.delegate = self;
    amountTxt.delegate = self;
    
    authButton.hidden = true;
}

- (void)getDataFromPlist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MerchantRealConfiguration" ofType:@"plist"];
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *merchantUserID = [myDictionary objectForKey:@"merchant_api_key_id"];
    NSString *merchantPassword =[myDictionary objectForKey:@"merchant_api_key_password"];
    NSString *merchantCountryCode = [myDictionary objectForKey:@"merchant_country_code"];
    NSString *merchantCurrencyCode = [myDictionary objectForKey:@"merchant_currency_code"];
    NSString *appleMerchantIdentifier = [myDictionary objectForKey:@"merchant_identifier"];
    
    self.PaysafeAuthController = [[PaySafePaymentAuthorizationProcess alloc] initWithMerchantIdentifier:appleMerchantIdentifier withMerchantID:merchantUserID withMerchantPwd:merchantPassword withMerchantCountry:merchantCountryCode withMerchantCurrency:merchantCurrencyCode];
}

-(BOOL)validateCredentials {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MerchantRealConfiguration" ofType:@"plist"];
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *merchantUserID = [myDictionary objectForKey:@"merchant_api_key_id"];
    
    if ([merchantUserID isEqualToString:@"Single Use API Key ID"]) {
        return NO;
    }

    return YES;
}


/* ---------------------- pay button ----------------------- */


-(IBAction)homePayBtnSelected:(id)sender{
    
    if (![self validateCredentials]) {
        [self showAlertWithTitle:@"PaySafe" withMsg:@"Please enter valid merchant credentials"];
        return;
    }
    
    
    if([amountTxt.text isEqualToString:@""] || [amountTxt.text isEqualToString:nil]) {
      [self showAlertWithTitle:@"Alert" withMsg:@"Amount should not be empty/zero."];
        return;
    }
    
#if TARGET_IPHONE_SIMULATOR
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        // code here
        self.PaysafeAuthController.authDelegate = self;
        [self.PaysafeAuthController beginPayment:self withRequestData:[self createDataDictionary] withCartData:[self cartData]];
    }
    else {
        [self showAlertWithTitle:@"Alert" withMsg:@"Device does not support Apple Pay!"];
    }
    
    
#else
    if([self.PaysafeAuthController isApplePaySupport]==false)
    {
        [self showAlertWithTitle:@"Alert" withMsg:@"Device does not support Apple Pay!"];


    } else
    {
        self.PaysafeAuthController.authDelegate = self;
       [self.PaysafeAuthController beginPayment:self withRequestData:[self createDataDictionary] withCartData:[self cartData]];
    }
#endif
}

-(IBAction)authorizeBtnSelected:(id)sender{
    
    self.OPTAuthObj = [[OPTAuthorizationProcess alloc] init];
    self.OPTAuthObj.processDelegate = self;
    [self.OPTAuthObj prepareRequestForAuthorization:[self createAuthDataDictonary]];
}

/* --------------- Creating data dictionaries -------------- */


-(NSMutableDictionary *)createDataDictionary {
    // Merchant shipping methods
    NSString *shippingMethodName = @"Llma California Shipping";
    NSString *shippingMethodAmount = @"0.01";
    NSString *shippingMethodDescription = @"3-5 Business Days";
    
    NSDictionary *shippingMethod = [NSDictionary dictionaryWithObjectsAndKeys:shippingMethodName,@"shippingName",shippingMethodAmount,@"shippingAmount", shippingMethodDescription,@"shippingDes", nil];
    
    
    NSMutableDictionary *EnvSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MerchantRealConfiguration" ofType:@"plist"]];
    
    NSDictionary *envSettingDict = [NSDictionary dictionaryWithObjectsAndKeys:[EnvSettings valueForKey:@"enviornmentType"],@"EnvType",[EnvSettings valueForKey:@"timeInterval"],@"TimeIntrval",nil];
    
    NSMutableDictionary *finalDataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:shippingMethod, @"ShippingMethod",envSettingDict,@"EnvSettingDict", nil ];
    return finalDataDictionary;
}

-(NSDictionary*)cartData
{
    // Merchant Cart data
    
    NSString *cartID =@"123423";
    NSString *cartTitle = @"TShirt";
    NSString *cartCost = amountTxt.text;
    NSString *cartDiscount = @"3";
    NSString *cartShippingCost =@"0.001";
    NSString *payTo =@"Llama Services, Inc.";
    
    NSDictionary *cartDictonary = [NSDictionary dictionaryWithObjectsAndKeys:cartID,@"CartID",cartTitle,@"CartTitle",cartCost,@"CartCost",cartDiscount, @"CartDiscount", cartShippingCost,@"CartShippingCost" , payTo, @"PayTo", nil];

    return cartDictonary;
}

/* ----- OPTPaymentAuthorizationViewControllerDelegate ---- */
#pragma mark OPTPaymentAuthorizationViewControllerDelegate
 
-(void)callBackResponseFromOPTSDK:(NSDictionary*)response
{
    if(response)
    {
        NSDictionary *errorDict=[response objectForKey:@"error"];
        
        NSString *code;
        NSString *message;
        
        if(errorDict){
            code=[errorDict objectForKey:@"code"];
            message=[errorDict objectForKey:@"message"];
            
            [self showAlertWithTitle:code withMsg:message];
        }
        else
        {
            tokenResponse = [NSDictionary dictionaryWithDictionary:response];
            NSString *message = [NSString stringWithFormat:@"Your Payment Token is :: %@", [response objectForKey:@"paymentToken"]];
            [self showAlertWithTitle:@"Success" withMsg:message];
            authButton.hidden = false;
            
        }
    }else{
        //Error handling
        [self showAlertWithTitle:@"Alert" withMsg:@"Error message"];

    }
}

-(void)callNonAppleFlowFromOPTSDK
{
    [self callNonApplePayFlow];
}

-(void)callBackAuthorizationProcess:(NSDictionary*)dictonary{
    
    NSDictionary *errorDict=[dictonary objectForKey:@"error"];
    
    NSString *code;
    NSString *message;
    
    if(errorDict){
        code=[errorDict objectForKey:@"code"];
        message=[errorDict objectForKey:@"message"];
        
        [self showAlertWithTitle:code withMsg:message];
    }
    else if([([dictonary objectForKey:@"status"]) isEqualToString:@"COMPLETED"])
    {
        NSNumber* authObject =[dictonary objectForKey:@"settleWithAuth"];
        
        if([authObject boolValue]== 0)
        {
            code=@"Success";
            message=@"Authorization completed, please proceed for settlement.";
            [self showAlertWithTitle:code withMsg:message];
        }else{
            code=@"Success";
            message=@"Settlement got completed, please check your order history.";
            [self showAlertWithTitle:code withMsg:message];

        }
    }
}


-(NSDictionary *)createAuthDataDictonary{
    
    NSDictionary *txnDic = tokenResponse[@"transaction"];
    NSString *amount = [txnDic valueForKey:@"amount"];
    
    NSDictionary *cardDictonary = [NSDictionary dictionaryWithObjectsAndKeys:[tokenResponse valueForKey:@"paymentToken"],@"paymentToken", nil];
    
    NSMutableDictionary *authDictonary =[[NSMutableDictionary alloc]init];
    [authDictonary setObject:merchantRefTxt.text forKey:@"merchantRefNum"];
     [authDictonary setObject:amount forKey:@"amount"];
     [authDictonary setObject:cardDictonary forKey:@"card"];
     [authDictonary setObject:@"Hand bag - Big" forKey:@"description"];
     [authDictonary setObject:@"10.10.345.114" forKey:@"customerIp"];
    if(isSwitchOn){
        [authDictonary setObject:@"true" forKey:@"settleWithAuth"];
    }else{
        [authDictonary setObject:@"false" forKey:@"settleWithAuth"];
    }
        
    return authDictonary;
}

- (IBAction)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn])
    {
        isSwitchOn = true;
    } else
    {
        isSwitchOn = false;
    }
}

// became first responder
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return false;
}

#pragma mark End

/* --------------------------------------------------------- */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callNonApplePayFlow
{
    CreditCardViewController *creditCardViewController=[[CreditCardViewController alloc]init];
    creditCardViewController.amount=amountTxt.text;
    creditCardViewController.PaysafeAuthPaymentController=self.PaysafeAuthController;
   
    UIStoryboard *storyboard = self.storyboard;
    creditCardViewController = [storyboard instantiateViewControllerWithIdentifier:@"CreditCardViewController"];
    [self.navigationController pushViewController:creditCardViewController animated:YES];
}

-(void)getTokenUseingCard:(NSDictionary *)response
{
    [self callBackResponseFromOPTSDK:response];
}

-(void)showAlertWithTitle:(NSString *)title withMsg:(NSString *)msg  {
    
    self.alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self removeAlertController];
                                                          }];
    [self.alertController addAction:defaultAction];
    [self presentViewController:self.alertController animated:YES completion:nil];
    
}
-(void)removeAlertController {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


@end
