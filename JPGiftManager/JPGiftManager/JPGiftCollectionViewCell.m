//
//  JPGiftCollectionViewCell.m
//  JPGiftManager
//
//  Created by Keep丶Dream on 2018/3/13.
//  Copyright © 2018年 dong. All rights reserved.
//

#import "JPGiftCollectionViewCell.h"
#import "JPGiftCellModel.h"
#import "UIImageView+WebCache.h"

@interface JPGiftCollectionViewCell()
/** bg */
@property(nonatomic,strong) UIView *bgView;
/** image */
@property(nonatomic,strong) UIImageView *giftImageView;
/** name */
@property(nonatomic,strong) UILabel *giftNameLabel;
/** money */
@property(nonatomic,strong) UILabel *moneyLabel;
/** moneyicon */
@property(nonatomic,strong) UIImageView *moneyImage;

@end

@implementation JPGiftCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self p_SetUI];
    }
    return self;
}

#pragma mark -设置UI
- (void)p_SetUI {
    
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor clearColor];
    self.bgView.layer.borderWidth = 0;
    self.bgView.layer.borderColor = [UIColor colorWithRed:253/255.0 green:161/255.0 blue:40/255.0 alpha:1.0].CGColor;
    [self.contentView addSubview:self.bgView];
    
    self.giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-70)*0.5, 11, 70, 55)];
    [self.contentView addSubview:self.giftImageView];
    
    self.giftNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.giftImageView.frame), self.bounds.size.width, 16)];
    self.giftNameLabel.text = @"礼物名";
    self.giftNameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.giftNameLabel.textAlignment = NSTextAlignmentCenter;
    self.giftNameLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.giftNameLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.giftNameLabel.frame), 30, 16)];
    moneyLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    moneyLabel.font = [UIFont systemFontOfSize:12];
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel = moneyLabel;
    [self.contentView  addSubview:moneyLabel];
    
    UIImageView *moneyImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(moneyLabel.frame)-4, moneyLabel.frame.origin.y+4, 10, 10)];
    self.moneyImage = moneyImage;
    [self.contentView  addSubview:moneyImage];
}

- (void)setModel:(JPGiftCellModel *)model {
    
    _model = model;
    [self.giftImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"Cece_live_star_small"]];
    self.giftNameLabel.text = model.name;
    
    if (model.isSelected) {
        self.bgView.layer.borderWidth = 1;
//        self.bgView.layer.borderColor = [UIColor colorWithRed:253/255.0 green:161/255.0 blue:40/255.0 alpha:1.0].CGColor;
    }else{
        self.bgView.layer.borderWidth = 0;
//        self.bgView.layer.borderColor = [UIColor colorWithRed:253/255.0 green:161/255.0 blue:40/255.0 alpha:1.0].CGColor;
    }
    BOOL isCcb = [model.cost_type boolValue];
    UIImage *img = [UIImage imageNamed:isCcb ? @"Live_Red_ccb" : @"Cece_live_star_small"];
    self.moneyImage.image = img;
    
//    NSString *moneyValue = [NSString stringWithFormat:@"%zd",[model.value integerValue]];
    self.moneyLabel.text = model.value;
    
    CGSize size = [model.value sizeWithAttributes:@{NSFontAttributeName:self.moneyLabel.font}];
    CGFloat w = size.width+1;
    CGFloat labelX = (self.contentView.bounds.size.width-w+4+10)*0.5;
    self.moneyLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.giftNameLabel.frame), w, 16);
    CGFloat imageX = CGRectGetMinX(self.moneyLabel.frame)-4-10;
    self.moneyImage.frame = CGRectMake(imageX, self.moneyLabel.frame.origin.y+4, 10, 10);
}

@end
