//
//  ViewController.swift
//  testScrape
//
//  Created by Umair Sharif on 3/24/17.
//  Copyright © 2017 usharif. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

private let baseURL = "http://www.snopes.com/category/facts/"

class ViewController: UIViewController {
    var arrayOfCategories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrapeCategories()
    }

    private func scrapeCategories() {
        Alamofire.request(baseURL).responseString(completionHandler: {response in
            if let html = response.result.value {
                self.arrayOfCategories = self.getCategories(html: html)
            }
            for category in self.arrayOfCategories {
                self.scrapeCategory(categoryURL: category.url)
            }
        })
    }
    
    private func scrapeCategory(categoryURL: String) {
        Alamofire.request(categoryURL).responseString(completionHandler: {response in
            if let html = response.result.value {
                print(categoryURL)
                self.getCategoryStories(html: html)
            }
        })
    }
    
    private func getCategoryStories(html: String) {
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for title in doc.css("h2[class^='article-link-title']") {
                if title.className == "article-link-title" {
                    if let _title = title.text {
                        if _title.contains("?") {
                            print(_title)
                        }
                    }
                }
            }
        }
    }
    
    private func getCategories(html: String) -> [Category] {
        var arrayOfCategories = [Category]()
        if let doc = Kanna.HTML(html: html, encoding: .utf8) {
            for link in doc.css("a, link") {
                if link.parent?.parent?["id"] == "menu-archives-subnavigation" {
                    var tempCategory = Category(title: "", url: "")
                    if let _linkTitle = link.text {
                        tempCategory.title = _linkTitle
                    }
                    if let _linkURL = link["href"] {
                        tempCategory.url = _linkURL
                    }
                    arrayOfCategories.append(tempCategory)
                }
            }
        }
        return arrayOfCategories
    }
}
struct Category {
    var title: String
    var url: String
}
