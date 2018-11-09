//
//  ViewController.m
//  iOSAnimationOptionsGraphic
//
//  Created by sloth on 2018/11/7.
//  Copyright © 2018 wyp. All rights reserved.
//

#import "ViewController.h"
#import "DisplayAnimationOptionsTrackView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *beginButton;

@property (nonatomic, strong) DisplayAnimationOptionsTrackView *trackView;
@property (nonatomic, assign) NSInteger currentOptionsInd;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.trackView];
    
    
}


- (IBAction)beginClicked:(UIButton *)sender {
    UIViewAnimationOptions opt = _currentOptionsInd << 16;
    [_trackView beginAnimationWithOptions:opt];
    NSArray *optionsNameArr = @[@"UIViewAnimationOptionCurveEaseInOut",@"UIViewAnimationOptionCurveEaseIn",@"UIViewAnimationOptionCurveEaseOut",@"UIViewAnimationOptionCurveLinear"];
    _label.text = optionsNameArr[_currentOptionsInd];

}
- (IBAction)changeMode:(UIButton *)sender {
    if (_currentOptionsInd == 3) {
        _currentOptionsInd = 0;
    }else{
        _currentOptionsInd++;
    }
    NSArray *optionsNameArr = @[@"UIViewAnimationOptionCurveEaseInOut",@"UIViewAnimationOptionCurveEaseIn",@"UIViewAnimationOptionCurveEaseOut",@"UIViewAnimationOptionCurveLinear"];
    _switchLabel.text = optionsNameArr[_currentOptionsInd];
}




#pragma mark - getter
- (DisplayAnimationOptionsTrackView *)trackView{
    if (!_trackView) {
        _trackView = [[DisplayAnimationOptionsTrackView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 400)];
    }
    return _trackView;
}
@end
