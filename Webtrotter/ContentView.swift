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
    
    @State var showActivityIndicator: Bool = false
    @State var searchResults: [SearchResult] = []
    @State var searchQuery: String = ""
    
    var body: some View {
        TabView {
            
            NavigationView {
                List(searchResults, id: \.link) { searchResult in
                    HStack(alignment: .center, spacing: 2.0) {
                        VStack(alignment: .leading, spacing: 2.0) {
                            Spacer(minLength: 2.0)
                            Text(verbatim: searchResult.title)
                                .font(.body)
                                .foregroundColor(.accentColor)
                            Text(verbatim: searchResult.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(verbatim: searchResult.link)
                                .font(.caption)
                            Spacer(minLength: 2.0)
                        }
                        .onTapGesture {
                            UIApplication.shared.open(URL(string: searchResult.link)!)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.grouped)
                .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Google Search")
                .onSubmit(of: .search, {
                    Task {
                        showActivityIndicator = true
                        searchResults = await loadSearchResults(query: searchQuery)
                        showActivityIndicator = false
                    }
                })
                .refreshable {
                        searchResults = await loadSearchResults(query: searchQuery)
                    }
                .overlay(content: {
                    if showActivityIndicator {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                })
                .navigationTitle("Web Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            NavigationView {
                List {
                }
                .navigationTitle("Image Search")
            }
            .tabItem {
                Label("Images", systemImage: "photo.on.rectangle.angled")
            }
            
            NavigationView {
                List {
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellGitHub")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("Get the source code")
                                .font(.body)
                            Text("katagaki/Webtrotter")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://github.com/katagaki/Webtrotter")!)
                    }
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellTwitter")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("Tweet me")
                                .font(.body)
                            Text("@katagaki_")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "https://twitter.com/katagaki_")!)
                    }
                    HStack(alignment: .center, spacing: 16.0) {
                        Image("CellEmail")
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("Email me")
                                .font(.body)
                            Text(verbatim: "ktgk.public@icloud.com")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: "mailto:ktgk.public@icloud.com")!)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            
        }
    }
    
    func setSearchResults(searchResults: [SearchResult]) {
        self.searchResults = searchResults
    }
    
}

struct ContentView_Previews: PreviewProvider {
    
    static var dummyData: [SearchResult] = [SearchResult(title: "Lorem Ipsum Dolor Amet",
                                                         description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sapien massa, auctor sed dolor nec, accumsan scelerisque turpis. Sed in dignissim mi, et...",
                                                         link: "https://www.lipsum.com"),
                                            SearchResult(title: "Suspendisse nec felis non erat convallis",
                                                         description: "Suspendisse faucibus tempor felis a viverra. Maecenas nibh tortor, luctus ac sodales sit amet, congue nec turpis. Proin mi felis, ultrices feugiat ultrices quis, lobortis scelerisque ante.",
                                                         link: "https://www2.suspendisse.com"),
                                            SearchResult(title: "Vestibulum - Ante",
                                                         description: "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia ...",
                                                         link: "https://www.vestibulum-ante.org")]
    static var previews: some View {
        Group {
            ContentView(searchResults: dummyData)
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .previewDisplayName("iPhone 12")
                .preferredColorScheme(.light)
            ContentView(searchResults: dummyData)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
                .preferredColorScheme(.dark)
        }
    }
}

func loadSearchResults(query: String) async -> [SearchResult] {
    var searchResults: [SearchResult] = []
    
    if query != "" {
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
    return searchResults
}
