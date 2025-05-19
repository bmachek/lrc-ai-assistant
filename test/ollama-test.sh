#!/bin/bash

time curl -X POST --location 'http://localhost:11434/api/chat' --header 'Content-type: application/json' --data \
'{
    "model": "lrc",
    "format": {
        "type": "object",
        "required": [ "Bildbeschreibung", "Bildtitel", "Bild Alt-Text", "keywords" ],
        "properties": {
            "Bild Alt-Text": {
                "type": "string"
            },
            "Bildbeschreibung": {
                "type": "string"
            },
            "Bildtitel": {
                "type": "string"
            },
            "keywords": {
                "type": "object",
                "required":  [ "Aktivitaeten", "Fahrzeuge", "Firmen", "Gebaeude", "Gegenstaende", "Ort", "Pflanzen", "Sehenswuerdigkeiten", "Stimmungen", "Szene", "Tiere", "Wetterbedingungen" ],
                "properties": {
                    "Aktivitaeten": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Fahrzeuge": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Firmen": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Gebaeude": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Gegenstaende": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Ort": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Pflanzen": {
                        "type": "array",
                        "items": {
                        "type": "string"
                        }
                    },
                    "Sehenswuerdigkeiten": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Stimmungen": {
                        "type": "array",
                        "items": {
                           "type": "string"
                        }
                    },
                    "Szene": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Tiere": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "Wetterbedingungen": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    },
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