//
//  FAVTagsView.h
//  Tools
//
//  Created by 冯鸿杰 on 2018/6/8.
//  Copyright © 2018年 vimfung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VITagField.h"

@class VITagListView;
@class VITagView;

//typedef void (^ContentHeightBlock)(CGFloat height);
typedef void (^ContentHeightBlock)(VITagListView * view, CGFloat height);
typedef void (^TagItemChangeBlock)(NSArray *tags);
typedef void (^TagEditBlock)(VITagListView * view, VITagView *tagView);
/**
 标签视图
 */
@interface VITagListView : UIScrollView

/**
 标签列表
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *tags;

/**
 错误标签列表
 */
@property (nonatomic, strong) NSArray<NSString *> *errorTags;

/**
 标签数组
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *tagArray;

/**
 文本输入框提示信息
 */
@property (nonatomic, copy) NSString *textFieldPlaceholder;

/**
 单个标签最大长度
 */
@property (nonatomic) NSInteger tagMaxLength;

/**
 标签项高度
 */
@property (nonatomic) CGFloat itemHeight;

/**
 标签间距
 */
@property (nonatomic) CGFloat itemGap;

/**
 标签左上边距离
 */
@property (nonatomic) CGFloat itemLeadGap;


/**
 标签输入文本框
 */
@property (nonatomic, strong) VITagField *tagInputField;


@property (nonatomic, copy) ContentHeightBlock block;

@property (nonatomic, copy) TagItemChangeBlock tagChangeBlock;

@property (nonatomic, copy) TagEditBlock tagEditBlock;
/**
 内容初始高度
 */
@property (nonatomic) CGFloat minHeight;

+ (CGFloat) staticHeight:(CGPoint)start width:(CGFloat) width tags:(NSMutableArray<NSString *>*)tagArray;

- (void)_reloadPreData:(BOOL)endEdit;

- (void)errorAlert:(NSArray<NSString *>*)tagArray;
@end
