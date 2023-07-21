//
//  DownloadWithCombine.swift
//  NetworkTestII
//
//  Created by Dr Cpt Blackbeard on 7/20/23.
//

import SwiftUI
import Combine // this gives us cancellables

// Model
struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// View Model
class DownloadWithCombineViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            print("Invalid URL.")
            return
        }
        
        // Combine analogy
        /*
        // 1. sign up for a monthly subscription for package to be delivered
        // 2. the company would make the package behind the scenes
        // 3. recieve the package at your front door
        // 4. make sure package isn't damaged
        // 5. open and make sure the item inside is correct
        // 6. use the item
        // 7. cancellable at any time
         */
        
        URLSession.shared.dataTaskPublisher(for: url)
        // 2. subscribe publisher on background thread (note we are subscribed to the backgorund thread by default)
            .subscribe(on: DispatchQueue.global(qos: .background))
        // 3. recieve on the main thread
            .receive(on: DispatchQueue.main)
        // 4. tryMap to check that the data is good
            .tryMap { (data, response) -> Data in
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
        // 5. decode data into PostModels (decode into our data model)
            .decode(type: [PostModel].self, decoder: JSONDecoder())
        // 6. sink (put the item into our app)
            .sink { (completion) in
                print("COMPLETION: \(completion)")
                switch completion {
                case .finished:
                    print("Finished!")
                case .failure(let recievedError):
                    print("There was an error. \(recievedError)")
                }
            } receiveValue: { [weak self] (returnedPosts) in /// we put weak self to force the self below to be converted from strong to weak. We don't need it floating in memory.
                self?.posts = returnedPosts /// we put returned posts into posts if successful
            }
        // 7. store (cancel subscription if needed - we are storing a reciept for our subscription so we know which to cancel)
            .store(in: &cancellables)
    }
    
}

// View
struct DownloadWithCombine: View {
    @StateObject var vm = DownloadWithCombineViewModel()
    
    var body: some View {
        List {
            ForEach(vm.posts) { post in
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct DownloadWithCombine_Previews: PreviewProvider {
    static var previews: some View {
        DownloadWithCombine()
    }
}
