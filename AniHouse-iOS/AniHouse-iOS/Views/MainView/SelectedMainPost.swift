//
//  SelectedMainPost.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/05/07.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct SelectedMainPost: View {
    
    @ObservedObject var storeManager = MainPostViewModel()
    
    @State var post: MainPost = MainPost() // 게시글 객체를 넘겨받음.
    @State var hitValue: Int = 0 // 현재 좋아요 개수
    @State private var animate = false // 애니매이션 동작여부
    @State var isLiked: Bool = false // 현재 유저가 좋아요를 체크했는지 여부
    @State var dateString: String = ""
    
    private let animationDuration: Double = 0.1
    private var animationScale: CGFloat {
        self.isLiked ? 0.7 : 1.3
    }

    let user = Auth.auth().currentUser // 현재 유저객체
    @State var url = ""
    
    // 좋아요 애니메이션
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                Rectangle().frame(height: 0)
                if url != "" {
                    AnimatedImage(url: URL(string: url)!)
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(10)
                } else {
                    Loader()
                }
                HStack {
                    Button {
                        //action
                        if isLiked {
                            /// 게시글의 좋아요를 누른 상태일 때 Like를 지운다.
                            DispatchQueue.main.async {
                                storeManager.deleteLike(post: self.post, currentUser: self.user?.email ?? "")
                            }
                            self.isLiked.toggle()
                            hitValue -= 1
                        } else {
                            /// 좋아요를 누르지 않은 상태일 때
                            DispatchQueue.main.async {
                                storeManager.addLike(post: self.post, currentUser: self.user?.email ?? "")
                                
                            }
                            self.isLiked.toggle()
                            hitValue += 1
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration, execute: {
                            self.animate = false
//                            self.isLiked.toggle()
                        })
                    } label: {
                        Image(systemName: self.isLiked ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(self.isLiked ? .red : .gray)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 3)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading)
                    .scaleEffect(animate ? animationScale : 1)
                    .animation(Animation.easeIn(duration: animationDuration), value: animationScale)
                    Text("\(self.hitValue)")
                        .padding(.leading, 3)
                    Spacer()
                }
                
                Text("\(post.title)")
                    .font(Font.custom("KoreanSDNR-B", size: 20))
                    .fontWeight(.semibold)
                    .padding(5)
                Text("\(post.body)")
                    .font(Font.custom("KoreanSDNR-M", size: 16))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    .lineSpacing(3)
                Text(self.dateString)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                Spacer()
            }
            .onAppear {
                let storage = Storage.storage().reference()
                storage.child("MainPostImage/\(post.id).jpg").downloadURL { url, err in
                    if err != nil {
                        print((err?.localizedDescription)!)
                        return
                    }
                    self.url = "\(url!)"
                }
                self.hitValue = post.hit
                if post.likeUsers.contains(user?.email ?? "") {
                    isLiked = true
                } else {
                    isLiked = false
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
                dateString = formatter.string(from: post.date)
                
            }
        }
        
        .navigationTitle("\(post.title)")
        .navigationBarTitleDisplayMode(.inline)
        
        
        
    }
    
}

struct SelectedMainPost_Previews: PreviewProvider {
    static var previews: some View {
        SelectedMainPost(post: MainPost())
    }
}
