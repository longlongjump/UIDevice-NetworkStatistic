//
//  UIDevice+Utils.h



#import <UIKit/UIKit.h>


// Usage [[UIDevice currentDevice] networkStatistics];
// returns [{bytes_received: 1925011178, bytes_received: 1925011178, device_name: en0}]

@interface UIDevice (NetworkStatistic)
-(NSDictionary*)networkStatistics;
@end
