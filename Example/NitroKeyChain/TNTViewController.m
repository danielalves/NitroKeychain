//
//  TNTViewController.m
//  NitroKeyChain
//
//  Created by Gustavo Barbosa on 07/30/2014.
//  Copyright (c) 2014 Gustavo Barbosa. All rights reserved.
//

#import "TNTViewController.h"
#import "TNTAddViewController.h"
#import "TNTAppDelegate.h"

@interface TNTViewController () <UITableViewDataSource, TNTAddViewControllerDelegate>
{
    NSMutableArray *keychainItems;
    TNTKeychainItemWrapper *keychain;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation TNTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    keychainItems = [NSMutableArray array];
    keychain = [(TNTAppDelegate *)[[UIApplication sharedApplication] delegate] sharedKeychain];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [keychainItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KeychainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = keychainItems[indexPath.row];
    
    cell.textLabel.text = item[@"key"];
    cell.detailTextLabel.text = [keychain objectForKey:item[@"key"]];
    
    return cell;
}

#pragma mark - TNTAddViewControllerDelegate

- (void)tnt_addViewController:(TNTAddViewController *)viewController didAddItemWithKey:(NSString *)key value:(NSString *)value
{
    NSDictionary *item = @{@"key": key, @"value": value};
    [keychainItems addObject:item];
    [_tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowModal"]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        TNTAddViewController *addItemVC = [navigationVC.viewControllers firstObject];
        addItemVC.delegate = self;
    }
}

- (IBAction)backToKeychainItemsList:(UIStoryboardSegue *)segue {
    // do nothing.
}


@end
