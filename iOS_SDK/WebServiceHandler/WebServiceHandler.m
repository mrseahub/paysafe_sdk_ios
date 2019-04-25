
#import "WebServiceHandler.h"
#import "PaysafeDef.h"
#import "PaySafeConstants.h"


@implementation WebServiceHandler
static WebServiceHandler *sharedWebServiceHandler = nil;

+ (id)sharedManager {
    @synchronized(self) {
        if (sharedWebServiceHandler == nil)
            sharedWebServiceHandler = [[self alloc] init];
    }
    return sharedWebServiceHandler;
}

-(void)callWebServiceWithURL:(NSString *)urlString withWebServiceName:(NSString *)webserviceName withAuthorization:(NSString *)authorization withReqData:(NSData *)reqData withMethod:(NSString *)method withSuccessfulBlock:(ResponseBlock)successfulBlock withFailedBlock:(FailureResponse)failBlock {
    
    NSString *serviceName = webserviceName;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[PaySafeDef.timeInterval doubleValue]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:method];
    if (reqData!=nil) {
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[reqData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:reqData];
    }
    NSURLSessionDataTask *postDataTask = [[self getSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error==nil) {
//            NSDictionary *responseObj = [self parseResponseWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                successfulBlock(data,serviceName);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failBlock(error);
            });
        }
    }];
    [postDataTask resume];
    
}


-(NSURLSession *)getSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    return session;
}

-(NSDictionary *)parseResponseWithData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary  *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    return jsonData;

}


-(NSData *)getPostDataFromDict:(NSDictionary *)inputData {
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:inputData options:0 error:&error];
    return postData;
}


@end
    
