//
//  OPAYMockApplePayDef.h
//
//  Created by sachin on 26/02/15.
//  Copyright (c) 2015 PaySafe. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString * const url_single_user_token;
extern NSString * const url_fake_apple_token;

static NSString *merchantIdentifier;
static NSString *merchantUserID;
static NSString *merchantPassword;
static NSDictionary *responseData;
static NSString *countryCode;
static NSString *currencyCode;
static NSString *selectedCardNumber;
static NSString *envType;
static NSString *merchantAuthID;
static NSString *merchantAuthPassword;
static NSString *merchantAccountNo;






@interface PaySafeMockApplePayDef : NSObject


@property(assign)NSString *merchantPassword;

+(void)OPAYLog:(NSString*)functionName returnMessage:(id)message;

+ (NSString*) merchantUserID;
+ (void) setMerchantUserID:(NSString*)value;

+ (NSString*) merchantPassword;
+ (void) setMerchantPassword:(NSString*)value;

+ (NSDictionary*) responseData;
+ (void) setResponseData:(NSDictionary*)value;

+ (NSString*) merchantIdentifier;
+ (void) setMerchantIdentifier:(NSString*)value;

+ (NSString*) countryCode;
+ (void) setCountryCode:(NSString*)value;

+ (NSString*) currencyCode;
+ (void) setCurrencyCode:(NSString*)value;

+ (NSString*) selectedCardNumber;
+ (void) setSelectedCardNumber:(NSString*)value;

+(NSString*)envType;
+(void)setEnvType:(NSString *)value;


+(NSString*)merchantAuthID;
+(void)setMerchantAuthID:(NSString *)ID;


+(NSString*)merchantAuthPassword;
+(void)setMerchantAuthPassword:(NSString *)Password;

+ (NSString*) merchantAccountNo;
+ (void) setMerchantAccountNo:(NSString*)value;



@end
