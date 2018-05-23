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
    
    var scale:CGFloat = 100.0
    var pointSize = CGSize(width: 5.0, height: 5.0)
    
    init(points: [CGPoint], size: CGSize) {
        self.points = points
        self.size = size
    }
    
    private func scoreLine(from: CGPoint, to: CGPoint) -> CAShapeLayer {
        let scoreLine = CGMutablePath()
        scoreLine.move(to: from)
        scoreLine.addLine(to: to)
        let scoreLayer = CAShapeLayer()
        scoreLayer.strokeColor = NSColor.lightGray.cgColor
        scoreLayer.lineWidth = 1.0
        scoreLayer.path = scoreLine
        return scoreLayer
    }
    
    private func pointLabel(currentPoint: CGPoint, value: CGPoint) -> GraphLabel {
        let graphlabel = GraphLabel(frame: CGRect(x: currentPoint.x - 10, y: currentPoint.y - 10, width: 50, height: 20))
        graphlabel.stringValue = "(\(Int(value.x)), \(Int(value.y)))"
        graphlabel.sizeToFit()
        return graphlabel
    }
    
    public func generate(window: UnsafeMutablePointer<NSWindow>) {
        let graphLayer = CALayer()
        graphLayer.backgroundColor = NSColor.clear.cgColor
        graphLayer.frame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        let xOffset:CGFloat = 200.0
        let yOffset:CGFloat = 200.0
        
        let maxHeight = self.size.height - yOffset
        let maxWidth = self.size.width - xOffset
        
        let minX = xOffset / 2
        let minY = yOffset / 2
        let maxY = maxHeight + (yOffset / 2)
        let maxX = maxWidth + (xOffset / 2)
    
        let ySpacing = maxHeight / 110

        var previousPoint: CGPoint?
        
        var x = 0
        let line = CGMutablePath()
        let lineLayer = CAShapeLayer()
        let axisLineLayer = CAShapeLayer()

        let sorted = self.points.sorted(by: { $0.y < $1.y })
        let lastXPoint = sorted.last!.x
        
        for x in stride(from: minX, through: maxX, by: self.scale) {
            let currentX = (lastXPoint / maxWidth) * (x - minX)
            
            let graphlabel = GraphLabel(frame: CGRect(x: x - 10, y: minY - 25, width: 50, height: 20))
            graphlabel.stringValue = "\(Int(currentX))"
            graphlabel.sizeToFit()
            
            window.pointee.contentView?.addSubview(graphlabel)

            //scores
            let scoreLayer = self.scoreLine(from: CGPoint(x: x, y: minY), to: CGPoint(x: x, y: maxY))
            graphLayer.addSublayer(scoreLayer)
        }
        
        for y in stride(from: minY, through: maxY, by: self.scale) {
            let currentY = (110 / maxHeight) * (y - minY)
            
            let graphlabel = GraphLabel(frame: CGRect(x: minX - 30.0, y: y - 5, width: 50, height: 20))
            graphlabel.stringValue = "\(Int(currentY))"
            graphlabel.sizeToFit()
            
            window.pointee.contentView?.addSubview(graphlabel)

            let scoreYLayer = self.scoreLine(from: CGPoint(x: minX, y: y), to: CGPoint(x: maxX, y: y))
            graphLayer.addSublayer(scoreYLayer)
            
        }
        
        for point in sorted {
            
            let currentX = (((point.x * maxWidth) / lastXPoint) + (xOffset / 2)) - (pointSize.width / 2)
            let currentY = ((point.y * ySpacing) + (yOffset / 2)) - (pointSize.height / 2)
            
            let oval = CGPath(ellipseIn: CGRect(x:currentX, y: currentY, width: pointSize.width, height: pointSize.height), transform: nil)
            let shapeLayer = CAShapeLayer()
            
            shapeLayer.fillColor = NSColor.red.cgColor
            shapeLayer.strokeColor = NSColor.clear.cgColor
            shapeLayer.path = oval

            graphLayer.addSublayer(shapeLayer)
            
            if previousPoint != nil {
                line.move(to:  CGPoint(x: previousPoint!.x + 2.5, y: previousPoint!.y + 2.5))
                line.addLine(to: CGPoint(x: currentX + 2.5, y: currentY + 2.5))
            }
            
            let pointLabel = self.pointLabel(currentPoint: CGPoint(x: currentX, y: currentY), value: point)
            window.pointee.contentView?.addSubview(pointLabel)
        
            
            previousPoint = CGPoint(x: currentX, y: currentY)
            x += 1
        }
        
        lineLayer.strokeColor = NSColor.red.cgColor
        lineLayer.lineWidth = 2.0
        lineLayer.path = line
        lineLayer.lineCap = kCALineCapRound

        let axis = CGMutablePath()
        axis.move(to: CGPoint(x: minX, y: minY))
        axis.addLine(to: CGPoint(x: maxX, y: minY))
        axis.move(to: CGPoint(x: minX, y: minY))
        axis.addLine(to: CGPoint(x: minX, y: maxY))
        
        axisLineLayer.strokeColor = NSColor.lightGray.cgColor
        axisLineLayer.lineWidth = 2.5
        axisLineLayer.path = axis
        
        graphLayer.addSublayer(axisLineLayer)
        graphLayer.addSublayer(lineLayer)

        
        window.pointee.contentView?.layer?.addSublayer(graphLayer)
    }

}
