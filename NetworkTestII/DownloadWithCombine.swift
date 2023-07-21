//
//  DownloadWithCombine.swift
//  NetworkTestII
//
//  Created by Dr Cpt Blackbeard on 7/20/23.
//

import SwiftUI

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
