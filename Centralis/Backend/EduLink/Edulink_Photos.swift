//
//  Edulink_Photos.swift
//  Centralis
//
//  Created by Amy While on 11/01/2022.
//

import UIKit
import Evander

final public class Photos {
    
    private let imagesFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("EdulinkImages")
    static let backgroundQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.amywhile.Centralis/PhotosQueue")
        queue.setSpecific(key: Photos.queueKey, value: Photos.queueContext)
        return queue
    }()
    static let queueKey = DispatchSpecificKey<Int>()
    static let queueContext = 848932579834
    
    public var cancelDump: Bool = false
    
    
    private let imageCache = NSCache<NSString, UIImage>()
    public static let shared = Photos()
    private var queue = [String]()
    private var exists = [String]()
    
    
    
    init() {
        if !imagesFolder.dirExists {
            try? FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        }
        exists = imagesFolder.implicitContents.map { $0.lastPathComponent.replacingOccurrences(of: ".png", with: "") }
    }
    
    public func getEmployeePictures(for ids: [String], size: Int = 1024, downscaled: CGSize? = nil, _ completion: (() -> Void)? = nil) {
        var check = [String]()
        for id in ids {
            if exists.contains(id) || queue.contains(id) || check.contains(id) {
                continue
            }
            check.append(id)
        }
        if check.isEmpty { return }
        queue += check
        EvanderNetworking.edulinkDict(method: "EduLink.TeacherPhotos", params: [
            .custom(key: "employee_ids", value: check),
            .custom(key: "size", value: Int(downscaled?.height ?? CGFloat(size)))
        ], timeout: 30) { _, _, error, result in
            guard let result = result,
                  let photos = result["employee_photos"] as? [[String: Any]] else { return }
            self.exists += ids
            for id in check {
                self.queue.removeAll { $0 == id }
            }
            for _photo in photos {
                guard let photo = _photo["photo"] as? String,
                      let base64 = Data(base64Encoded: photo),
                      var image = UIImage(data: base64),
                      let id = _photo["id"] as? String else { continue }
                image = ImageProcessing.downsample(image: image, to: downscaled) ?? image
                try? base64.write(to: self.imagesFolder.appendingPathComponent("\(id).png"))
                self.imageCache.setObject(image, forKey: id as NSString)
            }
        }
    }
    
    public func loadForMessages() {
        let _senders = Array(PersistenceDatabase.shared.messages.values).map { $0.sender }
        var senders = [String: Sender]()
        for _sender in _senders {
            senders[_sender.id] = _sender
        }
        let ids = Array(senders.values).map { $0.id! }
        Photos.shared.getEmployeePictures(for: ids)
    }
    
    public func getImage(for id: String, size: CGSize, _ completion: @escaping (UIImage) -> Void) -> UIImage? {
        if let image = imageCache.object(forKey: id as NSString) {
            return image
        }
        if self.imagesFolder.appendingPathComponent("\(id).png").exists {
            Self.backgroundQueue.async {
                if let data = try? Data(contentsOf: self.imagesFolder.appendingPathComponent("\(id).png")),
                   var image = UIImage(data: data) {
                    image = ImageProcessing.downsample(image: image, to: size) ?? image
                    self.imageCache.setObject(image, forKey: id as NSString)
                    completion(image)
                }
            }
        } else {
            getEmployeePictures(for: [id], downscaled: size) {
                if let image = self.imageCache.object(forKey: id as NSString) {
                    completion(image)
                }
            }
            return UIImage(systemName: "person.crop.circle")
        }
        return nil
    }
    
    public class func getStudentPictures(for ids: [String]) {
        /*
        try? FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        let array = 0...1000
        let string = array.map { String($0) }
        print(string)
        EvanderNetworking.edulinkDict(method: "EduLink.LearnerPhotos", params: [
            .custom(key: "learner_ids", value: string),
            .custom(key: "size", value: 1)
        ], timeout: 3000000) { _, _, error, result in
            print("Error = \(error), result = \(result)")
            guard let result = result,
                  let photos = result["learner_photos"] as? [[String: Any]] else { return }
            for _photo in photos {
                guard let photo = _photo["photo"] as? String,
                      let base64 = Data(base64Encoded: photo) else { continue }
                try? base64.write(to: imagesFolder.appendingPathComponent("\(_photo["id"] ?? "Unknown").png"))
            }
        }
         */
    }
    
    public func dumpAllEmployeePhotos(imageCompletion: @escaping (UIImage) -> (), completion: @escaping () -> ()) {
        let array = SafeArray<UIImage>(queue: Self.backgroundQueue, key: Self.queueKey, context: Self.queueContext)
        func handleImages() {
            while let image = array.first {
                array.remove(at: 0)
                if let downscaled = ImageProcessing.downsample(image: image) {
                    imageCompletion(downscaled)
                }
            }
        }
        func work(from: Int) {
            if cancelDump {
                cancelDump = false
                return completion()
            }
            let to = from + 1000
            if from > 100000 {
                return completion()
            }
            let range = from...to
            let string = range.map { String($0) }
            EvanderNetworking.edulinkDict(method: "EduLink.TeacherPhotos", params: [
                .custom(key: "employee_ids", value: string),
                .custom(key: "size", value: 1024)
            ], timeout: 120) { _, _, error, result in
                guard let result = result,
                      let photos = result["employee_photos"] as? [[String: Any]] else { return }
                for _photo in photos {
                    guard let photo = _photo["photo"] as? String,
                          let base64 = Data(base64Encoded: photo),
                          let image = UIImage(data: base64) else { continue }
                    array.append(image)
                }
                handleImages()
                work(from: to + 1)
            }
        }
        work(from: 0)
    }
    
}
