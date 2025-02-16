//
//  AnimationCardView.swift
//  PodcastAlbumCards
//
//  Created by HASAN BERAT GURBUZ on 10.10.2024.
//

import SwiftUI

struct AnimationCardView: View {

    // MARK: - PROPERTIES

    @State private var expandCards = false
    @State private var currentCard: Album?
    @State private var showDetail = false
    @State private var currentIndex = -1
    @State private var cardSize: CGSize = .zero
    @State private var rotateCards = false
    @State private var animateSingleView = false
    @State private var showDetailContent = false
    @Namespace private var animation

    // MARK: - BODY
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let offsetHeight = size.height * 0.1
            ZStack {
                ForEach(albumCards.reversed()) { album in
                    let index = getIndex(album: album)
                    let imageSize = (size.width - (CGFloat(index) * 20))
                    Image(album.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize / 1.5, height: imageSize / 1.5)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .matchedGeometryEffect(id: album.id ,in: animation)
                        .offset(y: CGFloat(index) * -20)
                        .offset(y: expandCards ? -CGFloat(index) * offsetHeight : 0)
                        .onTapGesture {
                            if expandCards {
                                withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8)) {
                                    cardSize = CGSize(width: imageSize / 1.5, height: imageSize / 1.5)
                                    currentCard = album
                                    currentIndex = index
                                    showDetail = true
                                    rotateCards = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring) {
                                            animateSingleView = true
                                        }
                                    }
                                }
                            } else {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    expandCards = true
                                }
                            }
                        }
                        .offset(y: showDetail && currentIndex != index ? size.height * (currentIndex < index ? -1 : 1) : 0)
                }
            }
            .offset(y: expandCards ? offsetHeight * 2 : 0)
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                    expandCards.toggle()
                }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
        }
        .overlay {
            if let currentCard, showDetail {
                ZStack {
                    Color(.white)
                        .ignoresSafeArea()
                    SingleCardView(album: currentCard)
                }
            }
        }
    }

    // MARK: - PRIVATE VIEW FUNCTIONS

    private func SingleCardView(album: Album) -> some View {
        VStack(spacing: 0) {
            Button {
                rotateCards = false
                withAnimation {
                    showDetailContent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8)) {
                        self.currentIndex = -1
                        self.currentCard = nil
                        showDetail = false
                        animateSingleView = false
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25, content: {
                    Image(album.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .rotation3DEffect(.init(degrees: showDetail && rotateCards ? -180 : 0), axis: (x: 1, y: 0, z: 0), anchor: .center, anchorZ: 1, perspective: 1)
                        .rotation3DEffect(.init(degrees: animateSingleView && rotateCards ? 180 : 0), axis: (x: 1, y: 0, z: 0), anchor: .center, anchorZ: 1, perspective: 1)
                        .matchedGeometryEffect(id: album.id, in: animation)
                        .padding(.top, 50)
                    
                    // MARK: - Control Bar
                    VStack(spacing: 20) {
                        ControlBarView(album: album)
                        TrackListView(albums: albumCards)
                    }
                })
            }
        }
    }

    @ViewBuilder
    private func ControlBarView(album: Album) -> some View {
        Text(album.name)
            .font(.title2.bold())
            .padding(.top, 10)
        HStack(spacing: 50) {
            Button {
                // Action
            } label: {
                Image(systemName: "shuffle")
                    .font(.title2)
            }
            Button {
                // Action
            } label: {
                Image(systemName: "pause.fill")
                    .font(.title3)
                    .frame(width: 55, height: 55)
                    .background(Circle().fill(.blue.opacity(0.2)))
            }
            Button {
                // Action
            } label: {
                Image(systemName: "arrow.2.squarepath")
                    .font(.title2)
            }
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private func TrackListView(albums: [Album]) -> some View {
        Text("Upcoming Tracks")
            .font(.title2.bold())
            .padding(.top, 20)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        
        ForEach(albums) { album in
            HStack(spacing: 12) {
                Image(album.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 8) {
                    Text(album.name)
                        .fontWeight(.semibold)
                    Label {
                        Text("1.000.000")
                    } icon: {
                        Image(systemName: "headphones.circle")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - FUNCTIONS

    private func getIndex(album: Album) -> Int {
        return albumCards.firstIndex { currentAlbum in return album.id == currentAlbum.id } ?? 0
    }
}

// MARK: - PREVIEW

#Preview {
    AnimationCardView()
}
