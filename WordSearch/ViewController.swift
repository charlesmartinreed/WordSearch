//
//  ViewController.swift
//  WordSearch
//
//  Created by Charles Martin Reed on 2/18/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //quick dirty JSON
        if let path = Bundle.main.url(forResource: "capitals", withExtension: ".json") {
            do {
                let contents = try Data(contentsOf: path)
                let words = try JSONDecoder().decode([Word].self, from: contents)
                
                let wordSearch = WordSearch()
                wordSearch.words = words
                wordSearch.makeGrid()
            } catch {
                fatalError("could not parse JSON")
            }
            
            
        }
    }


}

