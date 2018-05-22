//
//  GraphWindowController.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 5/22/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import Cocoa


class GraphWindowController: NSWindowController {
    var graph: Graph!
    
    convenience init(points: [CGPoint], frame: NSRect) {
        self.init(windowNibName: NSNib.Name.init("GraphWindowController"))
        graph = Graph(points: points, size: frame.size)
        self.window?.setFrame(frame, display: true)
        self.window?.contentView?.wantsLayer = true
        self.window?.styleMask.remove( [ .resizable ] )
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.loadGraph()
    }
    
    private func loadGraph() {
        graph.generateLayer { (layer) in
            DispatchQueue.main.async {
                self.window?.contentView?.layer?.addSublayer(layer)
            }
        }
    }
}
