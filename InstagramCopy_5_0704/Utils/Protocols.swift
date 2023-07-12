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
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTapped: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol Printable {
    var description: String { get }
}
