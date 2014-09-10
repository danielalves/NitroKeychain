NitroKeychain
=============
[![Version](http://cocoapod-badges.herokuapp.com/v/NitroKeychain/badge.png)](http://cocoadocs.org/docsets/NitroKeychain)
[![Platform](http://cocoapod-badges.herokuapp.com/p/NitroKeychain/badge.png)](http://cocoadocs.org/docsets/NitroKeychain)
<!-- [![TravisCI](https://travis-ci.org/danielalves/NitroKeychain.svg?branch=master)](https://travis-ci.org/danielalves/NitroKeychain) -->

**NitroKeychain** is a thin, yet powerful, abstraction layer on top of iOS keychain that provides commonly needed features. **NitroKeychain** is also thread safe.

There are 3 operations: `save`, `load` and `delete`, as you can see below:

Saving
------

```objc
[TNTKeychain save: @"com.myapp.service.id" 
             data: @"my-ultra-secret-token"];
             
// Or, if you want to make this item available across apps, specify 
// an access group:
[TNTKeychain save: @"com.myapp.service.id" 
             data: @"my-ultra-secret-token"
      accessGroup: @"super-company"];

```

- All keychain items are stored using the kSecClassGenericPassword Keychain Item class.
- `data` can be any value compatible with `NSKeyedArchiver`/`NSKeyedUnarchiver`.
- If there is already some data associated with a keychain item ID, it will be updated.

Loading
-------

```objc
NSString *token = [TNTKeychain load: @"com.myapp.service.id"];
NSLog( @"%@", token );
```

Deleting
--------

```objc
[TNTKeychain delete: @"com.myapp.service.id"];
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

Authors
-------

- [Daniel L. Alves](http://github.com/danielalves) ([@alveslopesdan](https://twitter.com/alveslopesdan))
- [Gustavo Barbosa](http://github.com/barbosa) ([@gustavocsb](https://twitter.com/gustavocsb))

License
-------

**NitroKeychain** is available under the MIT license. See the LICENSE file for more info.
