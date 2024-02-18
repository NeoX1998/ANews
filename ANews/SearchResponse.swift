//
//  SearchResponse.swift
//  ANews
//
//  Created by 許博皓 on 2023/7/20.
//

import Foundation

struct SearchResponse: Codable {
    let articles: [Article]

    struct Article: Codable {
        let title: String?
        let url: String?
        let urlToImage: URL?
    }
}
