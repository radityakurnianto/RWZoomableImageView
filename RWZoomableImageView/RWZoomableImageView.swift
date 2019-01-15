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
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch.delegate = self
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan.delegate = self
        
        self.addGestureRecognizer(pan)
        self.addGestureRecognizer(pinch)
    }
    
    @objc fileprivate func pinch(sender: UIPinchGestureRecognizer) -> Void {
        if sender.state == .began {
            let currentScale = self.frame.size.width / self.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            guard let view = sender.view else {return}
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.frame.size.width / self.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            guard let center = self.originalImageCenter else {return}
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform.identity
                self.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
    }
    
    @objc fileprivate func pan(sender: UIPanGestureRecognizer) -> Void {
        if isZooming {
            if sender.state == .began {
                originalImageCenter = sender.view?.center
            }
            
            if sender.state == .changed {
                let translation = sender.translation(in: self)
                if let view = sender.view {
                    let x = view.center.x + translation.x
                    let y = view.center.y + translation.y
                    
                    view.center = CGPoint(x: x, y: y)
                }
                
                sender.setTranslation(.zero, in: self.superview)
            }
        }
    }
}

extension RWZoomableImageView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
