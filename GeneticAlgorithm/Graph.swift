//
//  Graph.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 5/22/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import Cocoa

class Graph {
    private var points = [CGPoint]()
    private var size: CGSize!
    
    init(points: [CGPoint], size: CGSize) {
        self.points = points
        self.size = size
    }
    
    public func generateLayer(complete: @escaping ( _ layer: CALayer) -> ()) {
        let graphLayer = CALayer()
        graphLayer.backgroundColor = NSColor.white.cgColor
        graphLayer.frame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        let xOffset:CGFloat = 80.0
        let yOffset:CGFloat = 80.0
        
        let maxHeight = self.size.height - yOffset
        let maxWidth = self.size.width - xOffset
        
        let ySpacing = maxHeight / 110

        var previousPoint: CGPoint?
        
        var x = 0
        let line = CGMutablePath()
        let lineLayer = CAShapeLayer()
        let axisLineLayer = CAShapeLayer()

        let sorted = self.points.sorted(by: { $0.y < $1.y })
        let lastXPoint = sorted.last!.x
        
        for point in sorted {

            let currentX = ((point.x * maxWidth) / lastXPoint) + (xOffset / 2)
            let currentY = (point.y * ySpacing) + (yOffset / 2)
            
            let oval = CGPath(ellipseIn: CGRect(x:currentX, y: currentY, width: 5.05, height: 5.0), transform: nil)
            let shapeLayer = CAShapeLayer()
            
            shapeLayer.fillColor = NSColor.red.cgColor
            shapeLayer.strokeColor = NSColor.clear.cgColor
            shapeLayer.path = oval
            
            let graphlabel = NSTextField(frame: CGRect(x: currentX, y: 0, width: 50, height: 20))
            graphlabel.alignment = .center
            graphlabel.textColor = .green
            graphlabel.font = NSFont.systemFont(ofSize: 20)
            graphlabel.stringValue = "\(currentX)"
            graphlabel.wantsLayer = true
            
            graphLayer.addSublayer(graphlabel.layer!)
            graphLayer.addSublayer(shapeLayer)
            
            if previousPoint != nil {
                line.move(to:  CGPoint(x: previousPoint!.x + 2.5, y: previousPoint!.y + 2.5))
                line.addLine(to: CGPoint(x: currentX + 2.5, y: currentY + 2.5))
            }
            
            previousPoint = CGPoint(x: currentX, y: currentY)
            x += 1
        }
        
        lineLayer.strokeColor = NSColor.red.cgColor
        lineLayer.lineWidth = 2.0
        lineLayer.path = line
        lineLayer.lineCap = kCALineCapRound
        
        let axis = CGMutablePath()
        axis.move(to: CGPoint(x: xOffset / 2, y: yOffset / 2))
        axis.addLine(to: CGPoint(x: maxWidth + (xOffset / 2), y: yOffset / 2))
        axis.move(to: CGPoint(x: xOffset / 2, y:  yOffset / 2))
        axis.addLine(to: CGPoint(x: xOffset / 2, y: maxHeight + (yOffset / 2)))
        
        axisLineLayer.strokeColor = NSColor.lightGray.cgColor
        axisLineLayer.lineWidth = 2.5
        axisLineLayer.path = axis
        axisLineLayer.lineCap = kCALineCapRound
        
        graphLayer.addSublayer(axisLineLayer)
        graphLayer.addSublayer(lineLayer)
        complete(graphLayer)

    }

}
