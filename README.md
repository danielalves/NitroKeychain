NitroKeychain
=============

NitroKeychain is a simple abstraction layer to deal with Apple's Keychain on iOS.

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