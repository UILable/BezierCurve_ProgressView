//
//  ProgressView.m
//  贝塞尔曲线
//
//  Created by ainolee on 15/9/16.
//  Copyright (c) 2015年 com.kls66.www. All rights reserved.
//

#import "ProgressView.h"
#define kScreem_Width   [[UIScreen mainScreen] bounds].size.width



const float CIRCLE_RADIUS = 4.0;//小圆圈的半径
const float LINE_WIDTH = 2.0;//小圆圈的描边色的宽度




@interface ProgressView ()
{
    NSMutableArray *circleLayers;//小圆圈的数组
    NSMutableArray *layers;//线的数组
    int circleCounter;//圆的个数从0开始++
    int layerCounter;//
}
@property(strong,nonatomic)NSMutableArray *descriptionLabelsArr;//下面描述性的label的数组
@property(strong,nonatomic)UIView *timeViewContainer;//时间view
@property(strong,nonatomic)UIView *progressDescriptionViewContainer;//进度描述view
@end


@implementation ProgressView
#pragma mark - 懒加载
//label的描述的label的大小
- (NSMutableArray *)descriptionLabelsArr {
    if (!_descriptionLabelsArr) {
        _descriptionLabelsArr = [[NSMutableArray alloc] init];
    }
    return _descriptionLabelsArr;
}

-(id)initWithFrame:(CGRect)frame andDescriptionArr:(NSArray *)descriptionArr andStatus:(int)status
{
    if (self=[super initWithFrame:frame]) {
        //时间view
        self.timeViewContainer=[[UIView alloc]init];
        self.timeViewContainer.frame=CGRectMake(0, 0, kScreem_Width, 40);
        //进度view
        self.progressDescriptionViewContainer=[[UIView alloc]init];
        self.progressDescriptionViewContainer.frame=CGRectMake(0, self.timeViewContainer.frame.size.height, kScreem_Width, 40);
        self.progressDescriptionViewContainer.backgroundColor=[UIColor cyanColor];
        [self addSubview:self.timeViewContainer];
        [self addSubview:self.progressDescriptionViewContainer];
        
        
        //下侧的文字描述
        [self addTimeDescriptionLabels:descriptionArr andCurrentStatus:status];
        
        //上侧的带有圆点的view
        [self addProgressBaseOnLabels:self.descriptionLabelsArr currentStatus:status];
        
    }
    return self;
}
#pragma mark - 上面带有原点的view
-(void)addProgressBaseOnLabels:(NSArray *)labels currentStatus:(int)currentStatus
{
    UIColor *strokeColor;//小圆圈
    CGFloat XCenter;//圆点X的中心
    CGPoint lastpoint;
    CGPoint toPoint;
    CGPoint fromPoint;

    CGFloat kLabelWidth=(kScreem_Width-60)/labels.count;
    CGFloat kSpaceWidth=60/labels.count;
    
    
    
    circleLayers=[[NSMutableArray alloc]init];//小圆圈的数组
    layers=[[NSMutableArray alloc]init];//线的数组
    
 
    //labels是从上一步获取的数据
    for (int i=0;i<labels.count;i++) {
        //配置圆
        strokeColor=i<currentStatus?[UIColor orangeColor]:[UIColor lightGrayColor];
        XCenter=kLabelWidth*i+kSpaceWidth*(i+1)+kLabelWidth/2-CIRCLE_RADIUS;
        //贝塞尔曲线划线
        UIBezierPath *circle=[UIBezierPath bezierPath];
        [self configureBeierCircle:circle withCenterx:XCenter];
        
        //
        CAShapeLayer *circleLayer=[self getLayerWithCircle:circle andStrokeColor:strokeColor];
        //放到数组中
        [circleLayers addObject:circleLayer];
        
        //小圆圈的背景需要设置为灰色-(全部的圆)--可以改成其他颜色看一下------最好设置为灰色
        CAShapeLayer *garyStaticCircleLayer=[self getLayerWithCircle:circle andStrokeColor:[UIColor lightGrayColor]];
        [self.timeViewContainer.layer addSublayer:garyStaticCircleLayer];
        
        //配置线
        if (i>0) {
            fromPoint=lastpoint;
            toPoint=CGPointMake(XCenter-CIRCLE_RADIUS, lastpoint.y);
            lastpoint=CGPointMake(XCenter+CIRCLE_RADIUS, lastpoint.y);
            
            //划线
            UIBezierPath *line=[self getLineWithStartPoint:fromPoint endPoint:toPoint];
            //填充线
            CAShapeLayer *lineLayer=[self getLayerWithLine:line andStrokeColor:strokeColor];
            [layers addObject:lineLayer];
            //添加静态背景线
            CAShapeLayer *grayStaticLineLayer = [self getLayerWithLine:line andStrokeColor:[UIColor lightGrayColor]];
            [self.timeViewContainer.layer addSublayer:grayStaticLineLayer];
        }else
        {
            //第一次进入
            lastpoint = CGPointMake(XCenter+CIRCLE_RADIUS, self.timeViewContainer.center.y);
        }
        
    }
    
    [self startAnimatingLayers:circleLayers forStatus:currentStatus];
}
#pragma mark - 动画开始画--------小圆圈数组----根据状态的点可以选择哪个圆开启动画
- (void)startAnimatingLayers:(NSArray *)layersToAnimate forStatus:(int)currentStatus {
    float circleTimeOffset = 1;
    circleCounter = 0;
    int i = 1;
    //    NSLog(@"CUR ST = %i layer to anim = %lu", currentStatus, (unsigned long)layersToAnimate.count);
    
    //这个判断出现的原因是当状态等于要划的圆的个数，那么就不要动画，直接显示完全，否则添加动画
    if (currentStatus == layersToAnimate.count) {
        //add without animation
        //没有动画
        //currentStatus==3   layersToAnimate.count==4
        for (CAShapeLayer *cilrclLayer in layersToAnimate) {
            [self.timeViewContainer.layer addSublayer:cilrclLayer];
        }
        for (CAShapeLayer *lineLayer in layers) {
            [self.timeViewContainer.layer addSublayer:lineLayer];
        }
    } else {
        //找到点加动画
        //add with animation
        for (CAShapeLayer *cilrclLayer in layersToAnimate) {
            [self.timeViewContainer.layer addSublayer:cilrclLayer];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.duration = 0.2;
//            animation.duration = 1.0;
            animation.beginTime = [cilrclLayer convertTime:CACurrentMediaTime() fromLayer:nil] + circleTimeOffset;
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue   = [NSNumber numberWithFloat:1.0f];
            animation.fillMode = kCAFillModeForwards;
            animation.delegate = self;
            circleTimeOffset += .4;
            [cilrclLayer setHidden:YES];
            [cilrclLayer addAnimation:animation forKey:@"strokeCircleAnimation"];
            if (i == currentStatus && i != [layersToAnimate count]) {
                //只有当i=当前状态的时候&&i不等于数组的和--  即不是最后一个---一直闪烁
                CABasicAnimation *strokeAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
                strokeAnim.fromValue         = (id) [UIColor orangeColor].CGColor;
                strokeAnim.toValue           = (id) [UIColor clearColor].CGColor;
                strokeAnim.duration          = 1.0;
                strokeAnim.repeatCount       = HUGE_VAL;
                strokeAnim.autoreverses      = NO;
                [cilrclLayer addAnimation:strokeAnim forKey:@"animateStrokeColor"];
            }
            i++;
        }
    }
}

