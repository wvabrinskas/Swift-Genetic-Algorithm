//
//  Genetic.swift
//  GeneticAlgorithm
//
//  Created by William Vabrinskas on 3/29/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//
//: Genetic Algorithm - William Vabrinskas
//  Swift 4

import Foundation
import Cocoa

class Genetic {
    
    lazy var allowedChars = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    var goalWord = "test"
    
    var n = 10
    var mutationFactor:UInt32 = 100
    var matingPool = [(String, Double)]()
    var rankingPool = [(String, Double)]()
    var generations = 0
    var highestRanking = 0.0
    
    var highestLabel: String!
    var generationsLabel: String!
    var result: String!
    var foundAnswer = false
    var outputCSV = ""
    var outputPoints = [CGPoint]()
    var onComplete:(() -> ())?
    private let rankingExponent = 2.0

    public func getPopulation(size number: Int) -> [String] {
        var population = [String]()
        
        for _ in 1...number {
            population.append(getRandomWord())
        }
        return population
    }
    
    private func getRandomCharacter() -> Character {
        let allowedCharsCount = UInt32(allowedChars.count)
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let newCharacter = allowedChars[allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)]
        return newCharacter
    }
    
    private func getRandomWord() -> String {
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in (0..<goalWord.count) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        return randomString
    }
    
    public func start(with population: [String], block: () -> ()) {
        foundAnswer = false
        var newPopulation = population
        clear()
        
        while !foundAnswer {
            rankingPool.removeAll()
            for element in newPopulation {
                self.result = element
                if element == goalWord {
                    self.generationsLabel = "\(generations)"
                    self.highestLabel = "\(Int(pow(highestRanking, (1 / rankingExponent)) * 100.0))%"
                    self.result = "Found result: '\(element)'"
                    outputPoints.append(CGPoint(x: Double(generations), y:100.0))
                    self.onComplete?()
                    foundAnswer = true
                    block()
                    break
                }
                let rankedItem = (element, getRank(of: element))
                rankingPool.append(rankedItem)
            }
            DispatchQueue.global().sync {
                self.buildMatingPool()
            }
            newPopulation = crossover()
            self.generationsLabel = "\(generations)"
            generations += 1
            block()
        }
    }
    
    private func clear() {
        self.generationsLabel = ""
        self.highestLabel = ""
        generations = 0
        highestRanking = 0
        outputCSV = ""
        outputPoints.removeAll()
    }
    
    public func stop() {
        foundAnswer = true
        self.result = "Stopped"
        clear()
    }
    
    private func getRank(of word: String) -> Double {
        var rank = 0.0
        
        for i in 0..<goalWord.count {
            if Array(goalWord)[i] == Array(word)[i] {
                rank += 1.0
            }
        }
        
        if rank == 0.0 {
            return 0.0
        }
        
        rank = rank / Double(goalWord.count)
        rank = pow(rank, rankingExponent)
        if highestRanking < rank {
            highestRanking = rank
            print(highestRanking)
            self.highestLabel = "\(Int(pow(highestRanking, (1 / rankingExponent)) * 100.0))%"
            outputCSV += "\(generations), \(rank) \n"
            outputPoints.append(CGPoint(x: Double(generations), y: pow(highestRanking, (1 / rankingExponent)) * 100.0))
        }

        return rank
    }
    
    private func replaceCharacter(string: String, index: Int) -> String {
        var chars = Array(string)
        chars[index] = getRandomCharacter()
        let modifiedString = String(chars)
        return modifiedString
    }
    
    private func crossover() -> [String] {
        var crossoverResults = [String]()
        let matingItems = Array(matingPool)
        let half = matingItems.count / 2
        let leftHalf = matingItems[0..<half].sorted(by: { $0.1 > $1.1})
        let rightHalf = matingItems[half..<matingItems.count].sorted(by: { $0.1 > $1.1})
        
        var matingTuples = [(String, String)]()
        for i in 0...half - 1 {
            if i < leftHalf.count && i < rightHalf.count {
                let left = leftHalf[i].0
                let right = rightHalf[i].0
                matingTuples.append((left, right))
            }
        }
        
        matingTuples.forEach { (item) in
            let leftItem = item.0
            let rightItem = item.1
            let intOffset = goalWord.count / 2
            
            let indexOne = rightItem.index(rightItem.startIndex, offsetBy: Float(goalWord.count).truncatingRemainder(dividingBy: 2.0) != 0 ? intOffset + 1 : intOffset)
            let indexTwo = leftItem.index(leftItem.endIndex, offsetBy: -(goalWord.count - indexOne.encodedOffset))
            
            let rightPrefix = rightItem.prefix(upTo: indexOne)
            let leftSuffix = leftItem.suffix(from: indexTwo)
            
            let rightSuffix = rightItem.suffix(from: indexTwo)
            let leftPrefix = leftItem.prefix(upTo: indexOne)
            
            let randomMutation = Int(arc4random_uniform(mutationFactor))
            var mother = String(rightPrefix + leftSuffix)
            var father = String(leftPrefix + rightSuffix)
            
            if randomMutation == 1 {
                let indexToReplace = Int(arc4random_uniform(UInt32(goalWord.count)))
                mother = replaceCharacter(string: mother, index: indexToReplace)
                father = replaceCharacter(string: father, index: indexToReplace)
            }
            
            crossoverResults.append(String(mother))
            crossoverResults.append(String(father))
        }
        return crossoverResults
    }
    
    
    private func getRandomElement() -> (String, Double) {
        while true {
            let index = Int(arc4random_uniform(UInt32(rankingPool.count)))
            let element = rankingPool[index]
            let randomFitness:Double = Double(arc4random_uniform(UInt32(highestRanking * 100))) / 100.0
            if randomFitness <= element.1 {
                return element
            }
        }
    }
    
    private func buildMatingPool() {
        matingPool.removeAll()
        for _ in 1...n {
            matingPool.append(getRandomElement())
        }
    }

    
}

