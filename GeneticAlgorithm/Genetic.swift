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
    
    let allowedChars = "abcdefghijklmnopqrstuvwxyzm "
    var goalWord = "test"
    
    var n = 10
    var mutationFactor:UInt32 = 100
    var matingPool = [(String,Int)]()
    var rankingPool = [(String, Int)]()
    var generations = 0
    var highestRanking = 0
    
    var highestLabel: String!
    var generationsLabel: String!
    var result: String!
    var foundAnswer = false

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
        self.generationsLabel = ""
        self.highestLabel = ""
        generations = 0
        highestRanking = 0
        
        while !foundAnswer {
            rankingPool.removeAll()
            for element in newPopulation {
                self.result = element
                if element == goalWord {
                    self.generationsLabel = "\(generations)"
                    self.result = "Found result: '\(element)'"
                    foundAnswer = true
                    block()
                    break
                }
                let rankedItem = (element, getRank(of: element))
                rankingPool.append(rankedItem)
            }
            buildMatingPool()
            newPopulation = crossover()
            self.generationsLabel = "\(generations)"
            generations += 1
            block()
        }
    }
    
    public func stop() {
        foundAnswer = true
        self.generationsLabel = ""
        self.highestLabel = ""
        self.result = "Stopped"
        generations = 0
        highestRanking = 0
    }
    
    private func getRank(of word: String) -> Int {
        var rank = 0
        for letter in word {
            if goalWord.contains(letter) {
                rank += 1
            }
        }
        
        for i in 0...goalWord.count - 1 {
            if Array(goalWord)[i] == Array(word)[i] {
                rank += 1
            }
        }
        
        let adjustedRank = Int(Float(rank) / Float(goalWord.count * 2) * 100.0)
        
        if highestRanking < adjustedRank {
            highestRanking = adjustedRank
            self.highestLabel = "\(highestRanking)"
            print("Highest ranking word: '\(word)' with rank: \(highestRanking)")
        }
        return adjustedRank
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
    
    
    private func getRandomElement() -> (String, Int) {
        let total = UInt32(rankingPool.map { $0.1 }.reduce(0,+))
        let rand = Int(arc4random_uniform(total))
        
        var sum = 0
        
        for rankedItem in rankingPool {
            sum += rankedItem.1
            if rand < sum {
                return rankedItem
            }
        }
        return ("",0)
    }
    
    private func buildMatingPool() {
        matingPool.removeAll()
        for _ in 1...n {
            matingPool.append(getRandomElement())
        }
    }
    
}

