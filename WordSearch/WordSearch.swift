//
//  WordSearch.swift
//  WordSearch
//
//  Created by Charles Martin Reed on 2/18/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit

//r-l, l-r, diagonal, etc.

enum PlacementType: CaseIterable {
    //caseiterable provides a collection of our cases. We'll use this to grab a enum case at random.
    case leftRight
    case rightLeft
    case upDown
    case downUp
    case topLeftBottomRight
    case topRightBottomLeft
    case bottomLeftTopRight
    case bottomRightTopLeft
    
    var movement: (x: Int, y: Int) {
        switch self {
        case .leftRight:
            return (1, 0)
        case .rightLeft:
            return (-1, 0)
        case .upDown:
            return (0, 1)
        case .downUp:
            return (0, -1)
        case .topLeftBottomRight:
            return (1, 1)
        case .topRightBottomLeft:
            return (-1, 1)
        case .bottomLeftTopRight:
            return (1, -1)
        case .bottomRightTopLeft:
            return (-1, -1)
        }
    }
}

//game difficulty determines which enums we use
enum Difficulty {
    case easy
    case medium
    case hard
    
    var placement: [PlacementType] {
        switch self {
        case .easy:
            return [.leftRight, .upDown].shuffled()
        case .medium:
            return [.leftRight, .rightLeft, .upDown, .downUp].shuffled()
        case .hard:
            //because our PlacementType is iterable...
            return PlacementType.allCases.shuffled()
        }
    }
}


struct Word: Decodable {
    //define a word struct and the definition or clue that will determine the prompt given to direct the user on how to find it
    var text: String //hamster
    var clue: String //small furry creature
}

class Label {
    var letter: Character = " " //as a reference type, if we modify here, we modify that value to anything else that points to ths location in memory
}

class WordSearch {
    var words = [Word]()
    var gridSize = 10
    
    //must be reference type because we need to have shared ownership - character wrapped in a class
    var labels = [[Label]]()
    var difficulty = Difficulty.easy
    var numberOfPages = 10
    
    //65-90 is ASCII for A...Z. We end up with an array of characters of such.
    let allLetters = (65...90).map { Character(UnicodeScalar($0))}
    
    //, fill the gaps with a random letter, print the grid
    func makeGrid() {
        //init 2D array of labels
        labels = (0 ..< gridSize).map { _ in
            (0 ..< gridSize).map { _ in Label() }
        }
        
        //search through labels, find empty spaces, insert a letter from the allLetters array
        fillGaps()
        printGrid() //debug for seeing the grid
    }
    
    private func fillGaps() {
        for column in labels {
            for label in column {
                if label.letter == " " {
                    label.letter = allLetters.randomElement()!
                }
            }
        }
    }
    
    private func printGrid() {
        for column in labels {
            for row in column {
                print(row.letter, terminator: "") //no new line
            }
            print("")//new line after each column
        }
    }
}
