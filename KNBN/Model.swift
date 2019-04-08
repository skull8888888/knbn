//
//  Model.swift
//  KNBN
//
//  Created by Robert Kim on 17/1/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import Foundation
import RealmSwift
import MobileCoreServices

final class Note: Object, Codable, KanbanItem {
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var text: String = ""
    @objc dynamic var angle: CGFloat = 0.0
    @objc dynamic var color: String = ""
    @objc dynamic var index: Int = 0
    @objc dynamic var section: Int = 0
    
    @objc dynamic var createdDate: Date = Date(timeIntervalSince1970: 1)
    @objc dynamic var editedDate: Date = Date(timeIntervalSince1970: 1)
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension Note: NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        do {
            let data = try JSONEncoder().encode(self)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        return progress
        
    }
    
    
}

extension Note: NSItemProviderReading {
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData as String)]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Note {
        
        let decoder = JSONDecoder()
        
        do {
            //Here we decode the object back to it's class representation and return it
            let note = try decoder.decode(Note.self, from: data)
            return note 
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
}

enum NoteType: String {
    case toDo = "ToDo"
    case progress = "Progress"
    case done = "Done"
}

struct Model {
    
    lazy var realm = try! Realm()
    
    static var shared = Model()
    
    func migrate(){
        
        let config = Realm.Configuration(
            schemaVersion: Standard.schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                
                if (oldSchemaVersion < Standard.schemaVersion) {
                    
                    migration.enumerateObjects(ofType: Note.className(), { (old, new) in
    
                        switch oldSchemaVersion {
                        case 0:
                            new?["id"] = UUID().uuidString
                            
                            if let oldType = old?["type"] as? String {
                                
                                var newType = 0
                                
                                if oldType == "ToDo" {
                                    newType = 0
                                } else if oldType == "Progress"{
                                    newType = 1
                                } else {
                                    newType = 2
                                }
                                
                                new?["section"] = newType
                                
                            } else if let oldType = old?["type"] as? Int {
                                new?["section"] = oldType
                            }
                            
                        case 1:
                            
                            new?["createdDate"] = Date(timeIntervalSince1970: 1)
                            new?["editedDate"] = Date(timeIntervalSince1970: 1)
                            
                        default: break
                            
                        }
                        
                    })
                    
                }
                
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
    }

    mutating func saveItemsOrder(_ data: [[Note]]){
        
        for section in 0...2 {
            
            for (itemIndex, item) in data[section].enumerated() {

                let note = realm.object(ofType: Note.self, forPrimaryKey: item.id)

                try! realm.write {
                    
                    note?.index = itemIndex
                    note?.section = section
                }

            }

        }

    }
    
    mutating func getData() -> [[Note]]{
        
        let toDo = Array(realm.objects(Note.self).filter("section = 0").sorted(byKeyPath: "index"))
        let progress = Array(realm.objects(Note.self).filter("section = 1").sorted(byKeyPath: "index"))
        let done = Array(realm.objects(Note.self).filter("section = 2").sorted(byKeyPath: "index"))
        
        return [
            toDo,
            progress,
            done
        ]
    
    }
    
    mutating func add(_ note: Note) {
        
        try! realm.write {
            realm.add(note)
        }
        
    }
    
    mutating func save(id: String, text: String, colorHEX: String) {
        
        let note = realm.object(ofType: Note.self, forPrimaryKey: id)
        
        try! realm.write {
            note?.text = text
            note?.color = colorHEX
            note?.editedDate = Date()
        }
        
    }
    
    mutating func delete(_ note: Note) {
        
        try! realm.write {
            realm.delete(note)
        }
        
    }
    
}
