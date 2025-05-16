from pathlib import Path
from typing import Literal

from pydantic import BaseModel

from ollama import chat


# Define the schema for image objects
class Object(BaseModel):
  name: str
  confidence: float
  attributes: str


class ImageDescription(BaseModel):
  Bild_Alt_Text: str
  Bildbeschreibung: str
  Bildtitel: str
  keywords: list[Object]

# Get path from user input
# path = input('Enter the path to your image: ')
path = "R6_L0002.jpg"
path = Path(path)

# Verify the file exists
if not path.exists():
  raise FileNotFoundError(f'Image not found at: {path}')

# Set up chat as usual
response = chat(
  model='lrc',
  format=ImageDescription.model_json_schema(),  # Pass in the schema for the response
  messages=[
    {
      'role': 'user',
      'content': 'All results should be in German.',
      'images': [path],
    },
  ],
  options={'temperature': 0},  # Set temperature to 0 for more deterministic output
)


# Convert received content to the schema
image_analysis = ImageDescription.model_validate_json(response.message.content)
print(image_analysis)
