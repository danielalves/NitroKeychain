/*
 File: TNTKeychainItemWrapper.m
 Abstract:
 Objective-C wrapper for accessing a single keychain item.
 
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "TNTKeychainItemWrapper.h"
#import <Security/Security.h>

/*
 
 These are the default constants and their respective types,
 available for the kSecClassGenericPassword Keychain Item class:
 
 kSecAttrAccessGroup			-		CFStringRef
 kSecAttrCreationDate		    -		CFDateRef
 kSecAttrModificationDate       -		CFDateRef
 kSecAttrDescription			-		CFStringRef
 kSecAttrComment				-		CFStringRef
 kSecAttrCreator				-		CFNumberRef
 kSecAttrType                   -		CFNumberRef
 kSecAttrLabel				    -		CFStringRef
 kSecAttrIsInvisible			-		CFBooleanRef
 kSecAttrIsNegative			    -		CFBooleanRef
 kSecAttrAccount				-		CFStringRef
 kSecAttrService				-		CFStringRef
 kSecAttrGeneric				-		CFDataRef
 
 See the header file Security/SecItem.h for more details.
 
 */

#pragma mark - Implementation

@implementation TNTKeychainItemWrapper

@synthesize keychainItemIdentifier, keychainItemData, genericPasswordQuery, applicationName, automaticallySetsAccount;

-( id )initWithIdentifier:( NSString* )identifier
              accessGroup:( NSString* )accessGroup
          applicationName:( NSString* )appName
  setAccountAutomatically:( BOOL )setAccountAutomatically
{
    self = [super init];
    if( self )
    {
        // Must be the first line inside if, because other methods use the keychainItemIdentifier
        // property
        self.keychainItemIdentifier = identifier;
        self.applicationName = appName;
        self.automaticallySetsAccount = setAccountAutomatically;
        
        // Set up the keychain search dictionary
        genericPasswordQuery = [[NSMutableDictionary alloc] init];
        
        // This keychain item is a generic password
        [genericPasswordQuery setObject: ( __bridge id )kSecClassGenericPassword
                                 forKey: ( __bridge id )kSecClass];
        
        // The kSecAttrGeneric attribute is used to store a unique string that is used
        // to easily identify and find this keychain item. The string is first
        // converted to an NSData object
        NSData* keychainItemId = [self keychainItemIdentifierAsData];
        [genericPasswordQuery setObject: keychainItemId forKey: ( __bridge id )kSecAttrGeneric];
        [genericPasswordQuery setObject: self.applicationName forKey: ( __bridge id )kSecAttrService];
        
        if( automaticallySetsAccount )
        {
            // WE MUST SET AN UNIQUE ACCOUNT FOR EACH KEYCHAIN ENTRY !!!!
            // http://stackoverflow.com/questions/15526646/keychain-cant-find-item-but-then-cant-create-item
            [genericPasswordQuery setObject: self.keychainItemIdentifier forKey: ( __bridge id )kSecAttrAccount];
        }
        
        // The keychain access group attribute determines if this item can be shared
		// amongst multiple apps whose code signing entitlements contain the same keychain access group.
		if( accessGroup != nil )
		{
#if TARGET_IPHONE_SIMULATOR
			// Ignore the access group if running on the iPhone simulator.
			//
			// Apps that are built for the simulator aren't signed, so there's no keychain access group
			// for the simulator to check. This means that all apps can see all keychain items when run
			// on the simulator.
			//
			// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
			// simulator will return -25243 (errSecNoAccessForItem).
#else
			[genericPasswordQuery setObject: accessGroup forKey: ( __bridge id )kSecAttrAccessGroup];
#endif
		}
        
        // Return the attributes of the first match only
        [genericPasswordQuery setObject: ( __bridge id )kSecMatchLimitOne forKey: ( __bridge id )kSecMatchLimit];
        
        // Return the attributes of the keychain item
        [genericPasswordQuery setObject: ( __bridge id )kCFBooleanTrue
                                 forKey: ( __bridge id )kSecReturnAttributes];
        
        // If the keychain item exists, return the attributes of the item
        CFTypeRef nonARCOutDictionary = NULL;
        
        OSStatus keychainErr = noErr;
        keychainErr = SecItemCopyMatching(( __bridge CFDictionaryRef )genericPasswordQuery,
                                          ( CFTypeRef* )&nonARCOutDictionary);
        
        NSDictionary* outDictionary = ( __bridge_transfer NSDictionary* )nonARCOutDictionary;
        
        // Check the return code
        if( keychainErr == noErr )
        {
            // Convert the data dictionary into the format used by the view controller
            self.keychainItemData = [self secItemFormatToDictionary: outDictionary];
        }
        else
        {
            // Put default values into the keychain if no matching
            // keychain item is found
            [self resetKeychainItem];
            
            // Add the generic attribute and the keychain access group.
			[keychainItemData setObject: self.keychainItemIdentifier forKey: ( __bridge id )kSecAttrGeneric];
			if( accessGroup != nil )
			{
#if TARGET_IPHONE_SIMULATOR
				// Ignore the access group if running on the iPhone simulator.
				//
				// Apps that are built for the simulator aren't signed, so there's no keychain access group
				// for the simulator to check. This means that all apps can see all keychain items when run
				// on the simulator.
				//
				// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
				// simulator will return -25243 (errSecNoAccessForItem).
#else
				[keychainItemData setObject: accessGroup forKey: ( __bridge id )kSecAttrAccessGroup];
#endif
			}
        }
    }
    return self;
}

