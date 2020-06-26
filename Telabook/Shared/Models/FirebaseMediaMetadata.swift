//
//  FirebaseMediaMetadata.swift
//  Telabook
//
//  Created by Anmol Rajpal on 26/06/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation
struct FirebaseMediaMetadata : Codable {
    
    let bucket : String?
    let contentDisposition : String?
    let contentEncoding : String?
    let contentType : String?
    let crc32c : String?
    let downloadTokens : String?
    let etag : String?
    let generation : String?
    let md5Hash : String?
    let metageneration : String?
    let name : String?
    let size : String?
    let storageClass : String?
    let timeCreated : String?
    let updated : String?
    
    enum CodingKeys: String, CodingKey {
        case bucket = "bucket"
        case contentDisposition = "contentDisposition"
        case contentEncoding = "contentEncoding"
        case contentType = "contentType"
        case crc32c = "crc32c"
        case downloadTokens = "downloadTokens"
        case etag = "etag"
        case generation = "generation"
        case md5Hash = "md5Hash"
        case metageneration = "metageneration"
        case name = "name"
        case size = "size"
        case storageClass = "storageClass"
        case timeCreated = "timeCreated"
        case updated = "updated"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bucket = try values.decodeIfPresent(String.self, forKey: .bucket)
        contentDisposition = try values.decodeIfPresent(String.self, forKey: .contentDisposition)
        contentEncoding = try values.decodeIfPresent(String.self, forKey: .contentEncoding)
        contentType = try values.decodeIfPresent(String.self, forKey: .contentType)
        crc32c = try values.decodeIfPresent(String.self, forKey: .crc32c)
        downloadTokens = try values.decodeIfPresent(String.self, forKey: .downloadTokens)
        etag = try values.decodeIfPresent(String.self, forKey: .etag)
        generation = try values.decodeIfPresent(String.self, forKey: .generation)
        md5Hash = try values.decodeIfPresent(String.self, forKey: .md5Hash)
        metageneration = try values.decodeIfPresent(String.self, forKey: .metageneration)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        size = try values.decodeIfPresent(String.self, forKey: .size)
        storageClass = try values.decodeIfPresent(String.self, forKey: .storageClass)
        timeCreated = try values.decodeIfPresent(String.self, forKey: .timeCreated)
        updated = try values.decodeIfPresent(String.self, forKey: .updated)
    }
    
}
