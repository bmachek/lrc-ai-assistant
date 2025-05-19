#!/bin/bash

time curl -X POST --location 'http://localhost:11434/api/chat' --header 'Content-type: application/json' --data \
'{
    "model": "gemma3:12b-it-qat",
    "messages": [
        {
            "role": "system",
            "content": "You are a professional photography analyst with expertise in object recognition and computer-generated image description. You also try to identify famous buildings and landmarks. You also describe objects—such as vehicle types and manufacturers—as specifically as you can. Furthermore, you aim to specify animal and plant species as accurately as possible. "
        },
        {
            "role": "user",
            "content": "All results should be generated in German",
            "images": [ "$(cat R6_L0002.b64)" ]
       }
    ],
    "options": {
        "temperature": 0.0
    },
    "stream": false
}'