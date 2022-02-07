//
//  Establishment.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

final public class Establishment: Serializable {
    
    @SerializedTransformable<Base64> var logo: Data?
    @Serialized var name: String
    /*
    @Serialized var rooms: [Room]
    @Serialized var year_groups: [EdulinkStore]
    @Serialized var community_groups: [EdulinkStore]
    @Serialized var applicant_admission_groups: [EdulinkStore]
    @Serialized var applicant_intake_groups: [EdulinkStore]
    @Serialized var teaching_groups: [TeachingGroup]
    @Serialized var form_groups: [FormGroup]
    @Serialized var subjects: [Subject]
    @Serialized var report_card_target_types: [ReportCardTargetType]
    
    final public class Room: EdulinkStore {
        
        @Serialized var code: String
        
    }

    public class TeachingGroup: EdulinkStore {
        
        @Serialized var employee_id: String?
        @Serialized var year_group_ids: [String]?
        
    }

    public class FormGroup: TeachingGroup {
        
        @Serialized var room_id: String
        
    }

    final public class Subject: EdulinkStore {
        
        @Serialized var active: Bool
        
    }

    final public class ReportCardTargetType: EdulinkBase {
        
        @Serialized var code: String
        @Serialized var description: String
        
    }
    */
    required public init() {}
}
