//
//  IMRootViewController.m
//  IMNativeApp
//
//  Copyright (c) 2014 inmobi. All rights reserved.
//

#define RGBToUIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

#import "IMRootViewController.h"
#import "IMNewsViewController.h"
#import "IMFeedViewController.h"
#import "IMCoverFlowViewController.h"
#import "IMBoardViewController.h"

#define TABLE_CELL_ELEMENT_WIDTH_PADDING 10
#define TABLE_CELL_ELEMENT_HEIGHT_PADDING 10
#define TEXT_SEPERATION_PADDING 5
#define IMG_TAG 0xAB
#define TEXT_TAG 0xEF

@interface IMRootViewController ()
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) IMNewsViewController *newsViewController;
@property(nonatomic, strong) IMFeedViewController *feedViewController;
@property(nonatomic, strong) IMCoverFlowViewController *coverflowViewController;
@property(nonatomic, strong) IMBoardViewController *boardViewController;
@property CGRect cellRect;
@end

@implementation IMRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _tableView.frame = self.view.bounds;
    [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.tintColor = RGBToUIColor(101, 151, 213);
    self.navigationItem.title = @"Native Ads";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setSeparatorColor:RGBToUIColor(234, 111, 30)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    CGFloat heightOfCell = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    CGRect cellBounds = CGRectMake(0, 0, self.view.frame.size.width, heightOfCell);
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIView* prevImgView = [cell viewWithTag:IMG_TAG];
    UIView* prevTextView = [cell viewWithTag:TEXT_TAG];
    if (prevImgView!=nil && prevTextView!=nil) {
        [prevImgView removeFromSuperview]; //#warning TODO TRY RESUING THE SAME VIEWS INSTEAD OF REMOVING THEM
        [prevTextView removeFromSuperview];
    }
    cell.frame = cellBounds;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //Set Inmobi logo alternate in cells
    UIImageView *imgView;
    if ((indexPath.row)%2==0) {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake((cellBounds.size.width)/2 - TABLE_CELL_ELEMENT_WIDTH_PADDING, TABLE_CELL_ELEMENT_HEIGHT_PADDING, (cellBounds.size.width)/2, (cellBounds.size.height)/2 - 2 * TABLE_CELL_ELEMENT_HEIGHT_PADDING)];
        
    }else {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 + TABLE_CELL_ELEMENT_WIDTH_PADDING, TABLE_CELL_ELEMENT_HEIGHT_PADDING, (cellBounds.size.width)/2, (cellBounds.size.height)/2 - 2* TABLE_CELL_ELEMENT_HEIGHT_PADDING)];
    }
    imgView.tag = IMG_TAG;
    imgView.image = [UIImage imageNamed:@"inmobi-logo.png"];
    [cell addSubview:imgView];
    //Create label for each section
    UILabel *label = [[UILabel alloc] init];
    if ((indexPath.row)%2==0) {
        label = [[UILabel alloc] initWithFrame:CGRectMake((cellBounds.size.width)/2 - TABLE_CELL_ELEMENT_WIDTH_PADDING, (cellBounds.size.height)/2 - TABLE_CELL_ELEMENT_HEIGHT_PADDING, (cellBounds.size.width)/2, (cellBounds.size.height)/2)];
        label.textAlignment = NSTextAlignmentRight;
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0 + TABLE_CELL_ELEMENT_WIDTH_PADDING, (cellBounds.size.height)/2 - TABLE_CELL_ELEMENT_HEIGHT_PADDING , (cellBounds.size.width)/2, (cellBounds.size.height)/2)];
        label.textAlignment = NSTextAlignmentLeft;
    }
    label.tag = TEXT_TAG;
    //Set label title
    UIFont* font = [UIFont fontWithName:@"Open Sans" size:cellBounds.size.height/2 - 20];
    label.font = font;
    label.textColor = [UIColor grayColor];
    
    NSString* labelText = nil;

    switch (indexPath.row) {
        case 0:
            labelText = @"News";
            break;
        case 1:
            labelText = @"Feed";
            break;
        case 2:
            labelText = @"Flow";
            break;
        case 3:
            labelText = @"Board";
            break;
        default:
            break;
    }
    
    CGSize sizeOfLabel = [labelText sizeWithFont:label.font];
    label.text = labelText;
    CGRect frameForLabel = CGRectMake(label.frame.origin.x, label.frame.origin.y, sizeOfLabel.width, sizeOfLabel.height);
    label.frame = frameForLabel;
    [cell addSubview:label];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            _newsViewController = [[IMNewsViewController alloc] initWithNibName:@"IMNewsViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:_newsViewController animated:YES];
            break;
        case 1:
            _feedViewController = [[IMFeedViewController alloc] init];
            [self.navigationController pushViewController:_feedViewController animated:YES];
            break;
        case 2:
            _coverflowViewController = [[IMCoverFlowViewController alloc] init];
            [self.navigationController pushViewController:_coverflowViewController animated:YES];
            break;
        case 3:
            _boardViewController = [[IMBoardViewController alloc] init];
            [self.navigationController pushViewController:_boardViewController animated:YES];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
