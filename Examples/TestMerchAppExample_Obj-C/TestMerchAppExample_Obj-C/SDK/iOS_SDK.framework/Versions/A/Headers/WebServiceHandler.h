
/* –This class is responsible for calling webService and send back result to it's caller  */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ResponseBlock)(NSData *responseData,NSString *serviceName);
typedef void (^FailureResponse)(NSError *error);


@interface WebServiceHandler : NSObject
+ (id)sharedManager;
-(void)callWebServiceWithURL:(NSString *)urlString withWebServiceName:(NSString *)webserviceName withAuthorization:(NSString *)authorization withReqData:(NSData *)reqData withMethod:(NSString *)method withSuccessfulBlock:(ResponseBlock)successfulBlock withFailedBlock:(FailureResponse)failBlock;


@end

NS_ASSUME_NONNULL_END
