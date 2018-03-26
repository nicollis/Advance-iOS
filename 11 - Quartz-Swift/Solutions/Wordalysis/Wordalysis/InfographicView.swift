import UIKit

private enum Region {
    case titleAndCompletion
    case mostCommon
    case longestPopular
    case wordLengthHistogram
    case footer
}

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
    private var stats: WordCounter.TextStats!
    
    private var regionSlices: [Region: CGRect] = [:]
    private var timer: Timer?

    let logoImage = UIImage(named: "wordalysis")!  // This had better be there!
    
    func startTimer() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, 
                                     repeats: true) { timer in
            // capture stats
            self.stats = self.wordCounter.currentTextStats
            
            self.setNeedsDisplay()
            
            if self.stats.processedCount == self.stats.totalCount {
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
    
    
    private func sliceRegions(for bounds: CGRect) {
        regionSlices = [:]
        let sliceHeight = bounds.height / 6.0
        
        var slice: (slice: CGRect, remainder: CGRect)
        var remainder: CGRect
        
        slice = bounds.divided(atDistance: sliceHeight, from: .minYEdge)
        regionSlices[.titleAndCompletion] = slice.slice
        remainder = slice.remainder
        
        slice = remainder.divided(atDistance: sliceHeight, from: .minYEdge)
        regionSlices[.mostCommon] = slice.slice
        remainder = slice.remainder
        
        slice = remainder.divided(atDistance: sliceHeight, from: .minYEdge)
        regionSlices[.longestPopular] = slice.slice
        remainder = slice.remainder
        
        slice = remainder.divided(atDistance: sliceHeight * 2, from: .minYEdge)
        regionSlices[.wordLengthHistogram] = slice.slice
        remainder = slice.remainder
        
        slice = remainder.divided(atDistance: sliceHeight, from: .minYEdge)
        regionSlices[.footer] = slice.slice
    }
    
    private func drawProgress(in rect: CGRect, percentage: Double) {
        // Give a bit of breathing room around the progress meter.  3% horizontally, 5% vertically
        let rect = rect.insetBy(dx: rect.width * 0.03, dy: rect.height * 0.05)
        
        UIColor.lightGray.set()
        UIRectFill(rect)

        // Fill in the completed portion.
        var completedRect = rect
        
        let height = rect.size.height * CGFloat(percentage)
        completedRect.origin.y = rect.maxY - height
        completedRect.size.height = height
        
        UIColor.blue.set()
        UIRectFill(completedRect)

        // Give the whole thing an outline.
        UIColor.black.set()
        UIRectFrame(rect)
    }
    
    private func drawTop(in rect: CGRect) {
        // middle half has Wordalysis logo
        // right quarter has the progress meter, then a heart
        // left quarter has a heart
        
        let split = rect.threeWaySplit()
        
        let insetMiddle = split.middle.insetBy(dx: 10.0, dy: 20.0)
        logoImage.draw(in: insetMiddle)
        
        if stats.processing {
            drawProgress(in: split.right,
                         percentage: stats.processedPercentage)
        } else {
            drawHeart(in: split.right, angle: -CGFloat.pi / 4)
        }
        drawHeart(in: split.left, angle: CGFloat.pi / 4)
    }
    
    private func draw(string: String, in rect: CGRect,
                      color: UIColor, fontSize: CGFloat) {
        // Draw the most popular word.
        let nsstring = string as NSString
        
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)
        ]
        
        let wordSize = nsstring.size(withAttributes: attributes)
        var wordRect = rect
        wordRect.origin.x = rect.minX + (rect.width - wordSize.width) / 2.0
        
        nsstring.draw(in: wordRect, withAttributes: attributes)
    }
    
    private func drawMostCommon(in rect: CGRect) {
        draw(string: stats.mostPopularWord.word, in: rect,
             color: UIColor.blue, fontSize: 68)
    }
    
    private func drawLongestPopular(in rect: CGRect) {
        draw(string: stats.longestMostPopularWord.word, in: rect,
             color: UIColor.orange, fontSize: 44)
    }
    
    private func drawHistogram(in rect: CGRect) {
        let histogram = stats.wordFrequencyHistogram
        
        // Figure out the maximum word length seen.
        let maxBucket = histogram.keys.reduce(0, { max($0, $1) })
        guard maxBucket > 0 else { return }  // Nothing seen yet, bail out.
        
        // Give the chart a little breathing room
        var chartRect = rect.insetBy(dx: 5.0, dy: 5.0)

        // Figure out how wide each histogram bar is
        
        #if false
            // For drawing labels on the chart.
            let leftLabelWidth: CGFloat = 50.0
            let bottomLabelHeight: CGFloat = 20.0
            chartRect.origin.x += leftLabelWidth
            chartRect.size.width -= leftLabelWidth
            chartRect.size.height -= bottomLabelHeight
        #endif

        // We'll be using this later.
        let labelAttributes: [String: Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.lightGray,
            NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 10)
        ]
        
        // Draw the axis lines
        
        // -- Make the path that shows the X and Y axes
        let axisPath = UIBezierPath()
        
        let topLeft = CGPoint(x: chartRect.minX, y: chartRect.minY)
        let bottomLeft = CGPoint(x: chartRect.minX, y: chartRect.maxY)
        let bottomRight = CGPoint(x: chartRect.maxX, y: chartRect.maxY)
        axisPath.move(to: topLeft)
        axisPath.addLine(to: bottomLeft)
        axisPath.addLine(to: bottomRight)
        
        // Scale the histogram bars with this as the maximum height
        let maxCount = histogram.values.reduce(0, { max($0, $1) })

        // -- Make the path for the horizontal value lines
        let horizontalLinePath = UIBezierPath()

        // The "stride" is how often to draw the horizontal lines.
        // If there's not many items, draw them more often.
        var stride = 500
        if maxCount < 2000 {
            stride = 200
        }
        
        // Draw this from the bottom, a line for every multiple of the stride.
        // Stop when the value exceeds the maximum number from any bucket.
        // The lines themselves aren't drawn - just added to a path for later rendering.
        var count = stride
        while count < maxCount {
            // How tall to make the bar
            let proportion = CGFloat(count) / CGFloat(maxCount)
            let barHeight = chartRect.height * proportion
            
            // Where the Y coordinate is in the chart
            let Y = chartRect.maxY - barHeight
            
            // Add the horizontal line to the path for later stroking.
            horizontalLinePath.move(to: CGPoint(x: chartRect.minX, y: Y))
            horizontalLinePath.addLine(to: CGPoint(x: chartRect.maxX, y: Y))
            
            // click-up to the next value.
            count += stride
            
            #if false
                // while we're here and know the Y position, draw the label as well
                let countString = "\(count)" as NSString
                let width = countString.size(attributes: labelAttributes).width
                // TODO(markd, 1/8/2017): fix the fudge factors and use a proper centering
                let countRect = CGRect(x: rect.minX + (leftLabelWidth - width), y: Y - 5.0, 
                                       width: width, height: 20)
                countString.draw(in: countRect, withAttributes: labelAttributes)
            #endif
        }
        
        // Actually render the axes.  Draw the minor axes first, so that any overlap
        // with the major axes get drawn over.
        horizontalLinePath.lineWidth = 1.0
        let pattern: [CGFloat] = [2.0, 2.0]  // a pattern like ..  ..  ..  ..  
        horizontalLinePath.setLineDash(pattern, count: pattern.count, phase: 0.0)

        UIColor.lightGray.set()
        horizontalLinePath.stroke()
        
        UIColor.gray.set()
        axisPath.lineWidth = 2.0
        axisPath.stroke()
        
        
        // Draw the chart bars over the axes.
        
        // How much each bar plus spacing will take.
        let width = chartRect.width / CGFloat(maxBucket)
        let barWidth = width * 0.70  // Width of each bar
        let pad = width * 0.15       // Spacing - the pad on each side. bar + 2*pad == 100%
        
        let barsPath = UIBezierPath()
        
        var X = chartRect.minX
        for wordLength in 1 ... maxBucket {
            let wordCount = histogram[wordLength] ?? 0
            let proportion = CGFloat(wordCount) / CGFloat(maxCount)
            let height = chartRect.height * proportion
            
            #if false
                // Draw the rectangle the bars are being centered in
                // let boring = CGRect(x: X, y: chartRect.maxY - height, width: width, height: height)
                UIColor.green.set()
                UIRectFrame(boring)
            #endif
            
            let barRect = CGRect(x: X + pad, y: chartRect.maxY - height, 
                                 width: barWidth, height: height)
            
            barsPath.move   (to: CGPoint(x: barRect.minX, y: barRect.minY))  // bottom-left
            barsPath.addLine(to: CGPoint(x: barRect.maxX, y: barRect.minY))  // bottom-right
            barsPath.addLine(to: CGPoint(x: barRect.maxX, y: barRect.maxY))  // top-right
            barsPath.addLine(to: CGPoint(x: barRect.minX, y: barRect.maxY))  // top-left
            barsPath.close()
            
            // An alternative is to make a second path with the rect, and union it
            // with append.
            
            #if false
                // While we're here, draw the labels at the bottom of the bars
                let bucketString = "\(wordLength)" as NSString
                let labelWidth = bucketString.size(attributes: labelAttributes).width
                let bucketLabelRect = CGRect(x: barRect.midX - labelWidth / 2.0, y: barRect.maxY,
                                             width: labelWidth, height: 20)
                bucketString.draw(in: bucketLabelRect, withAttributes: labelAttributes)
            #endif
            
            X += width
        }

        // Fill all the bars at the same time.
        UIColor.lightGray.set()
        barsPath.fill()

        // Outline all the bars at the same time.
        UIColor.black.set()
        barsPath.lineWidth = 1.0
        barsPath.stroke()
    }
    
    func drawHeart(in rect: CGRect, angle: CGFloat) {
        let inset = rect.width * 0.11
        let insetRect = rect.insetBy(dx: inset, dy: inset)

        // This path draws a heart in a unit (1x1) square:
        let path = heartPath()

        let transform = CGAffineTransform.identity
            .translatedBy(x: insetRect.origin.x, y: insetRect.origin.y) // move origin to top-left
            .translatedBy(x: insetRect.width / 2.0, y: insetRect.height / 2.0) // move to middle
            .rotated(by: angle) // spin the axis
            .translatedBy(x: -insetRect.width / 2.0, y: -insetRect.height / 2.0) // move to top-left again
            .scaledBy(x: insetRect.width, y: insetRect.width)  // stretch the axes

        path.apply(transform)
        
        UIColor.red.set()
        path.lineWidth = 2.0
        path.stroke()
        
        // Replace with #if true to show the various debugging decorations
        #if false
            // Draw the coordinate axes
            let axes = UIBezierPath()
            axes.move(to: CGPoint(x: -500, y: 0))
            axes.addLine(to: CGPoint(x: 500, y: 0))
            axes.move(to: CGPoint(x: 0, y: -500))
            axes.addLine(to: CGPoint(x: 0, y: 500))
            UIColor.black.set()
            axes.apply(transform)
            axes.stroke()
            
            UIColor.black.set()
            axes.apply(transform)
            axes.stroke()
            
            // Draw the rectangle the heart goes in to
            let rectPath = UIBezierPath(rect: rect)
            UIColor.gray.set()
            let pattern: [CGFloat] = [2.0, 2.0]
            rectPath.setLineDash(pattern, count: pattern.count, phase: 0)
            rectPath.stroke()
            
            let unitRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
            let unitPath = UIBezierPath(rect: unitRect)
            unitPath.apply(transform)
            let dotPattern: [CGFloat] = [1.0, 1.0];
            unitPath.setLineDash(dotPattern, count: dotPattern.count, phase: 0)
            UIColor.orange.set()
            unitPath.stroke()
        #endif
    }
    
   
    private func drawBottomPad(in rect: CGRect) {
        let split = rect.threeWaySplit()

        drawHeart(in: split.left, angle: -CGFloat.pi / 4)
        drawHeart(in: split.right, angle: CGFloat.pi / 4)
    }
    
    override func draw(_ rect: CGRect) {
        // Start off with a clean slate
        UIColor.white.set()
        UIRectFill(bounds)
        
        // Figure out where everybody goes
        let boundsRect = self.bounds
        sliceRegions(for: boundsRect)

        // Draw All The Things
        drawTop(in: regionSlices[.titleAndCompletion]!)
        drawMostCommon(in: regionSlices[.mostCommon]!)
        drawLongestPopular(in: regionSlices[.longestPopular]!)
        drawHistogram(in: regionSlices[.wordLengthHistogram]!)
        drawBottomPad(in: regionSlices[.footer]!)
    }
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


