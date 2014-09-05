NitroKeychain
=============
[![Version](http://cocoapod-badges.herokuapp.com/v/NitroKeychain/badge.png)](http://cocoadocs.org/docsets/NitroKeychain)
[![Platform](http://cocoapod-badges.herokuapp.com/p/NitroKeychain/badge.png)](http://cocoadocs.org/docsets/NitroKeychain)
[![TravisCI](https://travis-ci.org/danielalves/NitroKeychain.svg?branch=master)](https://travis-ci.org/danielalves/NitroKeychain)

**NitroKeychain** is a simple abstraction layer to deal with Apple's Keychain on iOS.

It has basically 3 operations: `save`, `load` and `delete` items from Keychain, as you can see below:

Saving
------

```objc
[TNTKeychain save:@"com.myapp.token" 
             data:@"my-ultra-secret-token"];
```

Loading
-------
```objc
NSString *secretKey = [TNTKeychain load:@"com.myapp.token"];
NSLog(@"%@", secretKey);
```

Deleting
--------
```objc
[TNTKeychain delete:@"com.myapp.token"];
```

Simple as that :+1:

Requirements
------------

iOS 6.0 or higher, ARC only

Installation
------------

**NitroKeychain** is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'NitroKeychain'
```

License
-------

**NitroKeychain** is available under the MIT license. See the LICENSE file for more info.
