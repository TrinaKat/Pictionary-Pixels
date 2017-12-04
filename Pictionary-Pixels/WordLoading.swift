//
//  WordLoading.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 12/3/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

// Used to determine answer string
var words: [Any] = []
var url_words: [Any] = []
var local_words: [Any] = []

// Read a JSON from a URL via wifi/cellular data
func readUrlJSON() {
    let url = URL(string: "https://pictionary-pixels.herokuapp.com/")
    URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
        guard let data = data, error == nil else { return }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            let json_words = json["words"]  as! [Any]
            // print(json_words)
            // print(json_words[0])
            url_words = json_words
        } catch let error as NSError {
            print(error)
        }
    }).resume()
}

// Get JSON data from a local JSON file
// Backup if web server is down
func readLocalJSON() {
    if let path = Bundle.main.path(forResource: "words", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            do{
                
                let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                
                // JSONObjectWithData returns AnyObject so the first thing to do is to downcast to dictionary type
                // Print all the key/values from the JSON
                // let jsonDictionary =  json
                // for (key, value) in jsonDictionary {
                //      print("\(key) - \(value) ")
                // }
                
                let json_words = json["words"]  as! [Any]
                // print(json_words)
                // print(json_words[0])
                local_words = json_words
                
            } catch let error {
                
                print(error.localizedDescription)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    } else {
        print("Invalid filename/path.")
    }
}

func chooseNewWord() {
    readLocalJSON()
    
    if url_words.count <= 0  && local_words.count > 0{
        words = local_words
    } else if local_words.count <= 0 {
        let hard_coded_words = ["hello", "world", "tea", "mochi", "stickers", "candy", "ucla", "bruins", "computer", "keyboard", "mouse", "cup", "bottle", "chips", "napkin", "earbuds", "mirror", "shadow", "photo", "horse", "cat", "dog", "cow", "goat", "corgi", "squirrel", "unicorn", "stairs", "ladder", "phone", "book", "driver", "nail", "neck", "hand", "harp", "football", "soccer", "tennis", "swimmer", "golf", "ticket", "magic", "snake", "braces", "crutches", "cast", "singer", "desk", "cape", "hero", "fish", "dancer", "pie", "cupcake", "teacher", "student", "star", "adult", "airplane", "apple", "pear", "peach", "baby", "backpack", "bathtub", "bird", "button", "carrot", "chess", "circle", "clock", "clown", "coffee", "comet", "compass", "diamond", "drums", "ears", "elephant", "feather", "fire", "garden", "gloves", "grapes", "hammer", "highway", "spider", "kitchen", "knife", "map", "maze", "money", "rich", "needle", "onion", "painter", "perfume", "prison", "potato", "rainbow", "record", "robot", "rocket", "rope", "sandwich", "shower", "spoon", "sword", "teeth", "tongue", "triangle", "umbrella", "vacuum", "vampire", "werewolf", "water", "window", "worm", "bones", "cannon", "whistle", "brick", "volcano", "stamp", "flowers", "boat", "rain", "stretch", "farm", "soap", "tape", "suit", "tie", "egg", "bucket", "monkey", "shark", "pizza", "couch", "skirt", "cactus", "milk", "cookie", "bait", "boil", "wax", "comb", "mask", "stick", "bat", "cloud", "sneeze", "sick", "you", "saw", "shoe", "staple", "butter", "bell", "sponge", "train", "mail", "thunder", "cheese", "turkey", "snow", "mountain", "giraffe", "ceiling", "drawing", "fishing", "penguin", "hat", "balloon", "earring", "garbage", "ketchup", "nametag", "waffle", "music", "concert", "comic", "check", "zebra", "zit", "yolk", "quilt", "open", "lemon", "kiss", "jar", "archer", "bow", "igloo", "lion", "lake", "idea", "wedding", "crown"]
        words = hard_coded_words
    } else {
        words = url_words
    }
//    print("Using following word array in GuessingView:")
//    print(words)
    
    let answer_num = arc4random_uniform(UInt32(words.count))
    answer = words[Int(answer_num)] as! String
    print("The chosen answer is:")
    print(answer)
}