// Grid lines for handy coordinate debugging.
extension InfographicView {

    fileprivate func drawGridLines() {
        let lightGray = UIColor.lightGray.withAlphaComponent(0.3)
        let darkGray = UIColor.darkGray.withAlphaComponent(0.3)
        let context = UIGraphicsGetCurrentContext()!

        lightGray.setStroke()
        self.drawGridLinesWithStride(10, withLabels: false, context: context)
        
        darkGray.setStroke()
        drawGridLinesWithStride(100, withLabels: true, context: context)
    }


    fileprivate func drawGridLinesWithStride(_ strideLength: CGFloat,
                                             withLabels: Bool, context: CGContext) {
        let kBig: CGFloat = 10000

        let font = UIFont.systemFont(ofSize: 10.0)
        
        let darkGray = UIColor.darkGray.withAlphaComponent(0.3)
        
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: darkGray
        ]
        
        // draw vertical lines
        for x in stride(from: bounds.minX - kBig, to: kBig, by: strideLength) {
            let start = CGPoint(x: x + 0.25, y: -kBig)
            let end = CGPoint(x: x + 0.25, y: kBig )
            context.move (to: start)
            context.addLine (to: end)
            context.strokePath ()
            
            if (withLabels) {
                var textOrigin = CGPoint(x: x + 0.25, y: bounds.minY + 0.25)
                textOrigin.x += 2.0
                let label = NSString(format: "%d", Int(x))
                label.draw(at: textOrigin,  withAttributes: textAttributes)
            }
        }
        
        // draw horizontal lines
        for y in stride(from: bounds.minY - kBig, to: kBig, by: strideLength) {
            let start = CGPoint(x: -kBig, y: y + 0.25)
            let end = CGPoint(x: kBig, y: y + 0.25)
            context.move (to: start)
            context.addLine (to: end)
            context.strokePath ()
            
            if (withLabels) {
                var textOrigin = CGPoint(x: bounds.minX + 0.25, y: y + 0.25)
                textOrigin.x += 3.0
                
                let label = NSString(format: "%d", Int(y))
                label.draw(at: textOrigin,  withAttributes: textAttributes)
            }
        }
    }
}


