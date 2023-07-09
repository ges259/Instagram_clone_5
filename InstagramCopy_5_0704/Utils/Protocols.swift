//
//  Protocols.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/06.
//





protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}


protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cel: FeedCell)
    func handleLikeTapped(for cel: FeedCell)
    func handleCommentTapped(for cel: FeedCell)
}
