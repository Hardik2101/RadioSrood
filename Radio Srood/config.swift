
import UIKit

let BASE_BACKEND_URL                 =     "http://pamirtech.com/backend/srood/" // your  backend
let baseURL = "https://radiosrood.com/api/"
let recentListURL = baseURL + "currentsongappv2.json"
let currentLyricURL = baseURL + "currentlyric.json"
let songPath = "http://mediahost.6cp4ukzdmze0dz21tovov7shhs1ldq5x.srood.stream/media/mp3/"
let musicBaseUrl = "https://api.radiosrood.com/static/app/api/"
let redioHomeURL = musicBaseUrl + "rSroodMusicPageData.json"
let newReleaseURL = musicBaseUrl + "newRelease.json"
let trendingPlaylistURL = musicBaseUrl + "trendingTracks.json"
let popularPlaylistURL = musicBaseUrl + "popularTracks.json"
let playlistURL = musicBaseUrl + "rSroodPlaylistData.json"
let featuredArtistURL = musicBaseUrl + "rSroodFeaturedArtistData.json"
let lyricsURL = "https://api.radiosrood.com/static/app/lyrics/"
let GOOGLE_ADMOB_KEY                 =    IAPHandler.shared.isGetPurchase() ? "" :  "ca-app-pub-7049872613588191/4747855668"
let GOOGLE_ADMOB_INTER               =    IAPHandler.shared.isGetPurchase() ? "" : "ca-app-pub-7049872613588191/5635919690"
let GOOGLE_ADMOB_NATIVE              =    IAPHandler.shared.isGetPurchase() ? "" :  "ca-app-pub-7049872613588191/7385126578"
let GOOGLE_ADMOB_ForMiniPlayer             =    IAPHandler.shared.isGetPurchase() ? "" :  "ca-app-pub-7049872613588191/5977355028"

let GOOGLE_ADMOB_ForMusicPlayer             =    IAPHandler.shared.isGetPurchase() ? "" :  "ca-app-pub-7049872613588191/7260832328"


//ca-app-pub-7049872613588191/7260832328 /// for music player banner
//ca-app-pub-7049872613588191/5977355028 /// for mini player banner

let ONESIGNAL_APP_KEY                =     "cc867855-4271-4909-aa4b-24a48b4319f7"

let SHOW_BANNER_ADMOB                =     true // true - show ads, false - not

let SECONDS_BEFORE_SHOW_INTERSTITIAL =     10

let SHOW_PODCAST                     =     true    // true - show modules , false - hide module
let SHOW_ABOUT                       =     true
let SHOW_NEWS                        =     true
let SHOW_TIMELINE                    =     true
let DOWNLOAD_PODCAST                 =     true
let LOCAL_NOTIFICATION               =     false

//let inappPrefix = "com.appteve.lavradio."  // in-app purchase
//let inapp1 = "ad"
//let inapp2 = "tl"

let FACEBOOK_URL                     =     "https://facebook.com/radiosrood"
let GOOGLE_URL                       =     "https://instagram.com/radiosrood"
let TWITTER_URL                      =     "https://twitter.com/radiosrood"

var screenSize: CGSize {
    return UIScreen.main.bounds.size
}




