//
//  Edulink_Homework.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import Foundation
import Evander
import SerializedSwift

public final class Homework: EdulinkBase {
    
    @Serialized var available_date: String
    @Serialized var completed: Bool
    @Serialized var due_date: String
    @Serialized var description: String?
    @Serialized var activity: String
    @Serialized var source: String
    @Serialized var set_by: String
    @Serialized var subject: String

}
