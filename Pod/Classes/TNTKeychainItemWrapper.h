
#import <UIKit/UIKit.h>

/*
 The KeychainItemWrapper class is an abstraction layer for the iPhone Keychain communication. It is merely a 
 simple wrapper to provide a distinct barrier between all the idiosyncracies involved with the Keychain
 CF/NS container objects.
 */
@interface TNTKeychainItemWrapper : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
