//
//  UIDevice+Utils.m


#import <sys/types.h>
#import <sys/socket.h>
#import "net/if.h"
#import <sys/sysctl.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import "UIDevice+NetworkStatistic.h"

#define RTM_IFINFO2	0x12

@implementation UIDevice (NetworkStatistic)
-(NSDictionary*)networkStatistics
{
    NSMutableArray *result = [NSMutableArray array];
    
    int mib[6];
    mib[0]	= CTL_NET;			// networking subsystem
	mib[1]	= PF_ROUTE;			// type of information
	mib[2]	= 0;				// protocol (IPPROTO_xxx)
	mib[3]	= 0;				// address family
	mib[4]	= NET_RT_IFLIST2;	// operation
	mib[5]	= 0;

    size_t len = 0;
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
		return nil;
    
    NSMutableData *data = [NSMutableData dataWithLength:len];
    
    if (sysctl(mib, 6, [data mutableBytes], &len, NULL, 0) < 0) {
		return nil;
	}
    
    for (char *next = [data mutableBytes]; next < (char*)[data mutableBytes]+len;)
    {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        
        if (ifm->ifm_type != RTM_IFINFO2) {
            continue;
        }
        
        struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
        struct sockaddr_dl	*sdl = (struct sockaddr_dl *)(if2m + 1);
        
        NSString *name = [[NSString alloc] initWithBytes:sdl->sdl_data
                                                  length:sdl->sdl_nlen
                                                encoding:NSUTF8StringEncoding];
        
        uint64_t sent = if2m->ifm_data.ifi_obytes;
        uint64_t received = if2m->ifm_data.ifi_ibytes;
        
        NSDictionary *device_usage = @{@"bytes_sent": [NSNumber numberWithLongLong:sent],
                                       @"bytes_received": [NSNumber numberWithLongLong:received],
                                       @"device_name": name};
        
        [result addObject:device_usage];
        
    }
    
    return result;
}
@end
