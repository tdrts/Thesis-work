import os
import json


def create_song_json(title, artist, lyrics, image):
    folder_name = "JSON"
    os.makedirs(folder_name, exist_ok=True)

    for index, lyric in enumerate(lyrics):
        data = {
            "name": title,
            "description": lyric,
            "image": image,
            "attributes": [
                {"trait_type": "Artist", "value": artist},
                {"trait_type": "Lyric Index", "value": index}
            ]
        }

        filename = f"{folder_name}/song_5_{index}.json"
        with open(filename, "w") as file:
            json.dump(data, file, indent=4)

        print(f"Created JSON file: {filename}")


# Example usage
song_title = "Without Me"
song_artist = "Halsey"
image = "ipfs://QmTfxMjCq2VS8fjydgJ3cRAPfFV7ciZjXBJykrsJoPuSmi"
song_lyrics = [ "Found you when your heart was broke",
    "I filled your cup until it overflowed",
    "Took it so far to keep you close (keep you close)",
    "I was afraid to leave you on your own",
    "I said I'd catch you if you fall",
    "And if they laugh, then fuck 'em all (all)",
    "And then I got you off your knees",
    "Put you right back on your feet",
    "Just so you could take advantage of me",
    "Tell me how's it feel sittin' up there?",
    "Feeling so high but too far away to hold me",
    "You know I'm the one who put you up there",
    "Name in the sky",
    "Does it ever get lonely?",
    "Thinking you could live without me",
    "Thinking you could live without me",
    "Baby, I'm the one who put you up there",
    "I don't know why (yeah, I don't know why)",
    "Thinking you could live without me",
    "Live without me",
    "Baby, I'm the one who put you up there",
    "I don't know why (I don't know why, yeah yeah)"
      ]

create_song_json(song_title, song_artist, song_lyrics, image)