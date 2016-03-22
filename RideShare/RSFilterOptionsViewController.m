//
//  RSFilterOptionsViewController.m
//  
//
//  Created by Reddy on 02/02/16.
//
//

#import "RSFilterOptionsViewController.h"

@interface RSFilterOptionsViewController ()

@end

@implementation RSFilterOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"All";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Pickups";
    }
    else
    {
        cell.textLabel.text = @"Pick Me Ups";
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterOptionSelectedNotification" object:@{@"item" : [NSString stringWithFormat:@"%li", (long)indexPath.row]}];
   // NSLog(@"Bla bla");
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return tableView.frame.size.height / 3;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
