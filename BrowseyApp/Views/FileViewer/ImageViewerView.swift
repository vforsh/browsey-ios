import SwiftUI

struct ImageViewerView: View {
    let imageURL: URL

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(magnificationGesture)
                        .gesture(dragGesture)
                        .gesture(doubleTapGesture(in: geometry.size))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failure:
                    ContentUnavailableView {
                        Label("Failed to Load", systemImage: "photo")
                    } description: {
                        Text("Could not load the image")
                    }

                @unknown default:
                    EmptyView()
                }
            }
        }
        .background(.black)
        .ignoresSafeArea()
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1 {
                    withAnimation {
                        scale = 1
                        offset = .zero
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func doubleTapGesture(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring()) {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                        lastOffset = .zero
                    } else {
                        scale = 2
                    }
                }
            }
    }
}

#Preview {
    ImageViewerView(imageURL: URL(string: "https://picsum.photos/800/600")!)
}