-( void )setObject:( id )inObject forKey:( id )key
{
    if( inObject == nil )
        return;
    
    id currentObject = [keychainItemData objectForKey: key];
    if( ![currentObject isEqual: inObject] )
    {
        [keychainItemData setObject: inObject forKey: key];
        [self writeToKeychain];
    }
}

-( id )objectForKey:( id )key
{
    return [keychainItemData objectForKey: key];
}

// Reset the values in the keychain item, or create a new item if it
// doesn't already exist
-( void )resetKeychainItem
{
    if( !keychainItemData )
    {
        // Allocate the keychainData dictionary if it doesn't exist yet
        self.keychainItemData = [[NSMutableDictionary alloc] init];
    }
    else
    {
        // Format the data in the keychainData dictionary into the format needed for a query
        NSMutableDictionary* tempDictionary = [self dictionaryToSecItemFormat: keychainItemData];
        
        // Delete the keychain item in preparation for resetting the values
		OSStatus junk = SecItemDelete(( __bridge CFDictionaryRef )tempDictionary);
        NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary" );
    }
    
    // Default attributes for keychain item
    [keychainItemData setObject: @"" forKey: ( __bridge id )kSecAttrLabel];
    [keychainItemData setObject: @"" forKey: ( __bridge id )kSecAttrDescription];
    [keychainItemData setObject: self.applicationName forKey: ( __bridge id )kSecAttrService];
    [keychainItemData setObject: @"" forKey: ( __bridge id )kSecAttrComment];
    
    if( automaticallySetsAccount )
    {
        // WE MUST SET AN UNIQUE ACCOUNT FOR EACH KEYCHAIN ENTRY !!!!
        // http://stackoverflow.com/questions/15526646/keychain-cant-find-item-but-then-cant-create-item
        [keychainItemData setObject: self.keychainItemIdentifier forKey: ( __bridge id )kSecAttrAccount];
    }
    
	// Default data for keychain item
    [keychainItemData setObject: @"" forKey: ( __bridge id )kSecValueData];
}

-( NSMutableDictionary* )dictionaryToSecItemFormat:( NSDictionary* )dictionaryToConvert
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for a keychain item search
    
    // Create a dictionary to return populated with the attributes and data
    NSMutableDictionary* returnDictionary = [NSMutableDictionary dictionaryWithDictionary: dictionaryToConvert];
    
    // Add the keychain item class and the generic attribute
    NSData* keychainItemId = [self keychainItemIdentifierAsData];
    [returnDictionary setObject: keychainItemId forKey: ( __bridge id )kSecAttrGeneric];
    
    [returnDictionary setObject:( __bridge id )kSecClassGenericPassword forKey:( __bridge id )kSecClass];
    
    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData
	// This is where to store sensitive data that should be encrypted
    NSString* passwordString = [dictionaryToConvert objectForKey: ( __bridge id )kSecValueData];
    [returnDictionary setObject: [passwordString dataUsingEncoding: NSUTF8StringEncoding]
                         forKey: ( __bridge id )kSecValueData];
    
    return returnDictionary;
}

