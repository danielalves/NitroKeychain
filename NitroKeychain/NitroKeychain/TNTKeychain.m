
#import "TNTKeychain.h"

// ios
#import <Security/Security.h>

#pragma mark - Statics

static NSOperationQueue *serializerQueue;

#pragma mark - Implementation

@implementation TNTKeychain

#pragma mark - Ctors & Dtor

+( void )initialize
{
    if( self == [TNTKeychain class] )
    {
        serializerQueue = [NSOperationQueue new];
        serializerQueue.maxConcurrentOperationCount = 1;
        serializerQueue.name = [NSString stringWithFormat: @"%@SerializerQueue", NSStringFromClass( [self class] )];
    }
}

#pragma mark - Keychain Management

/**
 * These are the default constants and their respective types,
 * available for the kSecClassGenericPassword Keychain Item class:
 *
 * kSecAttrAccessGroup			-		CFStringRef
 * kSecAttrCreationDate		    -		CFDateRef
 * kSecAttrModificationDate     -		CFDateRef
 * kSecAttrDescription			-		CFStringRef
 * kSecAttrComment				-		CFStringRef
 * kSecAttrCreator				-		CFNumberRef
 * kSecAttrType                 -		CFNumberRef
 * kSecAttrLabel				-		CFStringRef
 * kSecAttrIsInvisible			-		CFBooleanRef
 * kSecAttrIsNegative			-		CFBooleanRef
 * kSecAttrAccount				-		CFStringRef
 * kSecAttrService				-		CFStringRef
 * kSecAttrGeneric				-		CFDataRef
 *
 * See the header file Security/SecItem.h for more details.
 */
+( NSMutableDictionary * )genericPasswordKeychainQuery:( NSString * )keychainItemId accessGroup:( NSString * )accessGroup
{
    // The kSecAttrGeneric attribute is used to store a unique string that is used
    // to easily identify and find a keychain item. The string is first converted
    // to an NSData object
    const char* identifierBytes = [keychainItemId cStringUsingEncoding: NSUTF8StringEncoding];
    NSData* keychainItemIdData = [NSData dataWithBytes: identifierBytes length: strlen( identifierBytes )];
    
    //
    // ACCOUNT MUST BE UNIQUE FOR EACH KEYCHAIN ENTRY
    // http://stackoverflow.com/questions/15526646/keychain-cant-find-item-but-then-cant-create-item
    //
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithDictionary: @{
        ( __bridge id )kSecClass: ( __bridge id )kSecClassGenericPassword,
        ( __bridge id )kSecAttrGeneric: keychainItemIdData,
        ( __bridge id )kSecAttrService: keychainItemId,
        ( __bridge id )kSecAttrAccount: keychainItemId,
        ( __bridge id )kSecAttrAccessible: ( __bridge id )kSecAttrAccessibleAfterFirstUnlock,
        ( __bridge id )kSecAttrLabel: @"",
        ( __bridge id )kSecAttrComment: @"",
        ( __bridge id )kSecAttrDescription: @""
    }];
    
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain
    // access group
    if( accessGroup.length > 0 )
    {
#if TARGET_IPHONE_SIMULATOR
        // Ignore the access group if running on the iOS Simulator.
        //
        // Apps that are built for the simulator aren't signed, so there's no keychain access group
        // for the simulator to check. This means that all apps can see all keychain items when run
        // on the simulator.
        //
        // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate will return
        // -25243 (errSecNoAccessForItem) on the simulator.
#else
        keychainQuery[( __bridge id )kSecAttrAccessGroup] = accessGroup;
#endif
    }
    
    return keychainQuery;
}

#pragma mark - Save

+( BOOL )save:( NSString * )keychainItemId data:( id )data
{
    return [self save: keychainItemId data: data accessGroup: nil];
}

+( BOOL )save:( NSString * )keychainItemId data:( id )data accessGroup:( NSString * )accessGroup
{
    if( keychainItemId.length == 0 || data == nil )
        return NO;
    
    NSData *dataToArchive = nil;
    @try
    {
        if( ![data conformsToProtocol: @protocol( NSCoding )] )
            return NO;
        
        dataToArchive = [NSKeyedArchiver archivedDataWithRootObject: data];
    }
    @catch( NSException *ex )
    {
    }
    
    if( dataToArchive == nil )
        return NO;
    
    NSMutableDictionary *keychainQuery = [self genericPasswordKeychainQuery: keychainItemId accessGroup: accessGroup];

    __block OSStatus ret = errSecItemNotFound;
    [serializerQueue addOperations: @[  [NSBlockOperation blockOperationWithBlock: ^{
        
                                            SecItemDelete( ( __bridge CFDictionaryRef )keychainQuery );
        
                                            keychainQuery[( __bridge id )kSecValueData] = dataToArchive;
        
                                            ret = SecItemAdd( ( __bridge CFDictionaryRef )keychainQuery, NULL );
                                     }]]
                 waitUntilFinished: YES];
    
    return ret == errSecSuccess;
}

#pragma mark - Load

+( id )load:( NSString * )keychainItemId
{
    return [self load: keychainItemId accessGroup: nil];
}

+( id )load:( NSString * )keychainItemId accessGroup:( NSString * )accessGroup
{
    if( keychainItemId.length == 0 )
        return nil;

    NSMutableDictionary *keychainQuery = [self genericPasswordKeychainQuery: keychainItemId accessGroup: accessGroup];
    
    keychainQuery[( __bridge id )kSecReturnData] = ( __bridge id )kCFBooleanTrue;
    keychainQuery[( __bridge id )kSecMatchLimit] = ( __bridge id )kSecMatchLimitOne;
    
    __block id ret = nil;
    [serializerQueue addOperations: @[  [NSBlockOperation blockOperationWithBlock: ^{
        
                                            CFDataRef keyData = NULL;
                                            if( SecItemCopyMatching( ( __bridge CFDictionaryRef )keychainQuery, ( CFTypeRef * )&keyData ) == errSecSuccess )
                                            {
                                                @try
                                                {
                                                    ret = [NSKeyedUnarchiver unarchiveObjectWithData: ( __bridge NSData * )keyData];
                                                }
                                                @catch( NSException *ex )
                                                {
                                                }
                                            }
        
                                            if( keyData )
                                                CFRelease( keyData );
                                        }]]
                 waitUntilFinished: YES];

    return ret;
}

#pragma mark - Delete

+( void )delete:( NSString * )keychainItemId
{
    [self delete: keychainItemId accessGroup: nil];
}

+( void )delete:( NSString * )keychainItemId accessGroup:( NSString * )accessGroup
{
    if( keychainItemId.length == 0 )
        return;
    
    NSMutableDictionary *keychainQuery = [self genericPasswordKeychainQuery: keychainItemId accessGroup: accessGroup];
    
    [serializerQueue addOperations: @[  [NSBlockOperation blockOperationWithBlock: ^{
                                            SecItemDelete( ( __bridge CFDictionaryRef )keychainQuery );
                                        }]]
                 waitUntilFinished: YES];
}

@end
