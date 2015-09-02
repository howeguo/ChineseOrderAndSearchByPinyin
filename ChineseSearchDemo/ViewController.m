//
//  ViewController.m
//  ChineseSearchDemo
//
//  Created by howeguo on 9/2/15.
//  Copyright (c) 2015 howeguo. All rights reserved.
//

#import "ViewController.h"
#import "ZYPinYinSearch.h"
#import "pinyin.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UISearchBar *searchBar;

@property(nonatomic,strong) NSMutableArray *displayArray;
@property(nonatomic,strong) NSArray *dataArray;
@property(nonatomic,strong) NSMutableArray *tempOtherArr;
@property(nonatomic,strong) NSMutableArray *allKeys;
@property(nonatomic,strong) NSArray *keys;
@property(nonatomic,strong) NSMutableDictionary *resultDict;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    

   
    _allKeys = [NSMutableArray array];
    _resultDict = [NSMutableDictionary dictionary];
    _keys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    
    
    _dataArray = @[@"你好",@"张三",@"李四",@"王五",@"刘备",@"json",@"abc",@"张玉",@"望天",@"haha",@"哈哈",@"艾玛",@"15178929",@"😄",@"必须得",@"才把你"];
    _displayArray = [NSMutableArray arrayWithArray:_dataArray];
    _resultDict = [self sortedArrayWithPinYinDic:_displayArray];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma -mark searchBarDelegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:@""]) {
        _displayArray = [NSMutableArray arrayWithArray:_dataArray];
    }
    else{
        _displayArray = [NSMutableArray arrayWithArray:[ZYPinYinSearch searchWithOriginalArray:_dataArray andSearchText:searchBar.text andSearchByPropertyName:@"name"]];
    }
    _resultDict = [self sortedArrayWithPinYinDic:_displayArray];

    [_tableView reloadData];
    [_searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchBar.text isEqualToString:@""]) {
        _displayArray = [NSMutableArray arrayWithArray:_dataArray];
    }
    else{
        _displayArray = [NSMutableArray arrayWithArray:[ZYPinYinSearch searchWithOriginalArray:_dataArray andSearchText:searchBar.text andSearchByPropertyName:@"name"]];
    }
    _resultDict = [self sortedArrayWithPinYinDic:_displayArray];

    [_tableView reloadData];
}

#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
-(NSString *) hanZiToPinYinWithString:(NSString *)hanZi
{
    if(!hanZi) return nil;
    NSString *pinYinResult=[NSString string];
    for(int j=0;j<hanZi.length;j++){
        NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    return pinYinResult;
}

/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */
-(NSMutableDictionary *) sortedArrayWithPinYinDic:(NSArray *) data
{
    if(!data) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    _tempOtherArr = nil;
    _tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (NSString *str in data) {
            
            NSString *pyResult = [self hanZiToPinYinWithString:str];
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]){
                [tempArr addObject:str];
            }
            
            if(isReturn) continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:str];
            }
        }
        if(![tempArr count]) continue;
        [returnDic setObject:tempArr forKey:key];
        
    }
    if([_tempOtherArr count])
        [returnDic setObject:_tempOtherArr forKey:@"#"];
    
    
    _allKeys = [[[returnDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {return [obj1 compare:obj2 options:NSNumericSearch];}] mutableCopy];
    
    if([_tempOtherArr count])
    {
        [_allKeys removeObject:@"#"];
        [_allKeys addObject:@"#"];
    }
    
    //加入放大镜图标
    //[_allKeys insertObject:[NSString stringWithFormat:@"%C%C", 0xD83D, 0xDD0D] atIndex:0];
    return returnDic;
}

#pragma mark - UITableView DataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *key = [_allKeys objectAtIndex:section];
    NSArray *arr = [_resultDict objectForKey:key];
    return [arr count];
}


//pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return _allKeys;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *key = [_allKeys objectAtIndex:section];
    return key;
    
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *key = [_allKeys objectAtIndex:indexPath.section];
    NSArray *arr = [_resultDict objectForKey:key];
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
