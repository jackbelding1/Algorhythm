//
//  AlgoDataManager.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/3/22.
//

import Foundation
import RealmSwift


class AlgoDataManager {
    // the Realm object
    let realm = try! Realm()
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
}
extension AlgoDataManager {
    
    func readIds(forGenre genre:String, forMood mood:String) -> [String]{
        var ids:[String] = []
        let results = realm.objects(DataObject.self)
            .where{
                $0.genre == genre
            }
        if !results.isEmpty {
            let moodObject = results.first?.IdsByMood.where{
                $0.mood == mood
            }
            if !moodObject!.isEmpty{
                if let idsByMood = moodObject?.first?.Ids {
                    for id in idsByMood {
                        ids.append(id as String)
                    }
                }
            }
        }
        return ids
    }
    
    func writeIds(forGenre genre:String, forMood mood:String, ids:[String]) {
        let results = realm.objects(DataObject.self)
            .where{
                $0.genre == genre
            }
        if results.isEmpty {
            // genre not created in db. create a new data object
            let newObject = DataObject()
            newObject.genre = genre
            let moodObject = Moods(mood, ids)
            newObject.IdsByMood.append(moodObject)
            try! realm.write {
                realm.add(newObject)
            }
        }
        else {
            // genre found. Check for mood in data object
            let dataObject = results.first?.IdsByMood.where{
                $0.mood == mood
            }
            if dataObject!.isEmpty {
                // mood not found. Create mood object and update the entry
                let moodObject = Moods(mood, ids)
                try! realm.write {
                    results.first?.IdsByMood.append(moodObject)
                }
            }
            else {
                // mood found. append to list of ids
                try! realm.write {
                    dataObject?.first?.Ids.append(objectsIn: ids)
                }
            }
        }
        
        print(results)
    }

}
final class Moods : Object {
    override init() {
    }
            
    init(_ mood:String, _ ids:[String]) {
        self.mood = mood
        for id in ids {
            Ids.append(id)
        }
    }
    
    @objc dynamic var mood:String = ""
    let Ids:RealmSwift.List<String> = RealmSwift.List<String>()
}

final class DataObject : Object {
    
    let IdsByMood =  RealmSwift.List<Moods>()
    @objc dynamic var genre:String?
}
