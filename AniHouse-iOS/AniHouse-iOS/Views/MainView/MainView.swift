//
//  MainView.swift
//  AniHouse-iOS
//
//  Created by Jaehoon So on 2022/04/28.
//

import SwiftUI
import FirebaseStorage

enum LayoutType: CaseIterable {
    case all, dog, cat, reptiles, bird, fish
}

extension LayoutType {
    // 레이아웃 타입에 대한 컬럼이 자동으로 설정되도록 한다.
    
}

struct MainView: View {
    
    @State var selectedLayoutType: LayoutType = .all
    @State var url = ""
    var image: UIImage? = UIImage(named: Constant.ImageName.defaultImage)
    let defaultImage: UIImage = UIImage(named: Constant.ImageName.defaultImage)!
    
    @EnvironmentObject var mainFirestoreViewModel: MainPostViewModel
    @EnvironmentObject var storageManager: StorageManager
    @EnvironmentObject var userInfoManager: UserInfoViewModel
    
    
    var columns = [
        GridItem(.flexible(minimum: 120, maximum: 160), spacing: 20, alignment: nil),
        GridItem(.flexible(minimum: 120, maximum: 160), spacing: 20, alignment: nil)
    ]
    
    var body: some View {
        
        
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            //임시로 더미를 출력
                            ForEach(mainFirestoreViewModel.posts, content: { (dataItem: MainPost) in
                                NavigationLink {
                                    SelectedMainPost(post: dataItem)
                                } label: {
                                    MainViewCell(post: dataItem)
//                                        .padding(.horizontal, 5)
                                }

                            })
                        }
                    } // ScrollView
                    .padding(0)
                } // VStack
                
                NavigationLink {
                    AddPostView()
                } label: {
                    Circle()
                        .foregroundColor(Color(Constant.ButtonColor.addButton))
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundColor(Color.white)
                                .font(.system(size: 35))
                        }
                }

            } // ZStack
            .navigationTitle("🐶 우리 가족 소개하기")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                mainFirestoreViewModel.getData()
                userInfoManager.getUserNickName()
                
            }
        }
        
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
