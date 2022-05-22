//
//  ContentView.swift
//  Webtrotter
//
//  Created by 堅書 on 2022/05/22.
//

import SafariServices
import SwiftSoup
import SwiftUI

struct ContentView: View {
    
//    @State var showSafariViewController: Bool = false
    @State var searchResults: [SearchResult] = []
    @State var searchQuery: String = ""
    
    var body: some View {
        NavigationView {
            List(searchResults, id: \.link) { searchResult in
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(searchResult.title)
                        .font(.body)
                    Text(searchResult.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(searchResult.link)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .onTapGesture {
                    UIApplication.shared.open(URL(string: searchResult.link)!)
                    //showSafariViewController.toggle()
                }
//                .sheet(isPresented: $showSafariViewController, content: {
//                    SafariView(url: URL(string: searchResult.link)!)
//                })
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchQuery, prompt: "Google Search")
            .onSubmit(of: .search, {
                Task {
                    await loadSearchResults(query: searchQuery)
                }
            })
            .refreshable {
                    await loadSearchResults(query: searchQuery)
                }
            .navigationTitle("Search")
            }
    }
    
    func loadSearchResults(query: String) async {
        if let searchURL = URL(string: "https://google.com/search?q=\(query.urlEncoded)&hl=en") {
            var request = URLRequest(url: searchURL)
            request.httpMethod = "GET"
            request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36", forHTTPHeaderField: "User-Agent")
            request.addValue("*/*", forHTTPHeaderField: "Accept")
            request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let html = String(data: data, encoding: .utf8)!
                let doc: Document = try parse(html)
                let searchResultsHTML: Elements = try doc.getElementById("search")!.getElementsByClass("v7W49e").get(0).getElementsByTag("div")

                for searchResultHTML: Element in searchResultsHTML {
                    if searchResultHTML.hasClass("jtfYYd") || searchResultHTML.hasClass("tF2Cxc") {
                        var searchResultObject: SearchResult = SearchResult()
                        
                        // Get title of search result
                        if let titles: Elements = try searchResultHTML.getElementsByTag("h3") as Elements? {
                            if titles.count >= 1 {
                                searchResultObject.title = try titles.get(0).text()
                            }
                        }
                        
                        // Get description of search result
                        if let divs: Elements = try searchResultHTML.getElementsByTag("div") as Elements? {
                            for div: Element in divs {
                                if div.hasClass("VwiC3b") && div.hasClass("yXK7lf") && div.hasClass("MUxGbd") && div.hasClass("yDYNvb") && div.hasClass("lyLwlc") {
                                    searchResultObject.description = try div.text()
                                }
                            }
                        }
                        
                        // Get link of search result
                        if let links: Elements = try searchResultHTML.getElementsByTag("link") as Elements? {
                            if links.count >= 1 {
                                searchResultObject.link = try links.get(0).attr("href")
                            }
                        }
                        if let links: Elements = try searchResultHTML.getElementsByTag("a") as Elements? {
                            if links.count >= 1 {
                                searchResultObject.link = try links.get(0).attr("href")
                            }
                        }
                        
                        if searchResultObject.hasAllValues() {
                            if !searchResults.contains(where: { searchResult in
                                searchResult == searchResultObject
                            }) {
                                searchResults.append(searchResultObject)
                            }
                        }
                    }
                }
            } catch {
                print("Could not get search results.")
            }
        } else {
            print("Invalid search query.")
        }
    }
    
}

//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//        return
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
