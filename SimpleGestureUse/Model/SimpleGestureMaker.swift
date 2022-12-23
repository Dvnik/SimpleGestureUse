//
//  SimpleGestureMaker.swift
//  JunkTest
//
//  Created on 2022/12/20.
//
// 參考來源：https://itisjoe.gitbooks.io/swiftgo/content/uikit/uigesturerecognizer.html
// 大致上將手勢功能都實作出來，可能有些手勢用不到所以delegate就不強制插入function
//
//

import Foundation
import UIKit

protocol SimpleGestureMakerDelegate {
    func onTapped(times: Int, points: [CGPoint])
    func onLongPress(state: UIGestureRecognizer.State, point: CGPoint?)
    func onSwipe(direction: UISwipeGestureRecognizer.Direction)
    func onPan(superView: UIView?, superPoint: CGPoint)
    /// scale: 縮放比例
    func onPinch(state: UIGestureRecognizer.State, scale: CGFloat, velocity: CGFloat)
    func onRotation(angle: CGFloat, radianTransform: CGAffineTransform)
}

extension SimpleGestureMakerDelegate {
    func onTapped(times: Int, points: [CGPoint]) {}
    func onLongPress(state: UIGestureRecognizer.State, point: CGPoint?) {}
    func onSwipe(direction: UISwipeGestureRecognizer.Direction) {}
    func onPan(superView: UIView?, superPoint: CGPoint) {}
    func onPinch(state: UIGestureRecognizer.State, scale: CGFloat, velocity: CGFloat) {}
    func onRotation(angle: CGFloat, radianTransform: CGAffineTransform) {}
}

class SimpleGestureMaker: NSObject {
    //MARK: Values
    var delegate: SimpleGestureMakerDelegate?
    var settingVC: UIViewController?//如果不是nil的話會自動註冊相關的手勢到UIViewController上
    //MARK: functions
    /**
     Tap 輕點
     */
    func addTapAction(tapsRequired trNum: Int = 1, touchesRequired fingerNum: Int = 1) -> UITapGestureRecognizer {
        // 指輕點
        let fingers = UITapGestureRecognizer(target: self, action: #selector(gestureTap(_:) ))
        
        // 點幾下才觸發 設置 1 時 則是點一下會觸發 依此類推
        fingers.numberOfTapsRequired = trNum
        // 幾根指頭觸發
        fingers.numberOfTouchesRequired = fingerNum
        // 為視圖加入監聽手勢
        settingVC?.view.addGestureRecognizer(fingers)
        // return UITapGestureRecognizer
        return fingers
    }
    /**
     Long Press 長按
     */
    func addLongPressAction() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(gestureLongPress(_:) ))
        
        // 為視圖加入監聽手勢
        settingVC?.view.addGestureRecognizer(longPress)
        return longPress
    }
    /**
     Swipe 滑動
     */
    func addSwipeAction() -> [UISwipeGestureRecognizer] {
        var results = [UISwipeGestureRecognizer]()
        // 向上滑動
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipe(_:) ))
        swipeUp.direction = .up
        // 向左滑動
        let swipeLeft =  UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipe(_:) ))
        swipeLeft.direction = .left
        // 向下滑動
        let swipeDown =  UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipe(_:) ))
        swipeDown.direction = .down
        // 向右滑動
        let swipeRight =  UISwipeGestureRecognizer(target: self, action: #selector(gestureSwipe(_:) ))
        swipeRight.direction = .right
        // append
        results.append(swipeUp)
        results.append(swipeLeft)
        results.append(swipeDown)
        results.append(swipeRight)
        // 為視圖加入監聽手勢
        results.forEach { gesture in
            settingVC?.view.addGestureRecognizer(gesture)
        }
        
        return results
    }
    /**
     Pan 拖曳
     */
    func addPanAction(minTouches minNum: Int = 1, maxTouches maxNum: Int = 1) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gesturePan(_:)) )
        // 最少可以用幾指拖曳
        pan.minimumNumberOfTouches = minNum
        // 最多可以用幾指拖曳
        pan.maximumNumberOfTouches = maxNum
        //因為要拖曳的是物件而非整個View，所以viewController不會被設定
        return pan
    }
    /**
     Pinch 縮放
     */
    func addPinchAction() -> UIPinchGestureRecognizer {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(gesturePinch(_:) ))
        
        // 為視圖加入監聽手勢
        settingVC?.view.addGestureRecognizer(pinch)
        return pinch
    }
    /**
     Rotation 旋轉
     */
    func addRotationAction() -> UIRotationGestureRecognizer {
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(gestureRotation(_:) ))
        // 為視圖加入監聽手勢
        settingVC?.view.addGestureRecognizer(rotation)
        
        return rotation
    }
    // 刪除Gesture，預設是做這個class的UIViewController的移除
    func removeGesture(_ recognizer: UIGestureRecognizer, view: UIView? = nil) {
        if let view = view {
            view.removeGestureRecognizer(recognizer)
        }
        else {
            settingVC?.view.removeGestureRecognizer(recognizer)
        }
    }
    // 取得手指在view上的點位置
    private func getGesturePoints(_ recognizer: UIGestureRecognizer) -> [CGPoint] {
        // 取得每指的位置
        let number = recognizer.numberOfTouches
        var getPoints = [CGPoint]()
        
        for i in 0 ..< number {
            let point = recognizer.location(ofTouch: i, in: recognizer.view)
            
            getPoints.append(point)
        }
        
        return getPoints
    }
    //MARK: objc
    // 觸發輕點手勢後 執行的動作
    @objc private func gestureTap(_ recognizer: UITapGestureRecognizer) {
        let getPoints = getGesturePoints(recognizer)
        
        delegate?.onTapped(times: recognizer.numberOfTapsRequired, points: getPoints)
    }
    // 觸發長按手勢後 執行的動作
    @objc private func gestureLongPress(_ recognizer:UILongPressGestureRecognizer) {
        let pressPoint = getGesturePoints(recognizer).first
        
        delegate?.onLongPress(state: recognizer.state, point: pressPoint)

    }
    // 觸發滑動手勢後 執行的動作
    @objc func gestureSwipe(_ recognizer:UISwipeGestureRecognizer) {
        delegate?.onSwipe(direction: recognizer.direction)
    }
    // 觸發拖曳手勢後 執行的動作
    @objc func gesturePan(_ recognizer:UIPanGestureRecognizer) {
        let sView = recognizer.view?.superview
        let sPoint = recognizer.location(in: sView)
        
        delegate?.onPan(superView: sView, superPoint: sPoint)
    }
    // 觸發縮放手勢後 執行的動作
    @objc func gesturePinch(_ recognizer:UIPinchGestureRecognizer) {
        delegate?.onPinch(state: recognizer.state, scale: recognizer.scale, velocity: recognizer.velocity)
    }
    // 觸發旋轉手勢後 執行的動作
    @objc func gestureRotation(_ recognizer:UIRotationGestureRecognizer) {
        // 弧度
        let radian = recognizer.rotation
        // 旋轉的弧度轉換為角度
        let angle = radian * (180 / CGFloat(Float.pi))
        
        delegate?.onRotation(angle: angle, radianTransform: CGAffineTransformMakeRotation(radian))
    }
}
