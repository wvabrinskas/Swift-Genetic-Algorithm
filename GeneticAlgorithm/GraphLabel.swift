//
//  GraphLabel.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 5/23/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import Cocoa

class GraphLabel: NSTextField {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isEditable = false
        self.alignment = .center
        self.textColor = .black
        self.backgroundColor = .clear
        self.isBordered = false
        self.font = NSFont.systemFont(ofSize: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
