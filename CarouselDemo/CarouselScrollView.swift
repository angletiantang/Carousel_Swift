//
//  CarouselScrollView.swift
//  CarouselView
//
//  Created by yzl001 on 17/08/15.
//  Copyright © 2017年 郭建恒. All rights reserved.
//  ScrollView封装的自动轮播图

import UIKit

//
/* 使用需要注意如下三点
    1.在有UINavigationController中的控制器上使用这个ScrollView，必须要加上如下的方法:
    self.navigationController?.navigationBar.isTranslucent = false
    因为（iOS7.0之后）如果ViewController上有navigationbar，自动将view上的内容下移64，且如果是透明的，self.navigationController.navigationBar.translucent = true（默认）
    2.使用时，初始化方法frame必须传值。不能给CGRect.zero。不要使用约束布局。
    3.使用前，如果需要加载网络图片，则库中必须包含SDWebImage。(需要配置plist文件允许http)
 **/
protocol CarouselScrollViewDelegate {
    /* 图片点击事件的回调**/
    func carouselImageViewClicked(index:Int) -> Void
}

class CarouselScrollView: UIView,UIScrollViewDelegate
{
    //MARK: - 属性
    //是否URL加载
    fileprivate var isFromURL:Bool  = true
    //页码
    fileprivate var index:Int       = 0
    //图片数量
    fileprivate var imgViewNum:Int  = 0
    //宽度
    fileprivate var sWidth:CGFloat  = 0
    //高度
    fileprivate var sHeight:CGFloat = 0
    //图片每一页停留时间
    fileprivate var pageStepTime:TimeInterval  = 0
    
    //定时器
    fileprivate var timer:Timer?
    //图片数组
    fileprivate var imgArray: [UIImage]?
    //图片url数组
    fileprivate var imgURLArray:[String]?
    
    //MARL: - 懒加载
    //图片滚动view
    fileprivate lazy var scrollView: UIScrollView = UIScrollView()
    
    fileprivate lazy var pageControl: UIPageControl =  UIPageControl()
    // 2 代理属性
    var delegate : CarouselScrollViewDelegate?
    //MARK: - 初始化方法
    /**
    初始化方法1,传入图片URL数组,以及pageControl的当前page点的颜色,特别注意需要SDWebImage框架支持
    
    - parameter frame:          frame
    - parameter imgURLArray:    图片URL数组
    - parameter pagePointColor: pageControl的当前page点的颜色
    - parameter stepTime:       图片每一页停留时间
    
    - returns: ScrollView图片轮播器
    */
    init(frame: CGRect, imageURLArray:[String], pagePointColor: UIColor, stepTime: TimeInterval)
    {
        super.init(frame: frame)
        
        imgURLArray = imageURLArray
        
        prepareUI(imageURLArray.count, pagePointColor: pagePointColor,stepTime: stepTime)
        
    }
    
