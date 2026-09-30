import SwiftUI

public struct MovieCatalogView: View {
    @ObservedObject public var appVM: AppViewModel
    @ObservedObject public var catalogVM: CatalogViewModel
    @ObservedObject public var playerVM: PlayerViewModel
    
    private let movieColumns = [
        GridItem(.adaptive(minimum: 140, maximum: 170), spacing: 14)
    ]
    
    public init(
        appVM: AppViewModel,
        catalogVM: CatalogViewModel,
        playerVM: PlayerViewModel
    ) {
        self.appVM = appVM
        self.catalogVM = catalogVM
        self.playerVM = playerVM
    }
    
    public var body: some View {
        let movies = catalogVM.filteredMovies(from: appVM.catalog.movies, in: appVM.selectedGroup)
        
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search movies...", text: $catalogVM.searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.07)))
                .frame(maxWidth: 240)
                
                Spacer()
                Text("\(movies.count) movies").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            
            Divider()
            
            if movies.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "film.slash").font(.system(size: 40)).foregroundColor(.secondary.opacity(0.5))
                    Text("No movies found").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: movieColumns, spacing: 16) {
                        ForEach(movies) { movie in
                            MoviePosterCard(movie: movie) {
                                playerVM.playMovie(movie)
                            }
                        }
                    }
                    .padding(14)
                }
            }
        }
    }
}

private struct MoviePosterCard: View {
    let movie: Movie
    let onPlay: () -> Void
    @State private var isHovered = false
    @State private var posterImage: NSImage?
    
    var body: some View {
        Button(action: onPlay) {
            VStack(alignment: .leading, spacing: 6) {
                // Poster
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                    
                    if let img = posterImage {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        VStack {
                            Image(systemName: "film")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Rating Badge
                    if let rating = movie.rating, rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill").font(.system(size: 8)).foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                        }
                        .padding(4)
                        .background(Capsule().fill(.ultraThinMaterial))
                        .padding(6)
                    }
                }
                .frame(height: 200)
                
                Text(movie.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                
                if let genre = movie.genre {
                    Text(genre)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 140)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .task {
            if let url = movie.posterURL {
                posterImage = await ImageCacheActor.shared.image(for: url, targetSize: CGSize(width: 140, height: 200))
            }
        }
    }
}
