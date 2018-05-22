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
    @IBOutlet weak var outputDirectoryField: NSTextField!
    
    let genetic = Genetic()
    var saveURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mutationFactorField.delegate = self
        self.populationSizeField.delegate = self
        
        self.mutationFactorField.formatter = OnlyIntegerValueFormatter()
        self.populationSizeField.formatter = OnlyIntegerValueFormatter()

        self.title = "Swift Genetic Algorithm"
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func showGraph(_ sender: Any) {
        let origin = CGPoint(x: self.view.frame.origin.x + (self.view.frame.size.width + 40), y: self.view.frame.origin.y + self.view.frame.size.height)
        
        let title = (self.goalPhraseField.stringValue == "" ? self.goalPhraseField.placeholderString ?? "test" : self.goalPhraseField.stringValue) + " - " + generationLabel.stringValue
        let frame = NSRect(origin: origin, size:CGSize(width: 1000, height: 600))
        
        let graphController = GraphWindowController(points: genetic.outputPoints, frame: frame, title: title, xAxisTitle: "Generations", yAxisTitle: "% Match")
        graphController.showWindow(self)
    }

    @IBAction func start(_ sender: Any) {
        genetic.n = populationSizeField.intValue == 0 ? 100 : Int(populationSizeField.intValue)
        genetic.mutationFactor = mutationFactorField.intValue == 0 ? 100 : UInt32(mutationFactorField.intValue)
        genetic.goalWord = goalPhraseField.stringValue.isEmpty ? "test" : goalPhraseField.stringValue
        genetic.onComplete = {
            self.writeToFile()
        }
        
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
    
    @IBAction func selectOutput(_ sender: Any) {
        let panel = NSSavePanel()
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        panel.nameFieldStringValue = "output.csv"
        
        panel.begin { (result) in
            if result == .OK, let url = panel.url {
                self.saveURL = url
                self.outputDirectoryField.placeholderString = self.saveURL?.absoluteString
            }
        }
        
    }
    
    private func writeToFile() {
        do {
            if self.saveURL != nil {
                print("saving to file")
                try genetic.outputCSV.write(to: self.saveURL!, atomically: true, encoding: .utf8)
            }
        } catch {
            print(error)
        }
    }
}