    /**
     初始化方法2,传入图片数组,以及pageControl的当前page点的颜色,无需依赖第三方库
     
     - parameter frame:          frame
     - parameter imgArray:       图片数组
     - parameter pagePointColor: pageControl的当前page点的颜色
     - parameter stepTime:       图片每一页停留时间
     
     - returns: ScrollView图片轮播器
     */
    init(frame: CGRect, imageArray:[UIImage], pagePointColor: UIColor, stepTime: TimeInterval)
    {
        super.init(frame: frame)
        
        imgArray = imageArray
        
        isFromURL = false
        
        prepareUI(imageArray.count, pagePointColor: pagePointColor,stepTime: stepTime)
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 准备UI
    fileprivate func prepareUI(_ numberOfImage:Int, pagePointColor: UIColor,stepTime: TimeInterval)
    {
        //设置图片数量
        imgViewNum = numberOfImage
        //图片每一页停留时间
        pageStepTime = stepTime
        
        //添加scrollView
        addSubview(scrollView)
        //添加pageControl
        addSubview(pageControl)
        //pageControl数量
        pageControl.numberOfPages = imgViewNum;
        //pageControl颜色
        pageControl.currentPageIndicatorTintColor = pagePointColor
        //view宽度
        sWidth = self.frame.size.width
        //view高度
        sHeight = self.frame.size.height
        
        //设置代理
        scrollView.delegate = self;
        //一页页滚动
        scrollView.isPagingEnabled = true;
        //隐藏滚动条
        scrollView.showsHorizontalScrollIndicator = false;
        //设置一开始偏移量
        scrollView.contentOffset = CGPoint(x: sWidth , y: 0);
        
        //设置timer
        setTheTimer()
        //设置图片
        prepareImage()
    }
    
    //布局子控件
    override func layoutSubviews()
    {
        super.layoutSubviews()
        //布局ScrollView
        scrollView.frame = self.bounds
        
        //布局pageControl
        let pW = scrollView.bounds.width
        let pH = CGFloat(15)
        let pX = CGFloat(0)
        let pY = scrollView.bounds.height -  CGFloat(pH * 2)
        
        pageControl.frame = CGRect(x: pX, y: pY, width: pW, height: pH)
    }
    
    deinit
    {
        print("scrollDeinit")
    }
    
    //MARK: - 创建图片
    /**
    *  创建图片
    */
    fileprivate func prepareImage()
    {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            //设置一开始偏移量
            self.scrollView.contentOffset = CGPoint(x: self.sWidth, y: 0);
            //设置滚动范围
            
            self.scrollView.contentSize = CGSize(width: CGFloat(self.imgViewNum + 2) * self.sWidth, height: 0)
            
        })
        
        
        for i in 0 ..< imgViewNum + 2
        {
            var imgX = CGFloat(i) * sWidth;
            let imgY:CGFloat = 0;
            let imgW = sWidth;
            let imgH = sHeight;
            let imgView = UIImageView()
            
            if i == 0
            {
                //第0张 显示图片最后一张
                imgX = 0;
                
                if !isFromURL
                {
                    imgView.image = imgArray?.last
                }
                else
                {
                    imgView.sd_setImage(with: URL(string: (imgURLArray?.last)!), placeholderImage: UIImage(named: "holder"))
                }
            }
            else if i == imgViewNum + 1
            {
                //第n+1张,显示图片第一张
                imgX = CGFloat(imgViewNum + 1) * sWidth;
                
                if !isFromURL
                {
                    imgView.image = imgArray?.first
                }
                else
                {
                    imgView.sd_setImage(with: URL(string: (imgURLArray?.first)!), placeholderImage: UIImage(named: "holder"))
                }
            }
            else
            {
                //正常显示图片
                if !isFromURL
                {
                    imgView.image = imgArray?[i - 1]
                }
                else
                {
                    imgView.sd_setImage(with: URL(string: (imgURLArray?[i - 1])!), placeholderImage: UIImage(named: "holder"))
                }
            }
            
            imgView.frame = CGRect(x: imgX, y: imgY, width: imgW, height: imgH)
            
            //添加子控件
            scrollView.addSubview(imgView)
            // 开启用户交互
            imgView.isUserInteractionEnabled = true
            let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(imgViewClicked))
            imgView.addGestureRecognizer(tapGR);
        }
    }
    
    /**
     *  轻拍图片
     */
    @objc func imgViewClicked() -> Void {
        let index = self.pageControl.currentPage
        if self.delegate != nil {
            self.delegate?.carouselImageViewClicked(index: index)
        }
    }
    
    /**
     *  执行下一页的方法
     */
    @objc fileprivate func nextImage()
    {   //取得当前pageControl页码
        var indexP = self.pageControl.currentPage
        
        if indexP == imgViewNum
        {
            indexP = 1;
        }
        else
        {
            indexP += 1;
        }
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(indexP + 1) * sWidth, y: 0), animated: true)
    }
    
    
    //MARK: - pragma mark- 代理
    
    /**
    * 动画减速时的判断
    *
    */
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        carousel()
    }
    
    /**
     *  拖拽减速时的判断
     *
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        carousel()
    }
    
    func carousel()
    {
        
        //获取偏移值
        let offset = scrollView.contentOffset.x;
        //当前页
        let page = Int((offset + sWidth/2) / sWidth);
        //如果是N+1页
        if page == imgViewNum + 1
        {
            //瞬间跳转第1页
            scrollView.setContentOffset(CGPoint(x: sWidth, y: 0), animated: false)
            index = 1
        }
            //如果是第0页
        else if page == 0
        {
            //瞬间跳转最后一页
            scrollView.setContentOffset(CGPoint(x: CGFloat(imgViewNum) * sWidth, y: 0), animated: false)
            
        }
    }
    
    /**
     *  滚动时判断页码
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        //获取偏移值
        let offset = scrollView.contentOffset.x - sWidth;
        //页码
        let pageIndex = Int((offset + sWidth / 2.0) / sWidth);
        
        pageControl.currentPage = pageIndex
        
    }
    
    /**
     *  拖拽图片时停止timer
     */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        stopTimer()
    }
    
    /**
     销毁timer
     */
    func stopTimer()
    {
        timer?.invalidate()
        
        timer = nil
    }
    
    /**
     *  结束拖拽时重新创建timer
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        setTheTimer()
    }
    
    //MARK:设置timer
    fileprivate func setTheTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: pageStepTime, target: self, selector: #selector(CarouselScrollView.nextImage), userInfo: nil, repeats: true)
        
        let runloop = RunLoop.current
        
        runloop.add(timer!, forMode: RunLoopMode.commonModes)
        
    }
}
