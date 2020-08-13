//
//  LookupConversationsMockData.swift
//  Telabook
//
//  Created by Anmol Rajpal on 14/08/20.
//  Copyright © 2020 Anmol Rajpal. All rights reserved.
//

import Foundation

let lookupConversationsMockData = """
{
    "result": "success",
    "message": "OK",
    "data": {
        "externalCs": [
            {
                "external_conversation_id": 25791,
                "sender_id": 164,
                "sender_name": "Quincy Porter",
                "company_id": 22,
                "all_last_message_text": "Yoto",
                "message_type": "TEXT_ONLY",
                "last_message_date": 1596913360,
                "last_message_datetime": 1596913360,
                "node": "164-24683-Customer",
                "last_message_key": "-MEEsULZlnPXvj5ECfSy",
                "customer_id": 24683,
                "customer_person": "RLT- AIM T100",
                "customer_phone_number": "+18324101983",
                "black_list": 0
            },
            {
                "external_conversation_id": 25926,
                "sender_id": 167,
                "sender_name": "Terminator T100",
                "company_id": 22,
                "all_last_message_text": "Test mms",
                "message_type": "MULTIMEDIA",
                "last_message_date": 1596912750,
                "last_message_datetime": 1596912750,
                "node": "167-24683-Customer",
                "last_message_key": "-MEEq8yCWX7qXL4p5-RJ",
                "customer_id": 24683,
                "customer_person": "RLT- AIM T100",
                "customer_phone_number": "+18324101983",
                "black_list": 0
            }
        ],
        "pages": 1
    }
}
"""
