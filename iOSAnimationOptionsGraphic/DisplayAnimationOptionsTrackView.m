//
//  DisplayAnimationOptionsTrackView.m
//  iOSAnimationOptionsGraphic
//
//  Created by sloth on 2018/11/8.
//  Copyright © 2018 wyp. All rights reserved.
//

#import "DisplayAnimationOptionsTrackView.h"

@interface DisplayAnimationOptionsTrackView ()
// 移动的滑块
@property (nonatomic, strong) UIView *rectView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIBezierPath *shapePath;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray *points;

// 上下两个区域的wrapView
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

// 坐标轴
@property (nonatomic, strong) CAShapeLayer *axisesLayer;

@property (nonatomic, assign) CFAbsoluteTime beginTime;

@end


@implementation DisplayAnimationOptionsTrackView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}


- (void)setup{
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [_topView addSubview:self.rectView];
    [_bottomView.layer addSublayer:self.shapeLayer];
    [_bottomView.layer addSublayer:self.axisesLayer];

    [self drawAxisesLayer];
}


- (void)beginAnimationWithOptions:(UIViewAnimationOptions)options{
    // 记录每次动画开始时间
    _beginTime = CFAbsoluteTimeGetCurrent();
    // 方块回归起点
    self.rectView.frame = CGRectMake(0, _topView.bounds.size.height * 0.25, _topView.bounds.size.height * 0.5, _topView.bounds.size.height * 0.5);
    // 清空曲线
    [self.points removeAllObjects];
    [self.shapePath removeAllPoints];
    
    //开始动画
    [self startObserve];
    [UIView animateWithDuration:1 delay:0 options:options animations:^{
        CGSize size = self.rectView.frame.size;
        self.rectView.frame = CGRectMake(self.topView.bounds.size.width - self.rectView.bounds.size.width, self.rectView.frame.origin.y, size.width, size.height);
    } completion:^(BOOL finished) {
        [self stopObserve];
    }];
}


// 监听MyView
- (void)startObserve {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displaySynced)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)displaySynced {
    CGFloat x = [self.rectView.layer presentationLayer].frame.origin.x;
    
    [self drawCurrentValue:x];
}

// 停止监听MyView
- (void)stopObserve {
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self displaySynced];
}

// 绘制的曲线
- (void)drawCurrentValue:(CGFloat)xValue{
    // 取得当前的精准时间
    CFAbsoluteTime nowTime = CFAbsoluteTimeGetCurrent();
    // 计算出时间差
    double timePast = nowTime - _beginTime;
    if (timePast > 1.0) {
        return;
    }
    
    // 求出方块当前滑过距离和总距离的百分比
    CGFloat percentage = xValue * 1.0f / (_topView.bounds.size.width - _rectView.bounds.size.width);
    if (timePast < 0.1 && percentage == 1) {
        return;
    }
    
    NSLog(@"-----time: %f   perc: %f", timePast, percentage);
    // 计算出曲线当前点的位置
    CGFloat totalWith = _bottomView.bounds.size.width;
    CGFloat totalHeight = _bottomView.bounds.size.height;
    CGPoint point = CGPointMake(totalWith * timePast,totalHeight *( 1 - percentage));
    // 渲染
    if (self.points.count == 0) {
        [self.shapePath moveToPoint:point];
    }else{
        [self.shapePath addLineToPoint:point];
        self.shapeLayer.path = _shapePath.CGPath;
    }
    [self.points addObject:NSStringFromCGPoint(point)];
    
    
}

#pragma mark - private
- (void)drawAxisesLayer{
    CGFloat height = self.axisesLayer.bounds.size.height;
    CGFloat width = self.axisesLayer.bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, height)];
    [path addLineToPoint:CGPointMake(width, height)];
    self.axisesLayer.path = path.CGPath;
}


#pragma mark - getter
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height * 0.5 - 20)];
    }
    return _topView;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10,self.bounds.size.height * 0.5 + 10, self.bounds.size.width - 20, self.bounds.size.height * 0.5 - 20)];
        _bottomView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1 alpha:1];
    }
    return _bottomView;
}

- (UIView *)rectView{
    if (!_rectView) {
        _rectView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bounds.size.height * 0.25, _topView.bounds.size.height * 0.5, _topView.bounds.size.height * 0.5)];
        _rectView.backgroundColor = [UIColor lightGrayColor];
    }
    return _rectView;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = CGRectMake(0, 0, _bottomView.bounds.size.width, _bottomView.bounds.size.height);
        _shapeLayer.lineWidth = 2.0f;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    }
    return _shapeLayer;
}


- (CAShapeLayer *)axisesLayer{
    if (!_axisesLayer) {
        _axisesLayer = [CAShapeLayer layer];
        _axisesLayer.frame = CGRectMake(0, 0, _bottomView.bounds.size.width, _bottomView.bounds.size.height);
        _axisesLayer.lineWidth = 2.0f;
        _axisesLayer.fillColor = [UIColor clearColor].CGColor;
        _axisesLayer.strokeColor = [UIColor grayColor].CGColor;
    }
    return _axisesLayer;
}



- (UIBezierPath *)shapePath{
    if (!_shapePath) {
        _shapePath = [UIBezierPath bezierPath];
    }
    return _shapePath;
}

- (NSMutableArray *)points{
    if (!_points) {
        _points = [NSMutableArray new];
    }
    return _points;
}


@end
