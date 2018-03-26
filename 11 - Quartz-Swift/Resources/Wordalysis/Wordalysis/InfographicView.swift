import UIKit

class InfographicView: UIView {
    var wordCounter: WordCounter! {
        willSet {
            wordCounter?.runSlowly = false
        }
        didSet {
            stats = wordCounter.currentTextStats
            startTimer()
            wordCounter.runSlowly = true
        }
    }
    fileprivate var stats: WordCounter.TextStats!
    fileprivate var timer: Timer?
}


extension InfographicView {
    fileprivate func heartPath() -> UIBezierPath {
        // adapted from https://github.com/ipraba/EPShapes
        let originalRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let scale = 1.0
        
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: originalRect.size.width/2, 
                              y: scaledRect.origin.y + scaledRect.size.height))
        
        
        path.addCurve(to: CGPoint(x: scaledRect.origin.x, 
                                  y: scaledRect.origin.y + (scaledRect.size.height/4)),
                      controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), 
                                             y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                      controlPoint2: CGPoint(x: scaledRect.origin.x, 
                                             y: scaledRect.origin.y + (scaledRect.size.height/2)) )
        
        path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/4), 
                                        y: scaledRect.origin.y + (scaledRect.size.height/4)),
                    radius: (scaledRect.size.width/4),
                    startAngle: CGFloat.pi,
                    endAngle: 0,
                    clockwise: true)
        
        path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3/4), 
                                        y: scaledRect.origin.y + (scaledRect.size.height/4)),
                    radius: (scaledRect.size.width/4),
                    startAngle: CGFloat.pi,
                    endAngle: 0,
                    clockwise: true)
        
        path.addCurve(to: CGPoint(x: originalRect.size.width/2, 
                                  y: scaledRect.origin.y + scaledRect.size.height),
                      controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, 
                                             y: scaledRect.origin.y + (scaledRect.size.height/2)),
                      controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), 
                                             y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
        
        path.close()
        
        return path
    }
}


extension InfographicView {

    // Partial solution to using a circle for the progress meter.
    // It has an annoying vertical black line from the center at 0 / 100%
    private func fillArc(withPercentage percent: CGFloat,
                         atCenter center: CGPoint,
                         radius: CGFloat) {
        let path = UIBezierPath()
        
        path.move(to: center)
        let startAngle: CGFloat = -CGFloat.pi / 2.0
        let completedAngle: CGFloat = startAngle + 2 * CGFloat.pi * percent
        
        path.addArc(withCenter: center, radius: radius,
                    startAngle: startAngle, endAngle: completedAngle,
                    clockwise: true)
        path.close()
        
        UIColor.purple.set()
        path.fill()
        
        UIColor.black.set()
        path.stroke()
        
        let path2 = UIBezierPath()
        path2.move(to: center)
        path2.addArc(withCenter: center, radius: radius,
                     startAngle: completedAngle, endAngle: startAngle,
                     clockwise: true )
        
        UIColor.orange.set()
        path.fill()
        
        UIColor.black.set()
        path.stroke()
    }
}

// Timer handling
extension InfographicView {
    func startTimer() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, 
                                     repeats: true) { timer in
            // capture stat snapshot
            self.stats = self.wordCounter.currentTextStats
            
            if !self.stats.processing {
                // all done
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override func didMoveToSuperview() {
        startTimer()
    }
}


extension CGRect {
    func threeWaySplit() -> (left: CGRect, middle: CGRect, right: CGRect) {
        let quarterWidth = self.width / 4.0
        
        let leftQuarter = CGRect(x: self.origin.x, y: self.origin.y, 
                                 width: quarterWidth, height: self.height)
        
        let rightQuarter = CGRect(x: self.maxX - quarterWidth, y: self.origin.y,
                                  width: quarterWidth, height: self.height)
        
        let middleHalf = CGRect(x: leftQuarter.maxX, y: self.origin.y,
                                width: quarterWidth * 2, height: self.height)
        
        return (leftQuarter, middleHalf, rightQuarter)
    }
}
