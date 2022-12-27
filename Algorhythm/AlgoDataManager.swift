//
//  AlgoDataManager.swift
//  Algorhythm
//
//  Created by Jack Belding on 12/3/22.
//

import Foundation
import RealmSwift

/**
 * this class interacts with the realm database
 */
class AlgoDataManager {
    // the Realm object
    let realm = try! Realm()
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
}

extension AlgoDataManager {
    /**
     * function that gets a track id for a given genre and mood
     * @param genre: the genre to search within
     * @param mood: the mood of the seed id to return
     */
    func readIds(forGenre genre:String, forMood mood:String) -> [String]{
        var ids:[String] = []
        let results = realm.objects(MoodDataObject.self)
            .where{
                $0.genre == genre
            }
        if !results.isEmpty {
            let MoodDataObject = results.first?.IdsByMood.where{
                $0.mood == mood
            }
            if !MoodDataObject!.isEmpty{
                if let idsByMood = MoodDataObject?.first?.Ids {
                    for id in idsByMood {
                        ids.append(id as String)
                    }
                }
            }
        }
        return ids
    }
    /**
     * function that writes the track ids for a given genre and mood
     * @param genre: the genre to search within
     * @param mood: the mood of the seed id to return
     * @param ids: the ids to write
     */
    func writeIds(forGenre genre:String, forMood mood:String, ids:[String]) {
        let results = realm.objects(MoodDataObject.self)
            .where{
                $0.genre == genre
            }
        if results.isEmpty {
            // genre not created in db. create a new data object
            let newObject = MoodDataObject()
            newObject.genre = genre
            let MoodDataObject = Moods(mood, ids)
            newObject.IdsByMood.append(MoodDataObject)
            try! realm.write {
                realm.add(newObject)
            }
        }
        else {
            // genre found. Check for mood in data object
            let MoodDataObject = results.first?.IdsByMood.where{
                $0.mood == mood
            }
            if MoodDataObject!.isEmpty {
                // mood not found. Create mood object and update the entry
                let MoodDataObject = Moods(mood, ids)
                try! realm.write {
                    results.first?.IdsByMood.append(MoodDataObject)
                }
            }
            else {
                // mood found. replace ids with ids passed in
                try! realm.write {
                    MoodDataObject?.first?.Ids.removeAll()
                    MoodDataObject?.first?.Ids.append(objectsIn: ids)
                }
            }
        }
        print(results)
    }
    /**
     * function to write a created playist
     * @param id: the id to write
     */
    func writePlaylistId(withId id:String) {
        let results = realm.objects(Playlists.self)
        let playlistId = PlaylistDataObject(id)
        if let playlistObject = results.first {
            print("append element")
            try! realm.write {
                playlistObject.playlists.append(playlistId)
            }
        }
        else {
            let playlists = Playlists()
            playlists.playlists.append(playlistId)
            try! realm.write {
                realm.add(playlists)
            }
        }
    }
    
    /**
     * Function returns the ids of created playlists
     * @return [String]: the ids of all created playlists
     */
    func readCreatedPlaylists() -> [String] {
        let results = realm.objects(Playlists.self)
        var playlistIds:[String] = []
        if let playlistObject = results.first {
            for playlist in playlistObject.playlists {
                playlistIds.append(playlist.id)
            }
        }
        return playlistIds
    }
    
    /**
     * function removes an id from the playlists object
     * @param id: the id to remove
     */
    func deletePlaylist(withId idToDelete:String){
        let objectToDelete = realm.objects(PlaylistDataObject.self).where {
            $0.id == idToDelete
        }
        if !objectToDelete.isEmpty {
            try! realm.write {
                realm.delete(objectToDelete)
            }
        }
    }
}
/**
 * The key value object for mood and trackId, respectively
 */
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
/**
 * the realm db key value object for genre and moods, respectively
 */
final class MoodDataObject : Object {
    
    let IdsByMood =  RealmSwift.List<Moods>()
    @objc dynamic var genre:String?
}
/**
 * The realm data object for created playlists
 */
final class PlaylistDataObject : Object {
    override init() {}

    init(_ id:String){
        self.id = id
    }
    
    @objc dynamic var id:String = ""
}
/**
 * The realm collection of playlists
 */
final class Playlists : Object {
    let playlists:RealmSwift.List<PlaylistDataObject> = RealmSwift.List<PlaylistDataObject>()
}
