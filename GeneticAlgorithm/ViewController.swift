//
//  ViewController.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 3/29/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var generationLabel: NSTextField!
    @IBOutlet weak var rankLabel: NSTextField!
    @IBOutlet weak var populationSizeField: NSTextField!
    @IBOutlet weak var mutationFactorField: NSTextField!
    @IBOutlet weak var goalPhraseField: NSTextField!
    @IBOutlet weak var resultLabel: NSTextField!
    
    let genetic = Genetic()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mutationFactorField.delegate = self
        self.populationSizeField.delegate = self
        
        self.mutationFactorField.formatter = OnlyIntegerValueFormatter()
        self.populationSizeField.formatter = OnlyIntegerValueFormatter()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func start(_ sender: Any) {
        genetic.n = populationSizeField.intValue == 0 ? 100 : Int(populationSizeField.intValue)
        genetic.mutationFactor = mutationFactorField.intValue == 0 ? 100 : UInt32(mutationFactorField.intValue)
        genetic.goalWord = goalPhraseField.stringValue.isEmpty ? "test" : goalPhraseField.stringValue
        
        self.rankLabel.stringValue = ""
        self.generationLabel.stringValue = ""
        self.resultLabel.stringValue = ""
        
        OperationQueue().addOperation {
            self.genetic.start(with: self.genetic.getPopulation(size: self.genetic.n), block: {
                DispatchQueue.main.sync {
                    self.rankLabel.stringValue = self.genetic.highestLabel ?? ""
                    self.generationLabel.stringValue = self.genetic.generationsLabel ?? ""
                    self.resultLabel.stringValue = self.genetic.result ?? ""
                }
            })
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        genetic.stop()
        self.rankLabel.stringValue = self.genetic.highestLabel ?? ""
        self.generationLabel.stringValue = self.genetic.generationsLabel ?? ""
        self.resultLabel.stringValue = self.genetic.result ?? ""
        
    }
}

