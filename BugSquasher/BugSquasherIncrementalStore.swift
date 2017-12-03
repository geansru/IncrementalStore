//
//  BugSquasherIncrementalStore.swift
//  BugSquasher
//
//  Created by Dmitriy Roytman on 03.12.17.
//  Copyright © 2017 poccaDot. All rights reserved.
//

import CoreData

final class BugSquasherIncrementalStore: NSIncrementalStore {
    var bugs: [String] = []
    var currentBugId = 0
    class var strokeType: String {
        return String(describing: BugSquasherIncrementalStore.self)
    }
    override func execute(_ request: NSPersistentStoreRequest, with context: NSManagedObjectContext?) throws -> Any {
        switch request.requestType {
        case .fetchRequestType:
            let fetchRequest = request as! NSFetchRequest<NSManagedObject>
            guard fetchRequest.resultType == NSFetchRequestResultType(), bugs.count > 0 else { break }
            let fetchedObjects: [NSManagedObject] = (1...bugs.count).flatMap { [weak self] bugId in
                guard let objectId = self?.newObjectID(for: fetchRequest.entity!, referenceObject: bugId) else { return nil }
                return context?.object(with: objectId)
            }
            return fetchedObjects
        case .saveRequestType:
            let saveRequest = request as! NSSaveChangesRequest
            saveRequest.insertedObjects?.forEach { bugs.append(($0 as! Bug).title)}
            save()
        default: break
        }
        return []
    }
    override func loadMetadata() throws {
        let uuid = "Bugs database"
        metadata = [
            NSStoreTypeKey: BugSquasherIncrementalStore.strokeType,
            NSStoreUUIDKey: uuid
        ]
        if let loadedArray = NSMutableArray(contentsOf: path) as? [String] {
            bugs = loadedArray
        }
    }
    override func obtainPermanentIDs(for array: [NSManagedObject]) throws -> [NSManagedObjectID] {
        let objectIds: [NSManagedObjectID] = array.flatMap { [weak self] in
            return self?.newObjectID(for: $0.entity, referenceObject: $0.value(forKey: "bugID"))
        }
        return objectIds
    }
    override func newValuesForObject(with objectID: NSManagedObjectID, with context: NSManagedObjectContext) throws -> NSIncrementalStoreNode {
        let values: [String: Any] = [
            "title": bugs[currentBugId],
            "bugID": currentBugId
        ]
        let node = NSIncrementalStoreNode(objectID: objectID, withValues: values, version: UInt64(0.1))
        currentBugId += 1
        return node
    }
    func save() {
        (bugs as NSArray).write(to: path, atomically: true)
    }
    private let path: URL = {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { fatalError() }
        return dir.appendingPathComponent("bugs.txt")
    }()
}
