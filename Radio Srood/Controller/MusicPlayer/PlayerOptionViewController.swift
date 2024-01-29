//
//  PlayerOptionViewController.swift
//  Radio Srood
//
//  Created by Tech on 24/05/2023.
//  Copyright © 2023 Appteve. All rights reserved.
//

import UIKit
 
class PlayerOptionViewController: UIViewController , PlayListViewControllerDelegate {
    @IBOutlet weak var lblPlayedSongtitle: UILabel!
    @IBOutlet weak var lblPlayedSongName: UILabel!
    @IBOutlet weak var imgPlayedSong: UIImageView!
    @IBOutlet weak var viewLyrics: UIView!
    @IBOutlet weak var lblMyMusic: UILabel!
    var currentSong = SongModel()
    var isMyMusic = false
    override func viewDidLoad() {
        super.viewDidLoad()
        isAlreadyInMyMusic(track: currentSong)
        if currentSong.lyric_synced == ""{
            self.viewLyrics.isHidden  = true
        }
        
        lblPlayedSongtitle.text = currentSong.artist
        lblPlayedSongName.text = currentSong.track
        if let url = URL(string: currentSong.artcover) {
            imgPlayedSong.af_setImage(withURL: url, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
        }
        // Do any additional setup after loading the view.
    }
    
    func isAlreadyInMyMusic(track : SongModel){
        let savedTracks = UserDefaultsManager.shared.localTracksData
        let isInMyMusic = savedTracks.filter({$0.isBookMarked && track.trackid == $0.trackid})
        if isInMyMusic.count > 0{
            isMyMusic = true
        }
        if isMyMusic {
            self.lblMyMusic.text = "Remove from My Collection"
        } else {
            self.lblMyMusic.text = "Add to My Collection"
        }
    }
    
    func configureMyMusicPlayed(){
        let item = currentSong
        var savedTracks = UserDefaultsManager.shared.localTracksData
        let trackIndex = savedTracks.firstIndex(where: {$0.trackid == item.trackid})
        if let trackIndex = trackIndex{
            savedTracks[trackIndex].isBookMarked = !savedTracks[trackIndex].isBookMarked
        }
        else{
            let newItem = item
            newItem.isBookMarked = true
            savedTracks.append(newItem)
        }
        UserDefaultsManager.shared.localTracksData = savedTracks
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.dismiss(animated: true)
   
    }
    @IBAction func actionMusic(_ sender: Any) {
        isMyMusic = !isMyMusic
        if isMyMusic {
            self.lblMyMusic.text = "Remove from My Collection"
        } else {
            self.lblMyMusic.text = "Add to My Collection"
        }
        configureMyMusicPlayed()
    }
   
    @IBAction func actionShare(_ sender: Any) {
        let songTitle = currentSong.track
        let artistName = currentSong.artist

        // Create a string with the song details you want to share
        let shareText = "Check out this awesome song: \(songTitle) by \(artistName)"

        // Create an array of items to share
        var items: [Any] = [shareText]

        // Add the image to the array if available
        if let image = imgPlayedSong.image {
            items.append(image)
        }

        // Create a UIActivityViewController to display the Share Sheet
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Exclude some activities if needed
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact]

        // Present the Share Sheet
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func actionLyrics(_ sender: Any) {
        if currentSong.lyric_synced != ""{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LyricPlayViewController") as! LyricPlayViewController
            vc.lyricsUrl = "\(lyricsURL)\(currentSong.lyric_synced)"
            vc.currentSong = currentSong
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func actionAddPlayList(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayListViewController") as! PlayListViewController
        vc.songToSave = self.currentSong
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func songSavedToList() {
        
    }
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 36))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 18;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
