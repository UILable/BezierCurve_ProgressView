//
//  ProgressView.h
//  贝塞尔曲线
//
//  Created by ainolee on 15/9/16.
//  Copyright (c) 2015年 com.kls66.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView
/*
 圆放在了view上，这个view的高度是40
 下面的描述view的高度也是40
 
 
 
 时间没有改动
*/
- (id)initWithFrame:(CGRect)frame andDescriptionArr:(NSArray *)descriptionArr andStatus:(int)status;
@end
