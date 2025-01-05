# **Automatic Subtitle Translation**

As students speaking different languages, we realized how difficult it is to find suitable subtitles for a movie. For instance, to understand the film, we need the subtitles in Italian and the voices in French, or vice versa. This situation led us to create a tool that automatically translates subtitles into the desired language, regardless of the original language of the movie or TV show.

The goal of this project is to enhance the user experience by translating subtitles into any preferred language. Whether you're watching a movie in Italian with French subtitles, in English with Spanish subtitles, or in any other language combination, this tool allows you to easily translate the subtitles to any language of your choice. The project supports various subtitle formats, such as .srt and .vtt, and integrates with popular translation services like DeepL and Google Translate.

## **Features:**

### Subtitle Translation:
Automatically translates subtitles using one of the following services:
- DeepL
- Google Translate

### Subtitle Format Support :
Supports multiple subtitle formats such as .srt and .vtt.

### Maintains Original Subtitle Structure:
The program preserves timing, line numbers, and special subtitle lines (e.g., chapter titles, notes).  

### User Interface:
A user-friendly Shiny interface to upload subtitle files, select translation services, and preview translated subtitles. Once the translation is complete, users can download the translated subtitle file.

## **Installation:**

To use the program, you need to install the required R packages. You can install them using the following commands:
```
if (!require("httr")) install.packages("httr")
if (!require("stringr")) install.packages("stringr")
if (!require("stringi")) install.packages("stringi")
if (!require("jsonlite")) install.packages("jsonlite")
if (!require("shiny")) install.packages("shiny")
if (!require("rvest")) install.packages("rvest")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
```

### Setup : 

- DeepL API Key: To use DeepL's translation service, you'll need to obtain an API key. Visit DeepL's API website to create an account and get your API key. Replace INSERT API KEY with your key in the code.

- If you don't want to make an API key for DeepL you can still use the program, but be sure to check the Google translate box in the user interface.

## How to Use :

### Search for Subtitles:
The program allows you to search for subtitles on OpenSubtitles by entering the name of the movie or TV show you want.

### Download Subtitles:
After performing a search, you can select from the available subtitles, download them, and the program will automatically detect if the file is not encoded in UTF-8, converting it to UTF-8 if necessary.

### Translation:
Once the subtitles are downloaded, you can select a translation service (DeepL or Google Translate), choose the target language, and translate the subtitles.

### Shiny Interface:
The Shiny UI allows you to upload new subtitle files (with the default being the one previously downloaded from OpenSubtitles), choose the translation service, and preview the translation before downloading the translated subtitle file.

## Example Use Case

### Search for Subtitles:

Enter the name of the movie : "La haine"

```
Search results :

1: La haine (1995), URL : https://www.opensubtitles.org/fr/search/sublanguageid-all/idmovie-3292

2: Romeo & Juliette: De la haine a l'amour (2002), URL : https://www.opensubtitles.org/fr/search/sublanguageid-all/idmovie-37310

3: Inde, l'ideologie de la haine (2024), URL : https://www.opensubtitles.org/fr/search/sublanguageid-all/idmovie-1829958
(...)
```

### Choose a number to display the corresponding subtitles : "1"

```
Available subtitles :

1: la-haine Language : he URL : https://www.opensubtitles.org/fr/subtitleserve/sub/12911350

2: la-haine Language : tr URL : https://www.opensubtitles.org/fr/subtitleserve/sub/12874982

3: la-haine Language : de URL : https://www.opensubtitles.org/fr/subtitleserve/sub/12855448
(...)
```

### Select a number to download the corresponding subtitles: "3" (if we want the german subtitles for example)

```
Subtitles downloaded and extracted in: subtitles/La.Haine.1995.1080p.BluRay.x264.AAC5.1-[YTS.MX]-Hass.german_utf8.srt
```

### Open the User Interface : 

The user interface will open, and the previously downloaded file will be preloaded automatically.

### Replace the Preloaded File : 

If you wish to translate another file, you can replace the preloaded file by using the section: Change current file uploaded (SRT or VTT). Simply click on Browse to select your new subtitle file.

### Select the Translation Service :

If you have replaced the API key in the program, choose DeepL as the translation service. Otherwise, select Google Translate.

### Choose the Target Language : 

Select the language you want to translate the subtitles into.

### Translate the Subtitles : 

Click on the Translate button and wait...

_Note: Files uploaded to OpenSubtitles are movie subtitles, which can contain a large number of characters. Translation may take a few minutes (up to 5 minutes if the file is large)._

### Preview the Translated Subtitles :

Once the translation is complete, the translated text will appear on the right-hand side of the interface.

### Check the Translation Time : 

The total translation time will be displayed at the bottom of the preview.

### Download the Translated Subtitles :

To download the final translated subtitle file, click on Download translated subtitles.

## Potential Future Features

- Additional Subtitle Formats : Support for more subtitle formats (e.g., .ass, .sub) will be added.

- ChatGPT (OpenAI) API Support : Integration of the ChatGPT (OpenAI) API to translate subtitle files (But using the API is not free).
