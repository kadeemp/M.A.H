//
//  CardTable.swift
//  M.A.H
//
//  Created by Kadeem Palacios on 8/23/19.
//  Copyright © 2019 Kadeem Palacios. All rights reserved.
//

import Foundation
struct CardTable {
    let currentPrompt:PromptCard
    let responses:[MemeCard]

    init(currentPrompt:PromptCard, responses:[MemeCard]) {
        self.currentPrompt = currentPrompt
        self.responses = responses
    }
}
