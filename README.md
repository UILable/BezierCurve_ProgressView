# BezierCurve_ProgressView
贝塞尔曲线画出进度，时间需要修改

 NSArray *desArr=@[@"准备购买",@"已经付款",@"已经收货",@"完成评价",@"最多五个"];
    
    ProgressView *progressview=[[ProgressView alloc]initWithFrame:CGRectMake(0, 100, kScreem_Width, 80) andDescriptionArr:desArr andStatus:4];
    [self.view addSubview:progressview];
    
    
