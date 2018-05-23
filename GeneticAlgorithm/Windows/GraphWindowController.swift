//
//  GraphWindowController.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 5/22/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import Cocoa
import QuartzCore

class GraphWindowController: NSWindowController {
    var graph: Graph!
    @IBOutlet weak var yAxisLabel: NSTextField! {
        didSet {
            yAxisLabel.frameCenterRotation = 90.0
        }
    }
    
    @IBOutlet weak var xAxisLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    
    convenience init(points: [CGPoint], frame: NSRect, title: String, xAxisTitle: String, yAxisTitle: String) {
        self.init(windowNibName: NSNib.Name.init("GraphWindowController"))
        graph = Graph(points: points, size: frame.size)
        self.window?.setFrame(frame, display: true)
        self.window?.contentView?.wantsLayer = true
        self.window?.styleMask.remove( [ .resizable ] )
        self.yAxisLabel.stringValue = yAxisTitle
        self.xAxisLabel.stringValue = xAxisTitle
        self.titleLabel.stringValue = title
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.loadGraph()
    }
    
    private func loadGraph() {
        graph.scale = 50
        var window = self.window!
        window.contentView!.wantsLayer = true
        graph.generate(window: &window)
    }
}
