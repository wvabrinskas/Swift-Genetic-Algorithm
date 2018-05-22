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
    
    public func generateLayer(complete: @escaping ( _ layer: CALayer,_ xAxisLabels:[NSTextField]) -> ()) {
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
        
        var currentXAxisLabels = [NSTextField]()
        
        var previousPoint: CGPoint?
        
        var x = 0
        let line = CGMutablePath()
        let lineLayer = CAShapeLayer()
        let axisLineLayer = CAShapeLayer()

        let sorted = self.points.sorted(by: { $0.y < $1.y })
        let lastXPoint = sorted.last!.x
        
        DispatchQueue.global().async {
            for point in sorted {
                
                let currentX = ((point.x * maxWidth) / lastXPoint) + (xOffset / 2)
                let currentY = (point.y * ySpacing) + (yOffset / 2)
                
                let oval = CGPath(ellipseIn: CGRect(x:currentX, y: currentY, width: 5.05, height: 5.0), transform: nil)
                let shapeLayer = CAShapeLayer()
                
                shapeLayer.fillColor = NSColor.red.cgColor
                shapeLayer.strokeColor = NSColor.clear.cgColor
                shapeLayer.path = oval

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
            axis.move(to: CGPoint(x: minX, y: minY))
            axis.addLine(to: CGPoint(x: maxX, y: minY))
            axis.move(to: CGPoint(x: minX, y: minY))
            axis.addLine(to: CGPoint(x: minX, y: maxY))
            
            axisLineLayer.strokeColor = NSColor.lightGray.cgColor
            axisLineLayer.lineWidth = 2.5
            axisLineLayer.path = axis
            axisLineLayer.lineCap = kCALineCapRound
            
            graphLayer.addSublayer(axisLineLayer)
            graphLayer.addSublayer(lineLayer)
            
            for x in stride(from: minX, through: maxX, by: 100) {
                
                let graphlabel = NSTextField(frame: CGRect(x: x - 25, y: minY - 25, width: 50, height: 20))
                graphlabel.isEditable = false
                graphlabel.alignment = .center
                graphlabel.textColor = .black
                graphlabel.backgroundColor = .clear
                graphlabel.isBordered = false
                graphlabel.font = NSFont.systemFont(ofSize: 12)
                graphlabel.stringValue = "\(x - 100)"
                graphlabel.sizeToFit()
                
                currentXAxisLabels.append(graphlabel)
            }
            
            complete(graphLayer, currentXAxisLabels)
        }
    }

}
