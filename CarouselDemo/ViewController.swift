//
//  ViewController.swift
//  CarouselDemo
//
//  Created by yzl001 on 2017/8/15.
//  Copyright © 2017年 郭建恒. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CarouselScrollViewDelegate {

    // 图片轮播组件
    var carouselView : CarouselScrollView?
    // 屏幕宽
    let kScreenWidth = UIScreen.main.bounds.size.width
    // 图片集合
    var images = ["http://bizhi.zhuoku.com/bizhi2008/0516/3d/3d_desktop_13.jpg",
                  "http://tupian.enterdesk.com/2012/1015/zyz/03/5.jpg",
                  "http://img.web07.cn/UpImg/Desk/201301/12/desk230393121053551.jpg",
                  "http://wallpaper.160.com/Wallpaper/Image/1280_960/1280_960_37227.jpg",
                  "http://bizhi.zhuoku.com/wall/jie/20061124/cartoon2/cartoon014.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 如果是navigationController,必须加上下面的方法
        // 如果不是，则不需要
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.carouselView = CarouselScrollView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth/16*9), imageURLArray: images, pagePointColor: UIColor.green, stepTime: 3.0)
        carouselView?.delegate = self
        self.view.addSubview(self.carouselView!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func carouselImageViewClicked(index: Int) {
        print("index:\(index)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

