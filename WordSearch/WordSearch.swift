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
    
    var placementTypes: [PlacementType] {
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
    var difficulty = Difficulty.hard
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
        placeWords()
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
    
    private func labels(fromX x: Int, y: Int, word: String, movement: (x: Int, y: Int)) -> [Label]? {
        //look at this position, move in this direction, for a given word
        //if the proposed movment is valid, return the new array of labels, to replace what was previously at the position. Else, return nil
        var returnValue = [Label]()
        var xPosition = x
        var yPosition = y
        
        for letter in word {
            //read label from our grid
            let label = labels[xPosition][yPosition]
            
            //no letter here, we can fill it
            if label.letter == " " || label.letter == letter {
                returnValue.append(label)
                
                //shift the letter check as directed
                xPosition += movement.x
                yPosition += movement.y
            } else {
                return nil
            }
        }
        return returnValue
    }
    
    private func tryPlacing(_ word: String, movement: (x: Int, y: Int)) -> Bool {
        //start at a random position and try placing from there
        let xLength = (movement.x * (word.count - 1))
        let yLength = (movement.y * (word.count - 1))
        
        //get a random array of number and try to position the word at each place
        let rows = (0 ..< gridSize).shuffled()
        let cols = (0 ..< gridSize).shuffled()
        
        for row in rows {
            for col in cols {
                let finalX = col + xLength
                let finalY = row + yLength
                
                //is value inside grid?
                if finalX >= 0 && finalX < gridSize && finalY >= 0 && finalY < gridSize {
                    //try and read the labels and place the words
                    if let returnValue = labels(fromX: col, y: row, word: word, movement: movement) {
                        //if we're here, the word can be placed
                        for (index, letter) in word.enumerated() {
                            returnValue[index].letter = letter
                        }
                        return true
                    }
                }
            }
        }
        return false //couldn't place the word for any the given movement type
    }
    
    private func place(_ word: Word) -> Bool {
        let formattedWord = word.text.replacingOccurrences(of: " ", with: "").uppercased() //all uppercased makes this a little more difficult
        
//        for type in difficulty.placementTypes {
//            if tryPlacing(formattedWord, movement: type.movement) {
//                return true
//            }
//        }
        
        return difficulty.placementTypes.contains {
            tryPlacing(formattedWord, movement: $0.movement)
        }
        //return false
    }
    
    private func placeWords() -> [Word] {
        //get the words we used in words and display the hints for them
//        words.shuffle()
//        var usedWords = [Word]()
//
//        for word in words {
//            if place(word) { //place -> tryPLacing -> labels
//                usedWords.append(word)
//            }
//        }
//
//        return usedWords
//    }
        //filter takes our function, returns true or false from our place. The values that pass our place function
        return words.shuffled().filter(place)
    }
    
    //MARK:- Rendering the PDF
    func render() -> Data {
        //how big the page should be - A4 size
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin = pageRect.width / 10
        
        let availableSpace = pageRect.width - (margin * 2)
        let gridCellSize = availableSpace / CGFloat(gridSize) //square size
        
        //letters should be rendered in the center of the grid
        let gridLetterFont = UIFont.systemFont(ofSize: 16)
        let gridLetterStyle = NSMutableParagraphStyle()
        gridLetterStyle.alignment = .center
        
        let gridLetterAttributes: [NSAttributedString.Key: Any] = [
            .font: gridLetterFont,
            .paragraphStyle: gridLetterStyle
        ]
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { ctx in
            //returns the output from the PDF being rendered - we're making unique instances of the word search
            for _ in 0 ..< numberOfPages {
                ctx.beginPage()
                
                //get a grid
                _ = makeGrid()
                
                //write to the grid
                for i in 0 ... gridSize {
                    let linePosition = CGFloat(i) * gridCellSize
                    
                    //across
                    ctx.cgContext.move(to: CGPoint(x: margin, y: margin + linePosition))
                    ctx.cgContext.addLine(to: CGPoint(x: margin + (CGFloat(gridSize) * gridCellSize), y: margin + linePosition))
                    
                    //down
                    ctx.cgContext.move(to: CGPoint(x: margin + linePosition, y: margin))
                    ctx.cgContext.addLine(to: CGPoint(x: margin + linePosition, y: margin + (CGFloat(gridSize) * gridCellSize)))
                }
                
                //drawing the path
                ctx.cgContext.setLineCap(.square)
                ctx.cgContext.strokePath()
                
                //MARK:- Drawing letters
                //start in top left corner
                var xOffset = margin
                var yOffset = margin
                
                for column in labels {
                    for label in column {
                        //read letter, figure out size to render it at to center it vertically
                        //we need String here because Characters don't have size
                        let size = String(label.letter).size(withAttributes: gridLetterAttributes)
                        let yPosition = (gridCellSize - size.height) / 2
                        let cellRect = CGRect(x: xOffset, y: yOffset + yPosition, width: gridCellSize, height: gridCellSize)
                        
                        //draw string into space
                        String(label.letter).draw(in: cellRect, withAttributes: gridLetterAttributes)
                        
                        //move to the next space
                        xOffset += gridCellSize
                    }
                    
                    //after finishing, move to the next line down
                    xOffset = margin
                    yOffset += gridCellSize
                }
            }
        }
    }
}
