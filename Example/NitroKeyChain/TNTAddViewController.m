//
//  TNTAddViewController.m
//  NitroKeyChain
//
//  Created by Gustavo Barbosa on 7/30/14.
//  Copyright (c) 2014 Gustavo Barbosa. All rights reserved.
//

#import "TNTAddViewController.h"
#import "TNTAppDelegate.h"

@interface TNTAddViewController ()
{
    TNTKeychainItemWrapper *keychain;
}
@property (nonatomic, weak) IBOutlet UITextField *keyTextField;
@property (nonatomic, weak) IBOutlet UITextField *valueTextField;
@end

@implementation TNTAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    keychain = [(TNTAppDelegate *)[[UIApplication sharedApplication] delegate] sharedKeychain];
}

- (IBAction)saveButtonDidTap
{
    NSString *key = [_keyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *value = [_valueTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([key isEqualToString:@""] || [value isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Ops"
                                   message:@"Não vale campo vazio"
                                  delegate:nil
                         cancelButtonTitle:@"ok"
                         otherButtonTitles:nil] show];
    } else {
        // Store in keychain
        [keychain setObject:value forKey:key];
        
        if ([self.delegate respondsToSelector:@selector(tnt_addViewController:didAddItemWithKey:value:)]) {
            
            // call the delegate passing saved item
            [self.delegate tnt_addViewController:self
                           didAddItemWithKey:key
                                       value:value];
        }
        
        [self performSegueWithIdentifier:@"CloseModal" sender:nil];
    }
}

@end