-( NSMutableDictionary* )secItemFormatToDictionary:( NSDictionary* )dictionaryToConvert
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for the keychain item
    
    // Create a return dictionary populated with the attributes
    NSMutableDictionary* returnDictionary = [NSMutableDictionary dictionaryWithDictionary: dictionaryToConvert];
    
    // To acquire the password data from the keychain item,
    // first add the search key and class attribute required to obtain the password
    [returnDictionary setObject: ( __bridge id )kCFBooleanTrue forKey:( __bridge id )kSecReturnData];
    [returnDictionary setObject: ( __bridge id )kSecClassGenericPassword forKey:( __bridge id )kSecClass];
    
    // Then call Keychain Services to get the password
    CFTypeRef nonARCPasswordData = NULL;
    if( SecItemCopyMatching(( __bridge CFDictionaryRef )returnDictionary, ( CFTypeRef* )&nonARCPasswordData) == noErr )
    {
        NSData* passwordData = ( __bridge_transfer NSData* )nonARCPasswordData;
        
        // Remove the kSecReturnData key, because we don't need it anymore
        [returnDictionary removeObjectForKey: ( __bridge id )kSecReturnData];
        
        // Convert the password to an NSString and add it to the return dictionary
        NSString* password = [[NSString alloc] initWithBytes: [passwordData bytes]
                                                      length: [passwordData length]
                                                    encoding: NSUTF8StringEncoding];
        
        [returnDictionary setObject: password forKey: ( __bridge id )kSecValueData];
    }
    else
    {
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }
    
	return returnDictionary;
}

// This method modifies an existing keychain item, or--if the item does not already
// exist--creates a new keychain item with the new attribute value plus default
// values for the other attributes
-( void )writeToKeychain
{
    CFTypeRef nonARCAttributes = NULL;
	OSStatus result = SecItemCopyMatching(( __bridge CFDictionaryRef )genericPasswordQuery, ( CFTypeRef* )&nonARCAttributes);
    if( result == noErr )
    {
        NSDictionary* attributes = ( __bridge_transfer NSDictionary* )nonARCAttributes;
        
        // First, get the attributes returned from the keychain and add them to the
        // dictionary that controls the update
        NSMutableDictionary* updateItem = [NSMutableDictionary dictionaryWithDictionary: attributes];
        
        // Second, get the class value from the generic password query dictionary and
        // add it to the updateItem dictionary
        [updateItem setObject: [genericPasswordQuery objectForKey: ( __bridge id )kSecClass]
                       forKey: ( __bridge id )kSecClass];
        
        // Lastly, we need to set up the updated attribute list being careful to remove
        // the class -- it's not a keychain attribute
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat: keychainItemData];
        [tempCheck removeObjectForKey: ( __bridge id )kSecClass];
		
#if TARGET_IPHONE_SIMULATOR
		// Remove the access group if running on the iPhone simulator.
		//
		// Apps that are built for the simulator aren't signed, so there's no keychain access group
		// for the simulator to check. This means that all apps can see all keychain items when run
		// on the simulator.
		//
		// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
		// simulator will return -25243 (errSecNoAccessForItem).
		//
		// The access group attribute will be included in items returned by SecItemCopyMatching,
		// which is why we need to remove it before updating the item.
		[tempCheck removeObjectForKey: ( __bridge id )kSecAttrAccessGroup];
#endif
        
        // You can update only a single keychain item at a time
        result = SecItemUpdate(( __bridge CFDictionaryRef )updateItem, ( __bridge CFDictionaryRef )tempCheck);
		NSAssert( result == noErr, @"Couldn't update the Keychain Item" );
    }
    else
    {
        // No previous item found; add the new item
        // The new value was added to the keychainData dictionary in the mySetObject routine,
        // and the other values were added to the keychainData dictionary previously
        
        // No pointer to the newly-added items is needed, so pass NULL for the second parameter
        result = SecItemAdd(( __bridge CFDictionaryRef )[self dictionaryToSecItemFormat: keychainItemData], NULL);
		NSAssert( result == noErr, @"Couldn't add the Keychain Item" );
    }
}

#pragma mark - Helpers

-( NSData* )keychainItemIdentifierAsData
{
    const char* identifierBytes = [self.keychainItemIdentifier cStringUsingEncoding: NSUTF8StringEncoding];
    return [NSData dataWithBytes: identifierBytes length: strlen( identifierBytes )];
}

@end


















































