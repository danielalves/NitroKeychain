
#import <UIKit/UIKit.h>

/**
 *  TNTKeychain is a thin, yet powerful, abstraction layer on top of iOS keychain that provides
 *  commonly needed features.
 *
 *  All keychain items are stored using the kSecClassGenericPassword Keychain Item class.
 *
 *  This class is thread safe.
 */
@interface TNTKeychain : NSObject

/**
 *  Stores data into the keychain associating it to keychainItemId. If there is
 *  already some data associated with keychainItemId, updates it.
 *
 *  @param keychainItemId The id of the keychain item. This value must be unique for each keychain
 *                        entry.
 *
 *  @param data           The data to be stored associated with keychainItemId. Every object compatible
 *                        with NSKeyedArchiver/NSKeyedUnarchiver is valid.
 *
 *  @return YES if data was saved successfully to the keychain. NO otherwise.
 *
 *  @see +save:data:accessGroup:
 *  @see +load:
 *  @see +load:accessGroup:
 *  @see +delete:
 *  @see +delete:accessGroup:
 */
+( BOOL )save:( NSString * )keychainItemId data:( id )data;

/**
 *  Stores data into the keychain associating it to keychainItemId. If there is
 *  already some data associated with keychainItemId, updates it.
 *
 *  @param keychainItemId The id of the keychain item. This value must be unique for each keychain
 *                        entry.
 *
 *  @param data           The data to be stored associated with keychainItemId. Every object compatible
 *                        with NSKeyedArchiver/NSKeyedUnarchiver is valid.
 *
 *  @param accessGroup    The access group of the keychain item. The keychain access group attribute
 *                        determines if an item can be shared amongst multiple apps whose code
 *                        signing entitlements contain the same keychain access group.
 *
 *  @return YES if the keychain item data was saved successfully. NO otherwise or if keychainItemId
 *          and/or data are invalid.
 *
 *  @see +save:data:
 *  @see +load:
 *  @see +load:accessGroup:
 *  @see +delete:
 *  @see +delete:accessGroup:
 */
+( BOOL )save:( NSString * )keychainItemId data:( id )data accessGroup:( NSString * )accessGroup;

/**
 *  Loads the data associated with a keychain item.
 *
 *  @param keychainItemId The id of the keychain item whose data must be loaded.
 *
 *  @return The data associated with a keychain item whose id is keychainItemId. Returns nil if
 *          keychainItemId is invalid or inexistent.
 *
 *  @see +save:data:
 *  @see +save:data:accessGroup:
 *  @see +load:accessGroup:
 *  @see +delete:
 *  @see +delete:accessGroup:
 */
+( id )load:( NSString * )keychainItemId;

/**
 *  Loads the data associated with a keychain item.
 *
 *  @param keychainItemId The id of the keychain item whose data must be loaded.
 *
 *  @param accessGroup    The access group of the keychain item.
 *
 *  @return The data associated with a keychain item whose id is keychainItemId. Returns nil if
 *          keychainItemId is invalid or inexistent.
 *
 *  @see +save:data:
 *  @see +save:data:accessGroup:
 *  @see +load:
 *  @see +delete:
 *  @see +delete:accessGroup:
 */
+( id )load:( NSString * )keychainItemId accessGroup:( NSString * )accessGroup;

/**
 *  Deletes the specified keychain item. This method does nothing if keychainItemId
 *  is invalid or inexistent.
 *
 *  @param keychainItemId The id of the keychain item which must be deleted.
 *
 *  @see +save:data:
 *  @see +save:data:accessGroup:
 *  @see +load:
 *  @see +load:accessGroup:
 *  @see +delete:accessGroup:
 */
+( void )delete:( NSString * )keychainItemId;

/**
 *  Deletes the specified keychain item. This method does nothing if keychainItemId
 *  is invalid or inexistent.
 *
 *  @param keychainItemId The id of the keychain item which must be deleted.
 *
 *  @param accessGroup    The access group of the keychain item.
 *
 *  @see +save:data:
 *  @see +save:data:accessGroup:
 *  @see +load:
 *  @see +load:accessGroup:
 *  @see +delete:
 */
+( void )delete:( NSString * )keychainItemId accessGroup:( NSString * )accessGroup;

@end
