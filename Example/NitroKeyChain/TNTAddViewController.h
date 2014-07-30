//
//  TNTAddViewController.h
//  NitroKeyChain
//
//  Created by Gustavo Barbosa on 7/30/14.
//  Copyright (c) 2014 Gustavo Barbosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TNTAddViewController;

@protocol TNTAddViewControllerDelegate <NSObject>

@optional
- (void)tnt_addViewController:(TNTAddViewController *)viewController
            didAddItemWithKey:(NSString *)key
                        value:(NSString *)value;
@end


@interface TNTAddViewController : UIViewController

@property (nonatomic, weak) id<TNTAddViewControllerDelegate> delegate;

@end
