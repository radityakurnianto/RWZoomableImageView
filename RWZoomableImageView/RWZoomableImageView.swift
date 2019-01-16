//
//  RWZoomableImageView.swift
//  Pinch
//
//  Created by Raditya Kurnianto on 1/14/19.
//  Copyright © 2019 Raditya Kurnianto. All rights reserved.
//

import UIKit

@IBDesignable public class RWZoomableImageView: UIImageView {
    
    var isZooming = false
    var originalImageCenter: CGPoint?
    var originalRect: CGRect!
    var originalPosition: CGPoint!
    var firstCenterPoint: CGPoint!
    
    lazy var overlayView: UIView = { [unowned self] in
        let view = UIView(frame: UIScreen.main.bounds)
        view.alpha = 0.5
        view.backgroundColor = .black
        return view
        }()
    
    lazy var dummyImageView: UIImageView = { [unowned self] in
        let imgView = UIImageView(frame: .zero)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
        }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        attachGesture()
    }
    
    override public init(image: UIImage?) {
        super.init(image: image)
        attachGesture()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        attachGesture()
    }
    
    fileprivate func attachGesture() -> Void {
        self.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchStateChanged(pinch:)))
        self.addGestureRecognizer(pinch)
    }
    
    @objc fileprivate func pinchStateChanged(pinch: UIPinchGestureRecognizer) -> Void {
        if pinch.state == .began {
            self.isHidden = true
            let window = UIApplication.shared.keyWindow
            originalPosition = self.convert(self.frame.origin, to: nil)
            originalRect = CGRect(origin: originalPosition, size: self.bounds.size)
            firstCenterPoint = pinch.location(in: window)
            
            dummyImageView.frame = originalRect
            dummyImageView.contentMode = .scaleAspectFill
            dummyImageView.clipsToBounds = true
            dummyImageView.image = self.image
            
            window?.addSubview(overlayView)
            window?.addSubview(dummyImageView)
        }
        
        if pinch.state == .changed {
            let currentScale = dummyImageView.frame.size.width / originalRect.size.width
            let newScale = currentScale * pinch.scale
            let newWidth = newScale * originalRect.size.width
            let newHeight = newScale * originalRect.size.height
            let newSize = CGSize(width: newWidth, height: newHeight)
            
            dummyImageView.frame = CGRect(origin: originalPosition, size: newSize)
            
            let currentWindow = UIApplication.shared.keyWindow
            let centerXDif = firstCenterPoint.x - pinch.location(in: currentWindow).x
            let centerYDif = firstCenterPoint.y - pinch.location(in: currentWindow).y
            
            let posX = originalRect.origin.x + (originalRect.size.width/2)-centerXDif
            let posY = originalRect.origin.y + (originalRect.size.height/2)-centerYDif
            dummyImageView.center = CGPoint(x: posX, y: posY)
            pinch.scale = 1
        }
        
        if pinch.state == .ended || pinch.state == .failed || pinch.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.dummyImageView.frame = self.originalRect
            }) { (completed) in
                self.originalPosition = .zero
                self.originalRect = .zero
                self.originalImageCenter = .zero
                self.dummyImageView.removeFromSuperview()
                self.overlayView.removeFromSuperview()
                self.isHidden = false
            }
        }
    }
}
