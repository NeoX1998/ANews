//
//  NewsTableViewController.swift
//  ANews
//
//  Created by 許博皓 on 2023/7/12.
//

import UIKit
import SafariServices
import GoogleMobileAds

class NewsTableViewController: UITableViewController {
    
    var bannerView: GADBannerView!
    
    var news =  [News]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        refreshControl()
        
        // 宣告橫幅廣告物件
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        addBannerViewToView(bannerView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return news.count
    }
    
    func refreshControl() {
            refreshControl = UIRefreshControl()
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white] //文字顏色
            refreshControl?.attributedTitle = NSAttributedString(string: "Loading...", attributes: attributes) //顯示字串內容
            refreshControl?.tintColor = UIColor.white //元件顏色
            refreshControl?.backgroundColor = UIColor.systemGray4 //下拉背景顏色
            refreshControl?.addTarget(self, action: #selector(fetchData), for: UIControl.Event.valueChanged) //下拉後執行動作
            tableView.addSubview(refreshControl!)
    }
    
   // MARK: Data Source
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! NewsTableViewCell

       var ar: News
       ar = news[indexPath.row]

       cell.titleLabel.text = ar.title
       
       if ar.image == URL(string: "about:blank") {
           cell.newsImageView?.image = UIImage(systemName: "photo")
       }
       else{
           DispatchQueue.global().async {
               // Fetch Image Data
               if let data = try? Data(contentsOf: ar.image) {
                   DispatchQueue.main.async {
                       // Create Image and Update Image View
                       cell.self.newsImageView.image = UIImage(data: data)
                   }
               }
           }
       }
       return cell
   }
    
    //使用者選取列之後,呼叫列的選取
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = news[indexPath.row].link
        let URL1 = URL(string: url)
        if  url.prefix(23) == "https://www.youtube.com" { //如果連結是youtube的話切換到瀏覽器打開
            UIApplication.shared.open(URL1 ?? URL(string: "about:blank")!)
        }else {
            //使用APP內嵌的Safari開啟網頁內容
            let safariController = SFSafariViewController(url: URL1 ?? URL(string: "about:blank")!)
            present(safariController, animated: true, completion: nil)
        }
        
        //取消列的選取: 選取完後不會有灰色突出
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func fetchData() {
        let categoryNum = Int.random(in: 0..<9)
        var category = ""

        switch categoryNum {
            case 0: category = "business"
            case 1: category = "entertainment"
            case 2: category = "health"
            case 3: category = "science"
            case 4: category = "sports"
            case 5: category = "technology"
            default:
                break
        }
        
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=f42fae20e1f44dbe8a37744d109ca89f"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data {
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        // 將解碼後的資料取出需要的項目整理到新的array中
                        var newArticles: [News] = []
                        for i in searchResponse.articles {
                            let newArticle = News(title: i.title ?? "There is no title.",
                                                  image: i.urlToImage ?? URL(string: "about:blank")!,
                                                  link: i.url ?? "about:blank")
                                newArticles += [newArticle]
                        }
    
                        self.news = newArticles
                        // 更新畫面必須要用main thread
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing() //停止 refreshControl()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }

}
