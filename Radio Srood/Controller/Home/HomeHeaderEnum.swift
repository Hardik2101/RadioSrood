
import UIKit

enum HomeHeader: Int, CaseIterable {
    case newReleases
    case currentRadio
    case trending
    case popularTracks
    case playlists
    case myPlaylist
    case recentlyPlayed
    case featuredArtist
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Releases"
        case .currentRadio:
            return "Currently Playing on Radio srood"
        case .trending:
            return "Trending"
        case .popularTracks:
            return "Popular Tracks"
        case .playlists:
            return "Playlists"
        case .myPlaylist:
            return "My Playlist"
        case .recentlyPlayed:
            return "Recently Played"
        case .featuredArtist:
            return "Featured Artist"
        }
    }
}
