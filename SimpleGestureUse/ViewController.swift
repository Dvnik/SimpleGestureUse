//
//  ViewController.swift
//  SimpleGestureUse
//
//  Created on 2022/12/23.
//
// 參考來源：https://itisjoe.gitbooks.io/swiftgo/content/uikit/uigesturerecognizer.html
// 雖然是直接用Model去註冊Gesture，但是exmple的程式碼還是抄別人的。(只是改成現在能用的版本)

import UIKit

class ViewController: UIViewController {

    //MARK: values
    var fullSize :CGSize!
    var myUIView :UIView!
    var anotherUIView :UIView!
    
    var myImageView: UIImageView!
    var anotherImageView :UIImageView!
    
    var gestureMaker = SimpleGestureMaker()
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 取得螢幕的尺寸
        fullSize = UIScreen.main.bounds.size
        // gesture function
        initGesture()
    }
    //MARK: functions
    /**
     其實有想過要讓這個Gesture做成單例模式，
     不過範例中的tap有分單指輕點和雙指輕點，
     所以就不放棄單例模式，
     並且產生出來的gesture作為回傳值來自行決定要怎麼處理。
     */
    private func initGesture() {
        gestureMaker.delegate = self
        gestureMaker.settingVC = self
        //輕點
        // 雙指輕點 2根指頭觸發
        let doubleFinger = gestureMaker.addTapAction(touchesRequired: 2)
        // 單指輕點 點2下才觸發
        let singleFinger = gestureMaker.addTapAction(tapsRequired: 2)
        // 雙指輕點沒有觸發時 才會檢測此手勢 以免手勢被蓋過
        singleFinger.require(toFail: doubleFinger)
        
        // 長按
        _ = gestureMaker.addLongPressAction()
        
        // 滑動
        // 一個可供移動的 UIView
        myUIView = UIView(frame: CGRect(
          x: 0, y: 0, width: 100, height: 100))
        myUIView.backgroundColor = UIColor.blue
        self.view.addSubview(myUIView)
        // 滑動手勢
        _ = gestureMaker.addSwipeAction()
        
        // 拖曳
        // 一個可供移動的 UIView
        anotherUIView = UIView(frame: CGRect(
          x: fullSize.width * 0.5, y: fullSize.height * 0.5,
          width: 100, height: 100))
        anotherUIView.backgroundColor = UIColor.orange
        self.view.addSubview(anotherUIView)
        // 拖曳手勢
        let panGesture = gestureMaker.addPanAction()
        // 為這個可移動的 UIView 加上監聽手勢
        anotherUIView.addGestureRecognizer(panGesture)
        
        // 縮放
        // 建立一個用來縮放的圖片
        myImageView = UIImageView(image: UIImage(systemName: "globe.americas"))
        myImageView.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        self.view.addSubview(myImageView)
        
        _ = gestureMaker.addPinchAction()
        
        // 旋轉
        // 建立一個用來旋轉的圖片
        anotherImageView = UIImageView(image: UIImage(systemName: "triangle"))
        anotherImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        anotherImageView.center = CGPoint( x: fullSize.width * 0.5, y: fullSize.height * 0.75)
        self.view.addSubview(anotherImageView)
        
        _ = gestureMaker.addRotationAction()
    }

}

//MARK: SimpleGestureMakerDelegate
/**
 會寫成Delegate的原因，應該看Model的那個程式碼可以知道，
 每個註冊的Gesture都帶著自己的#selector(@objc)方法。
 那麼寫起來就會很散。
 
 另外delegate做成非強至實作的模式則是依照需求來使用這些手勢，而非每次用這個Model就要實作一堆手勢方法
 */
extension ViewController: SimpleGestureMakerDelegate {
    func onTapped(times: Int, points: [CGPoint]) {
        print(#function)
        
        print("Times:\(times)")
        
        for i in 0 ..< points.count {
            print("第 \(i + 1) 指的位置：\(String(reflecting: points[i]))")
        }
    }
    func onLongPress(state: UIGestureRecognizer.State, point: CGPoint?) {
        if state == .began {
            print("長按開始")
        }
        else if state == .ended {
            print("長按結束")
        }
        
        if let point = point {
            print("位置：\(point)")
        }
    }
    func onSwipe(direction: UISwipeGestureRecognizer.Direction) {
        let point = myUIView.center
        if direction == .up {
            print("Go Up")
            if point.y >= 150 {
                myUIView.center = CGPoint(
                  x: myUIView.center.x,
                  y: myUIView.center.y - 100)
            } else {
                myUIView.center = CGPoint(
                  x: myUIView.center.x, y: 50)
            }
        }
        else if direction == .left {
            print("Go Left")
            if point.x >= 150 {
                myUIView.center = CGPoint(
                  x: myUIView.center.x - 100,
                  y: myUIView.center.y)
            } else {
                myUIView.center = CGPoint(
                  x: 50, y: myUIView.center.y)
            }
        }
        else if direction == .down {
            print("Go Down")
            if point.y <= fullSize.height - 150 {
                myUIView.center = CGPoint(
                  x: myUIView.center.x,
                  y: myUIView.center.y + 100)
            } else {
                myUIView.center = CGPoint(
                  x: myUIView.center.x,
                  y: fullSize.height - 50)
            }
        }
        else if direction == .right {
            print("Go Right")
            if point.x <= fullSize.width - 150 {
                myUIView.center = CGPoint(
                  x: myUIView.center.x + 100,
                  y: myUIView.center.y)
            } else {
                myUIView.center = CGPoint(
                  x: fullSize.width - 50,
                  y: myUIView.center.y)
            }
        }
    }
    func onPan(superView: UIView?, superPoint: CGPoint) {
        // 設置 UIView 新的位置
        anotherUIView.center = superPoint
        
        print("拖曳位置:\(superPoint)")
    }
    func onPinch(state: UIGestureRecognizer.State, scale: CGFloat, velocity: CGFloat) {
        if state == .began {
            print("開始縮放")
        }
        else if state == .changed {
            // 圖片原尺寸
            let frm = myImageView.frame
            
            // 目前圖片寬度
            let w = frm.width

            // 目前圖片高度
            let h = frm.height

            // 縮放比例的限制為 0.5 ~ 2 倍
            if w * scale > 100 && w * scale < 400 {
                myImageView.frame = CGRect(x: frm.origin.x,
                                           y: frm.origin.y,
                                           width: w * scale,
                                           height: h * scale)
            }
        }
        else if state == .ended {
            print("結束縮放")
        }
    }
    func onRotation(angle: CGFloat, radianTransform: CGAffineTransform) {
        anotherImageView.transform = radianTransform
        
        print("旋轉角度： \(angle)")
    }
}
