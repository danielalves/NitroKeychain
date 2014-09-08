//
//  NitroKeychainTests.m
//  NitroKeychainTests
//
//  Created by Daniel L. Alves on 5/9/14.
//  Copyright (c) 2014 Daniel L. Alves. All rights reserved.
//

#import <XCTest/XCTest.h>

// NitroKeychain
#import "TNTKeychain.h"

#pragma mark - Constants

static NSString * const kTestServiceName = @"tnt.keychain.test";

#pragma mark - Helper Types

@interface TNTNonSerializable : NSObject
@property( nonatomic, readwrite, strong )NSNumber *n;
@end

@implementation TNTNonSerializable
@end

#pragma mark - NitroKeychainTests Interface

@interface NitroKeychainTests : XCTestCase
@end

#pragma mark - NitroKeychainTests Implementation

@implementation NitroKeychainTests

#pragma mark - Test Lifecycle

-( void )tearDown
{
    [TNTKeychain delete: kTestServiceName];
}

#pragma mark - save Tests

-( void )test_save_saves_data
{
    BOOL saved = [TNTKeychain save: kTestServiceName data: @"Hello World"];
    XCTAssertTrue( saved );
    
    saved = [TNTKeychain save: kTestServiceName data: @{ @"Hello": @"World" }];
    XCTAssertTrue( saved );
    
    saved = [TNTKeychain save: kTestServiceName data: @[ @"Hello", @"World" ]];
    XCTAssertTrue( saved );
    
    saved = [TNTKeychain save: kTestServiceName data: @100];
    XCTAssertTrue( saved );
}

-( void )test_save_updates_data_if_keychainItemId_already_exists
{
    [TNTKeychain save: kTestServiceName data: @"Hello World"];
    BOOL saved = [TNTKeychain save: kTestServiceName data: @"Olá Mundo"];
    XCTAssertTrue( saved );
    XCTAssertEqualObjects( @"Olá Mundo", [TNTKeychain load: kTestServiceName] );
    
    [TNTKeychain save: kTestServiceName data: @{ @"Hello": @"World" }];
    saved = [TNTKeychain save: kTestServiceName data: @{ @"Olá": @"Mundo" }];
    XCTAssertTrue( saved );
    XCTAssertEqualObjects( @{ @"Olá": @"Mundo" }, [TNTKeychain load: kTestServiceName] );
    
    [TNTKeychain save: kTestServiceName data: @[ @"Hello", @"World" ]];
    saved = [TNTKeychain save: kTestServiceName data: @[ @"Olá", @"Mundo" ]];
    XCTAssertTrue( saved );
    NSArray *expected = @[ @"Olá", @"Mundo" ];
    XCTAssertEqualObjects( expected, [TNTKeychain load: kTestServiceName] );
    
    [TNTKeychain save: kTestServiceName data: @100];
    saved = [TNTKeychain save: kTestServiceName data: @500];
    XCTAssertTrue( saved );
    XCTAssertEqualObjects( @500, [TNTKeychain load: kTestServiceName] );
}

-( void )test_save_does_not_throw_on_invalid_keychain_item_ids
{
    XCTAssertNoThrow( [TNTKeychain save: nil data: @100] );
    XCTAssertNoThrow( [TNTKeychain save: @"" data: @500] );
}

-( void )test_save_returns_NO_on_invalid_keychain_item_ids
{
    XCTAssertFalse( [TNTKeychain save: nil data: @100] );
    XCTAssertFalse( [TNTKeychain save: @"" data: @500] );
}

-( void )test_save_does_not_throw_on_nil_data
{
    XCTAssertNoThrow( [TNTKeychain save: kTestServiceName data: nil] );
}

-( void )test_save_returns_NO_on_nil_data
{
    XCTAssertFalse( [TNTKeychain save: kTestServiceName data: nil] );
}

-( void )test_save_does_not_throw_on_invalid_data
{
    TNTNonSerializable *temp = [TNTNonSerializable new];
    temp.n = @99;
    XCTAssertNoThrow( [TNTKeychain save: kTestServiceName data: temp] );
}

-( void )test_save_returns_NO_on_invalid_data
{
    TNTNonSerializable *temp = [TNTNonSerializable new];
    temp.n = @99;
    XCTAssertFalse( [TNTKeychain save: kTestServiceName data: temp] );
}

#pragma mark - load Tests

-( void )test_load_loads_data
{
    [TNTKeychain save: kTestServiceName data: @"Hello World"];
    NSString *string = [TNTKeychain load: kTestServiceName];
    XCTAssertEqualObjects( @"Hello World", string );
    
    [TNTKeychain save: kTestServiceName data: @{ @"Hello": @"World" }];
    NSDictionary *dict = [TNTKeychain load: kTestServiceName];
    XCTAssertEqualObjects( @{ @"Hello": @"World" }, dict );
    
    [TNTKeychain save: kTestServiceName data: @[ @"Hello", @"World" ]];
    NSArray *array = [TNTKeychain load: kTestServiceName];
    NSArray *expected = @[ @"Hello", @"World" ];
    XCTAssertEqualObjects( expected, array );
    
    [TNTKeychain save: kTestServiceName data: @100];
    NSNumber *number = [TNTKeychain load: kTestServiceName];
    XCTAssertEqualObjects( @100, number );
}

-( void )test_load_does_not_throw_on_inexistent_keychain_item
{
    XCTAssertNoThrow( [TNTKeychain load: @"   "] );
    XCTAssertNoThrow( [TNTKeychain load: kTestServiceName] );
}

-( void )test_load_does_not_throw_on_invalid_keychain_item_ids
{
    XCTAssertNoThrow( [TNTKeychain load: nil] );
    XCTAssertNoThrow( [TNTKeychain load: @""] );
}

-( void )test_load_returns_nil_on_inexistent_keychain_item
{
    XCTAssertNil( [TNTKeychain load: @"   "] );
    XCTAssertNil( [TNTKeychain load: kTestServiceName] );
}

-( void )test_load_returns_nil_on_invalid_keychain_item_ids
{
    XCTAssertNil( [TNTKeychain load: nil] );
    XCTAssertNil( [TNTKeychain load: @""] );
}

#pragma mark - delete Tests

-( void )test_delete_deletes_data
{
    [TNTKeychain save: kTestServiceName data: @"Hello World"];
    [TNTKeychain delete: kTestServiceName];
    NSString *string = [TNTKeychain load: kTestServiceName];
    XCTAssertNil( string );
    
    [TNTKeychain save: kTestServiceName data: @{ @"Hello": @"World" }];
    [TNTKeychain delete: kTestServiceName];
    NSDictionary *dict = [TNTKeychain load: kTestServiceName];
    XCTAssertNil( dict );
    
    [TNTKeychain save: kTestServiceName data: @[ @"Hello", @"World" ]];
    [TNTKeychain delete: kTestServiceName];
    NSArray *array = [TNTKeychain load: kTestServiceName];
    XCTAssertNil( array );
    
    [TNTKeychain save: kTestServiceName data: @100];
    [TNTKeychain delete: kTestServiceName];
    NSNumber *number = [TNTKeychain load: kTestServiceName];
    XCTAssertNil( number );
}

-( void )test_delete_does_nothing_on_inexistent_keychain_item
{
    XCTAssertNoThrow( [TNTKeychain delete: @"   "] );
    XCTAssertNoThrow( [TNTKeychain delete: kTestServiceName] );
}

-( void )test_delete_does_nothing_on_invalid_keychain_item_ids
{
    XCTAssertNoThrow( [TNTKeychain delete: nil] );
    XCTAssertNoThrow( [TNTKeychain delete: @""] );
}

@end