//动画开启
- (void)animationDidStart:(CAAnimation *)anim {
    if (circleCounter < circleLayers.count) {
        //        NSLog(@"---circleCounter-%d------(int)circleLayers.count-%d",circleCounter,(int)circleLayers.count);
        //circleCounter   1-2-3-
        //circleLayers.count   4
        if (anim == [circleLayers[circleCounter] animationForKey:@"strokeCircleAnimation"]) {
            [circleLayers[circleCounter] setHidden:NO];
            circleCounter++;
        }
    }
}
//动画停止的时候
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (layerCounter >= layers.count) {
        return;
    }
    CAShapeLayer *lineLayer = layers[layerCounter];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 0.200;
//    animation.duration = 1.00;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue   = [NSNumber numberWithFloat:1.0f];
    animation.fillMode = kCAFillModeForwards;
    [self.timeViewContainer.layer addSublayer:lineLayer];
    [lineLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    layerCounter++;
}





#pragma mark - 线 - 划线
-(UIBezierPath *)getLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:start];
    [line addLineToPoint:end];
    return line;
}
#pragma mark - 线 - 填充线
-(CAShapeLayer *)getLayerWithLine:(UIBezierPath *)line andStrokeColor:(UIColor *)strokeColor
{
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = line.CGPath;
    lineLayer.strokeColor = strokeColor.CGColor;
    lineLayer.fillColor = nil;
    lineLayer.lineWidth = LINE_WIDTH;
    return lineLayer;
}
#pragma mark - 圆 - 从两侧画圆
-(void)configureBeierCircle:(UIBezierPath *)circle withCenterx:(CGFloat)centerX
{
    //从上下两个方向画圆---屏蔽掉其中一个可以看效果
    //上侧
    [circle addArcWithCenter:CGPointMake(centerX, self.timeViewContainer.center.y)
                      radius:CIRCLE_RADIUS
                  startAngle:-M_PI
                    endAngle:0
                   clockwise:YES];
    //下侧
    [circle addArcWithCenter:CGPointMake(centerX,self.timeViewContainer.center.y)
                      radius:CIRCLE_RADIUS
                  startAngle:0
                    endAngle:-M_PI
                   clockwise:YES];
}
#pragma mark - 圆 - 这个是小圆圈--
-(CAShapeLayer *)getLayerWithCircle:(UIBezierPath *)circle andStrokeColor:(UIColor *)strokeColor
{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = self.timeViewContainer.bounds;
    circleLayer.path = circle.CGPath;
    circleLayer.strokeColor = strokeColor.CGColor;//描边色
    circleLayer.fillColor = nil;//填充色
    circleLayer.lineWidth = LINE_WIDTH;
    circleLayer.lineJoin = kCALineJoinBevel;
    return circleLayer;
    
}

#pragma mark - 下面的描述label的view
-(void)addTimeDescriptionLabels:(NSArray *)descriptionArr andCurrentStatus:(int)currentStatus
{
    int i=0;
    CGFloat kLabelWidth=(kScreem_Width-60)/descriptionArr.count;
    CGFloat kSpaceWidth=60/descriptionArr.count;
    for (NSString *descriptionStr in descriptionArr) {
        UILabel *descriptionLabel=[[UILabel alloc]init];
        descriptionLabel.frame=CGRectMake(kLabelWidth*i+kSpaceWidth*(i+1), 10, kLabelWidth, self.timeViewContainer.frame.size.height-20);
        descriptionLabel.text=descriptionStr;
        descriptionLabel.font=[UIFont systemFontOfSize:12];
        descriptionLabel.textColor=i<currentStatus?[UIColor blackColor]:[UIColor grayColor];
        descriptionLabel.textAlignment=NSTextAlignmentCenter;
        [self.progressDescriptionViewContainer addSubview:descriptionLabel];
    
        //描述性label数组添加进去
        [self.descriptionLabelsArr addObject:descriptionLabel];
        i++;
    }
}
@end
