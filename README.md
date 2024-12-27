# **Automatic Subtitle Translation**

When we try to watch an episode of our favorite series or a movie on streaming platforms, it's common to find the video in its original language with subtitles in a language other than the one we prefer. 
This situation can be especially frustrating when we're looking for subtitles in a specific language, like French, for a movie with Italian voices. 
As two students who speak different languages, we realized how challenging it can be to find the right subtitles for a movie in a language we both understand. 
To solve this problem, we came up with the idea of creating a tool that automatically translates subtitles into the desired language, no matter the original language of the movie or show.

## **Features:**

### Translation of Subtitles:
- Automatically translates subtitles into the target language using one of three translation services: DeepL, Google Translate, or OpenAI's ChatGPT.
- Supports multiple subtitle formats, including .srt and .vtt.
- Maintains original subtitle structure, including timing, line numbers, and special lines (like chapter titles or notes).

### Subtitle Extraction (Work in progress...)
- The program can extract subtitles directly from video files (e.g., .mp4, .avi) using tools like ffmpeg or libraries in R.
  
### Re-embedding Translated Subtitles: (Work in progress...)
- After translating the subtitles, the program can re-embed them into the video file, making it ready for playback with the new subtitles.
  
### Subtitle Search and Download (Work in progress...)
- The program can search for subtitle files from online repositories (e.g., SubDL) based on the movie or episode name.
- If subtitles in the desired language aren’t available, the tool will download subtitles in another language and then translate them.
