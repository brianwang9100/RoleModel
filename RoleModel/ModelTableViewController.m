//
//  ModelTableViewController.m
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "ModelTableViewController.h"

@interface ModelTableViewController ()

@end

@implementation ModelTableViewController {
    NSUserDefaults *_defaults;
    NSMutableArray *_modelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaults = [NSUserDefaults standardUserDefaults];
    [self setupTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) setupTable {
    if ([_defaults objectForKey:@"Models"] == nil) {
        _modelArray = [NSMutableArray arrayWithObject:nil];
        [self saveModels];
    } else {
        _modelArray = [_defaults objectForKey:@"Models"];
    }
}

-(void) saveModels {
    [_defaults setObject:_modelArray forKey:@"Models"];
    [_defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modelArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    int selectedRow = indexPath.row;
//    NSLog(@"touch on row %d", selectedRow);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"ModelTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    Model *model = [_modelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.nameOfModel;
    cell.detailTextLabel.text = model.modelDescription;
    cell.accessoryType = UITableViewCellStyleSubtitle;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addModel"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        NewModelViewController *newModelViewController = [navigationController viewControllers][0];
        newModelViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"compareModels"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        CompareModelViewController *compareModelViewController = [navigationController viewControllers][0];
        compareModelViewController.delegate = self;
//        compareModelViewController.teacher = [_modelArray
    }
}

#pragma mark - PlayerDetailsViewControllerDelegate

- (void)newModelViewControllerDidClose:(NewModelViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)compareModelViewControllerDidClose:(CompareModelViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];

}


@end
