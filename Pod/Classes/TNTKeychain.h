
#import <UIKit/UIKit.h>

/*
 The TNTKeychain class is an abstraction layer for the iPhone Keychain communication. It is merely a
 simple wrapper to provide a distinct barrier between all the idiosyncracies involved with the Keychain
 CF/NS container objects.
 */
@interface TNTKeychain : NSObject

/**
 *  Store the given data into keychain associated to its service name.
 *
 *  @param service The name of the service to be associated.
 *  @param data    The data to be stored.
 */
+ (void)save:(NSString *)service data:(id)data;

/**
 *  Load the associated data from a given service name.
 *
 *  @param service The service name which contains the data.
 *
 *  @return The associated data. It returns nil in case it does not exist.
 */
+ (id)load:(NSString *)service;

/**
 *  Delete the data associated to the given service name.
 *
 *  @param service The service name associated to the data.
 */
+ (void)delete:(NSString *)service;

@end
