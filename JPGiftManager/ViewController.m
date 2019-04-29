//
//  ViewController.m
//  JPGiftManager
//
//  Created by Keep丶Dream on 2018/3/13.
//  Copyright © 2018年 dong. All rights reserved.
//

#import "ViewController.h"
#import "JPGiftView.h"
#import "JPGiftCellModel.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"

#import <YYModel.h>
#import <UIImageView+WebCache.h>
#import <SDAnimatedImageView+WebCache.h>
#import "SVGA.h"

@interface ViewController ()<JPGiftViewDelegate, SVGAPlayerDelegate>
/** gift */
@property(nonatomic,strong) JPGiftView *giftView;
/** gifimage */
@property(nonatomic,strong) SDAnimatedImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@property (nonatomic, strong) SVGAPlayer *aPlayer;
@property (nonatomic, strong) SVGAParser *parser;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"data" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSArray *data = [responseObject objectForKey:@"data"];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:data];
    self.giftView.dataArray = [NSArray yy_modelArrayWithClass:[JPGiftCellModel class] json:dataArr];
    
    
    _aPlayer = [[SVGAPlayer alloc] init];
    self.aPlayer.hidden = YES;
    [self.view addSubview:self.aPlayer];
    self.aPlayer.delegate = self;
    self.aPlayer.loops = 0;
    self.aPlayer.clearsAfterStop = YES;
    _parser = [[SVGAParser alloc] init];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *HUDView = [[UIVisualEffectView alloc] initWithEffect:blur];
    HUDView.alpha = 0.9f;
    HUDView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.aPlayer addSubview:HUDView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.aPlayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (SDAnimatedImageView *)gifImageView{
    
    if (!_gifImageView) {
        
        _gifImageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(7.5, 0, 360, 225)];
        _gifImageView.hidden = YES;
    }
    return _gifImageView;
}

- (JPGiftView *)giftView{
    
    if (!_giftView) {
        
        _giftView = [[JPGiftView alloc] init];
        _giftView.delegate = self;
    }
    return _giftView;
}

- (IBAction)clickGift:(id)sender {
    
    [self.giftView showGiftView];
}
- (IBAction)changeGifType:(id)sender {
    
    self.changeBtn.selected = !self.changeBtn.selected;
}

- (void)giftViewSendGiftInView:(JPGiftView *)giftView data:(JPGiftCellModel *)model {
    
    NSArray *items = @[
                       @"https://github.com/yyued/SVGA-Samples/blob/master/Walkthrough.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/angel.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/halloween.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/kingset.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true",
                       @"https://github.com/yyued/SVGA-Samples/blob/master/rose.svga?raw=true",
                       ];
    NSArray *items2 = @[@"Walkthrough",@"angel",@"halloween",@"kingset",@"posche",@"rose"];
    
    JPGiftModel *giftModel = [[JPGiftModel alloc] init];
    giftModel.userIcon = model.headIcon;
    giftModel.userName = model.username;
    giftModel.giftName = model.name;
    giftModel.giftImage = model.icon;
    giftModel.giftGifImage = model.icon_gif;
//    giftModel.giftId = model.id;
    giftModel.giftId = model.giftOrder;
    giftModel.defaultCount = 0;
    giftModel.sendCount = 1;
    
    if (self.changeBtn.selected) {
        
        NSLog(@"11111");
        
        [[JPGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
            //结束
            NSLog(@"22222");
        } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
            if ([giftModel.giftId integerValue] < 7) {
                
//                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//                [self.parser parseWithURL:[NSURL URLWithString:items[ ([giftModel.giftId integerValue] - 1) ]] completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
//
//                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                     if (videoItem != nil) {
//                         self.aPlayer.hidden = NO;
//                         self.aPlayer.videoItem = videoItem;
//                         [self.aPlayer startAnimation];
//                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                             self.aPlayer.hidden = YES;
//                             [self.aPlayer stopAnimation];
//                             [self.aPlayer clear];
//                         });
//                     }
//                 } failureBlock:nil];
                
                NSString *myBundlePath = [[NSBundle mainBundle] pathForResource:@"svga" ofType:@"bundle"];
                NSBundle *myBundle = [NSBundle bundleWithPath:myBundlePath];
                [self.parser parseWithNamed:items2[([giftModel.giftId integerValue] - 1)] inBundle:myBundle completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                    
                    if (videoItem != nil) {
                        self.aPlayer.hidden = NO;
                        self.aPlayer.videoItem = videoItem;
                        [self.aPlayer startAnimation];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.aPlayer.hidden = YES;
                            [self.aPlayer stopAnimation];
                            [self.aPlayer clear];
                        });
                    }
                } failureBlock:nil];
            }else{
                //展示gifimage
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    [window addSubview:self.gifImageView];
                    [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.giftGifImage]];
                    self.gifImageView.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.gifImageView.hidden = YES;
                        [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
                        [self.gifImageView removeFromSuperview];
                    });
                });
            }
            
        }];
    }else {
        
        [[JPGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
            //结束
            NSLog(@"333333");
        }];

    }
}


- (void)giftViewGetMoneyInView:(JPGiftView *)giftView {
    
    NSLog(@"充值");
}

@end
