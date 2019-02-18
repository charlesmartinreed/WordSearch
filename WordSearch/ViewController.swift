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
                
                let output = wordSearch.render()
                let url = getDocumentsDirectory().appendingPathComponent("output.pdf")
                try output.write(to: url)
                print(url)
                
            } catch {
                fatalError("could not parse JSON")
            }
        }
    }
    
    func renderPDFfrom(words: [Word]) {
        
    }
    
    
    func getDocumentsDirectory() -> URL {
        //find where the user's documents are stored for our app
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }


}

