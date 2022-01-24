//
//  EndpointSortable.swift
//  RedditFeed
//
//  Created by Farid Kopzhassarov on 24/01/2022.
//

protocol EndpointSortable {
    associatedtype SortOptions: RawRepresentable where SortOptions.RawValue: StringProtocol
}
