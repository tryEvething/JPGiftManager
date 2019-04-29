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

#define GifAnimateDuration 3

@interface ViewController ()<JPGiftViewDelegate, SVGAPlayerDelegate>
/** gift */
@property(nonatomic,strong) JPGiftView *giftView;
/** gifimage */
@property(nonatomic,strong) SDAnimatedImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@property (nonatomic, strong) SVGAPlayer *aPlayer;
@property (nonatomic, strong) SVGAParser *parser;

@property (nonatomic, strong) NSOperationQueue *queue;

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
    
    // 1.创建队列
    _queue = [[NSOperationQueue alloc] init];
    // 2.设置最大并发操作数
    _queue.maxConcurrentOperationCount = 1; // 串行队列
    
    [self.view addSubview:self.gifImageView];
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
    
    //    NSArray *items = @[
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/Walkthrough.svga?raw=true",
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/angel.svga?raw=true",
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/halloween.svga?raw=true",
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/kingset.svga?raw=true",
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/posche.svga?raw=true",
    //                       @"https://github.com/yyued/SVGA-Samples/blob/master/rose.svga?raw=true",
    //                       ];
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
        
        [[JPGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
            //结束
            NSLog(@"22222");
        } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
            // 两种加载方式,一种svga http://svga.io/  另一种加载Gif图
            if ([giftModel.giftId integerValue] < 7) {
                NSString *myBundlePath = [[NSBundle mainBundle] pathForResource:@"svga" ofType:@"bundle"];
                NSBundle *myBundle = [NSBundle bundleWithPath:myBundlePath];
                [self.parser parseWithNamed:items2[([giftModel.giftId integerValue] - 1)] inBundle:myBundle completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                    if (videoItem) {
                        //取消上一个的消失动画,直接加载下一个动画
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenGiftShowView) object:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.aPlayer.hidden = NO;
                        });
                        
                        self.aPlayer.videoItem = videoItem;
                        [self.aPlayer startAnimation];
                        
                        [self performSelector:@selector(hiddenGiftShowView) withObject:nil afterDelay:GifAnimateDuration];
                    }
                } failureBlock:nil];
            }else{
                //展示gifimage
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenGiftShowView) object:nil];
                    [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.giftGifImage]];
                    self.gifImageView.hidden = NO;
                    
                    [self performSelector:@selector(hiddenGiftShowView2) withObject:nil afterDelay:GifAnimateDuration];
                });
            }
        }];
    }else {
        // 无特效显示
        //        [[JPGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
        //            //结束
        //            NSLog(@"333333");
        //        }];
        
        // 更换特效为顺序队列,当前一个显示完后再显示下一个
        [[JPGiftShowManager sharedManager] showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
            //结束
            NSLog(@"22222");
        } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
            
            
            if ([giftModel.giftId integerValue] < 7) {
                NSString *myBundlePath = [[NSBundle mainBundle] pathForResource:@"svga" ofType:@"bundle"];
                NSBundle *myBundle = [NSBundle bundleWithPath:myBundlePath];
                [self.parser parseWithNamed:items2[([giftModel.giftId integerValue] - 1)] inBundle:myBundle completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
                    [self.queue addOperationWithBlock:^{
                        if (videoItem) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.aPlayer.hidden = NO;
                            });
                            
                            self.aPlayer.videoItem = videoItem;
                            [self.aPlayer startAnimation];
                            
                            [NSThread sleepForTimeInterval:GifAnimateDuration];
                            [self hiddenGiftShowView];
                        }
                    }];
                } failureBlock:nil];
            }else{
                //展示gifimage
                [self.queue addOperationWithBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.giftGifImage]];
                        self.gifImageView.hidden = NO;
                    });
                    
                    [NSThread sleepForTimeInterval:GifAnimateDuration];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hiddenGiftShowView2];
                    });
                }];
            }
        }];
    }
}

- (void)hiddenGiftShowView{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.aPlayer.hidden = YES;
    });
    [self.aPlayer stopAnimation];
    [self.aPlayer clear];
}

- (void)hiddenGiftShowView2{
    self.gifImageView.hidden = YES;
    self.gifImageView.image = nil;
}


- (void)giftViewGetMoneyInView:(JPGiftView *)giftView {
    
    NSLog(@"充值");
}

@end
