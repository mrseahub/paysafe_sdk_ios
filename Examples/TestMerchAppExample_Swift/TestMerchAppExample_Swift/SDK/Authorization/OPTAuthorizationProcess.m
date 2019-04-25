//
//  OPTAuthorizationProcess.m
//  TestQAMerchantApplication
//
//  Created by PLMAC-A1278-C1MLJUH1DTY3 on 2/13/15.
//  Copyright (c) 2015 opus. All rights reserved.
//

#import "OPTAuthorizationProcess.h"
#import "AppConstants.h"

@interface OPTAuthorizationProcess()
{
}

@property (nonatomic, retain) UIAlertController *alertCntrl;
@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSData *jsonData;
@end

@implementation OPTAuthorizationProcess
@synthesize responseData;

//- (id)init{
//    
//    return self;
//}

- (instancetype)init:(NSDictionary*)dictionary
{
    return [[[self class] alloc] init];
}

- (void)prepareRequestForAuthorization:(NSDictionary *)dictionary
{
    id dataObject = [NSDictionary dictionaryWithDictionary:dictionary];
    
    NSError *jsonSerializationError = nil;
    _jsonData = [NSJSONSerialization dataWithJSONObject:dataObject options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    
    if(!jsonSerializationError) {
       // NSString *serJSON = [[NSString alloc] initWithData:_jsonData encoding:NSUTF8StringEncoding];
        
        [self requestServiceRequestData:_jsonData];
    } else
    {
    }
}

-(void)requestServiceRequestData:(NSData*)requestData{
    
    
    [self callWaitingAlertViewTitle:@"" withMessage:nil withOkBtn:NO];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MerchantRealConfiguration" ofType:@"plist"];
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/merchantcardtestapp/v1/accounts/%@/authorizations",BaseUrl,[myDictionary objectForKey:@"merchantAccount"]];
        NSString *apiName = @"authorizations";
    
    
    
    NSString *userIDPassword= [NSString stringWithFormat:@"%@:%@", [myDictionary objectForKey:@"OptiMerchantID-Client"], [myDictionary objectForKey:@"OptiMerchantPassword-Client"]];
        NSData *plainData = [userIDPassword dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    
    NSString *authorizationField= [NSString stringWithFormat: @"Basic %@", base64String];
    
    [[WebServiceHandler sharedManager] callWebServiceWithURL:urlString withWebServiceName:apiName withAuthorization:authorizationField withReqData:requestData withMethod:@"POST" withSuccessfulBlock:^(NSData * _Nonnull responseData, NSString * _Nonnull serviceName) {
        self.responseData = (NSMutableData *)responseData;
        NSError *myError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
        [self removeAlertView:self.alertCntrl];
        [self.processDelegate callBackAuthorizationProcess:res];

        
    } withFailedBlock:^(NSError * _Nonnull error) {
        
        [self removeAlertView:self.alertCntrl];
        [self callWaitingAlertViewTitle:@"Alert" withMessage:@"Network connection error, please try again." withOkBtn:YES];

    }];
    self.responseData=[NSMutableData data];



}


- (void)callWaitingAlertViewTitle:(NSString *)title withMessage:(NSString*)message withOkBtn:(BOOL)isOkBtn{

    self.alertCntrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (isOkBtn) {
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self.alertCntrl dismissViewControllerAnimated:YES completion:nil];
                                                           [self callRetryRequest];
                                                       }];
        [self.alertCntrl addAction:cancel];
        
    } else {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = CGPointMake((_alertCntrl.view.bounds.size.width/2.0)-45.00, _indicator.frame.size.height);
        [_indicator startAnimating];
        [self.alertCntrl.view addSubview:_indicator];
    }
        
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:self.alertCntrl animated:YES completion:nil];
}

- (void)removeAlertView:(UIAlertController *)alert{
    if (_indicator !=nil) {
        [_indicator stopAnimating];
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
    [self.alertCntrl dismissViewControllerAnimated:YES completion:nil];
}

- (void)callRetryRequest
{
    [self requestServiceRequestData:_jsonData];
}

@end
